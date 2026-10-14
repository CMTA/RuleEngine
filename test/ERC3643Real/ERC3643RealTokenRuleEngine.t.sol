// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ComplianceNotFollowed, Token, TransferNotPossible} from "ERC3643/token/Token.sol";
import {RuleEngine} from "src/deployment/RuleEngine.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {RuleWhitelistMock} from "src/mocks/rules/validation/RuleWhitelistMock.sol";
import {TokenBindingModuleInvariantStorage} from "src/modules/library/TokenBindingModuleInvariantStorage.sol";
import {IdentityRegistryStub} from "./IdentityRegistryStub.sol";
import {SupplyCapProbeRule} from "./SupplyCapProbeRule.sol";

/**
 * @title ERC3643RealTokenRuleEngineTest
 * @notice Integration tests against the REAL vendored ERC-3643 token (`lib/ERC-3643`, T-REX 4.2.0-beta1).
 * `test/RuleEngine/ERC3643TokenIntegration.t.sol` drives `ERC3643TokenMock`, whose compliance calls are
 * transcribed from `Token.sol`; this suite deploys the genuine `Token`, so a change upstream in when or how the
 * token calls compliance breaks these tests instead of silently invalidating the mock.
 * @dev Built by the `erc3643` profile, because `Token.sol` pins `pragma solidity 0.8.30` exactly:
 *
 *     FOUNDRY_PROFILE=erc3643 forge test
 *
 * `test/ERC3643Real/**` is in the default profile's `skip` list, so a plain `forge test` is unaffected.
 */
contract ERC3643RealTokenRuleEngineTest is Test, TokenBindingModuleInvariantStorage {
    address constant ADMIN = address(1);
    address constant AGENT = address(10);
    address constant ALICE = address(11);
    address constant BOB = address(12);
    address constant CAROL = address(13);

    IdentityRegistryStub registry;
    RuleWhitelistMock whitelist;
    RuleEngine engine;
    Token token;

    function setUp() public {
        registry = new IdentityRegistryStub();
        // Everyone is identity-verified, so every rejection below comes from the RuleEngine.
        registry.setVerified(ALICE, true);
        registry.setVerified(BOB, true);
        registry.setVerified(CAROL, true);

        vm.startPrank(ADMIN);
        engine = new RuleEngine(ADMIN, address(0), address(0));
        whitelist = new RuleWhitelistMock(ADMIN, address(0));
        address[] memory listed = new address[](3);
        listed[0] = ALICE;
        listed[1] = BOB;
        // The mint pre-check is canTransfer(address(0), to, amount) and the whitelist treats the zero address
        // as an ordinary participant, so it must be listed for mint and burn to pass.
        listed[2] = address(0);
        whitelist.addAddressesToTheList(listed);
        engine.addRule(IRule(address(whitelist)));
        vm.stopPrank();

        token = new Token();
        // `init` calls setCompliance, which self-binds the token: approval is required first.
        vm.prank(ADMIN);
        engine.setTokenSelfBindingApproval(address(token), true);
        token.init(address(registry), address(engine), "Real ERC-3643", "R3643", 0, address(0));

        // `init` leaves the token paused and makes this contract its owner.
        token.addAgent(AGENT);
        vm.prank(AGENT);
        token.unpause();
    }

    /* ============ Binding ============ */

    /// @notice `init` -> `setCompliance` binds the real token to the engine through self-binding.
    function testInitSelfBindsTheToken() public view {
        assertTrue(engine.isTokenBound(address(token)), "token should be bound after init");
        assertEq(engine.getTokenBound(), address(token));
        assertEq(address(token.compliance()), address(engine));
    }

    /// @notice Without self-binding approval, `init` reverts on the engine's binding manager check.
    function testInitRevertsWithoutSelfBindingApproval() public {
        vm.prank(ADMIN);
        RuleEngine engine2 = new RuleEngine(ADMIN, address(0), address(0));
        Token token2 = new Token();

        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                address(token2),
                engine2.COMPLIANCE_MANAGER_ROLE()
            )
        );
        token2.init(address(registry), address(engine2), "Real ERC-3643", "R3643", 0, address(0));
    }

    /// @notice Re-pointing the token at a second engine unbinds it from the first (`unbindToken(this)`).
    function testSetComplianceMovesTheBinding() public {
        vm.startPrank(ADMIN);
        RuleEngine engine2 = new RuleEngine(ADMIN, address(0), address(0));
        engine2.setTokenSelfBindingApproval(address(token), true);
        vm.stopPrank();

        token.setCompliance(address(engine2));

        assertFalse(engine.isTokenBound(address(token)), "old engine should no longer be bound");
        assertTrue(engine2.isTokenBound(address(token)), "new engine should be bound");
    }

    /* ============ Mint / burn: created / destroyed ============ */

    /// @notice Mint is pre-checked with canTransfer(address(0), ...) then notified through created(), which the
    /// engine forwards to the rules as the 3-argument transferred(address(0), to, value).
    function testMintRoutesThroughCreated() public {
        vm.expectCall(address(engine), abi.encodeCall(engine.canTransfer, (address(0), BOB, 25)));
        vm.expectCall(address(engine), abi.encodeCall(engine.created, (BOB, 25)));
        vm.expectCall(
            address(whitelist), abi.encodeWithSignature("transferred(address,address,uint256)", address(0), BOB, 25)
        );

        vm.prank(AGENT);
        token.mint(BOB, 25);

        assertEq(token.balanceOf(BOB), 25);
    }

    /// @notice A mint to an address the rule rejects fails at the token's pre-check.
    function testMintToUnlistedAddressReverts() public {
        vm.prank(AGENT);
        vm.expectRevert(ComplianceNotFollowed.selector);
        token.mint(CAROL, 1);
    }

    /// @notice If address(0) is not listed, the whitelist blocks every mint (from == address(0)).
    function testMintIsBlockedWhenZeroAddressNotListed() public {
        vm.prank(ADMIN);
        whitelist.removeAddressFromTheList(address(0));

        vm.prank(AGENT);
        vm.expectRevert(ComplianceNotFollowed.selector);
        token.mint(ALICE, 1);
    }

    /// @notice Burn is notified through destroyed(), forwarded as transferred(from, address(0), value).
    function testBurnRoutesThroughDestroyed() public {
        vm.startPrank(AGENT);
        token.mint(ALICE, 100);

        vm.expectCall(address(engine), abi.encodeCall(engine.destroyed, (ALICE, 40)));
        vm.expectCall(
            address(whitelist), abi.encodeWithSignature("transferred(address,address,uint256)", ALICE, address(0), 40)
        );
        token.burn(ALICE, 40);
        vm.stopPrank();

        assertEq(token.balanceOf(ALICE), 60);
    }

    /* ============ Transfers: transferred(from, to, value) ============ */

    /// @notice A transfer between listed addresses succeeds and notifies the engine with no spender.
    function testTransferRoutesThroughThreeArgumentTransferred() public {
        vm.prank(AGENT);
        token.mint(ALICE, 100);

        vm.expectCall(address(engine), abi.encodeWithSignature("transferred(address,address,uint256)", ALICE, BOB, 40));
        vm.prank(ALICE);
        token.transfer(BOB, 40);

        assertEq(token.balanceOf(ALICE), 60);
        assertEq(token.balanceOf(BOB), 40);
    }

    /// @notice transferFrom also uses the 3-argument overload: ERC-3643 never forwards the spender.
    function testTransferFromCarriesNoSpender() public {
        vm.prank(AGENT);
        token.mint(ALICE, 100);
        vm.prank(ALICE);
        token.approve(CAROL, 30);

        // CAROL (the spender) is not whitelisted: the transfer still passes, because the engine never sees her.
        vm.expectCall(address(engine), abi.encodeWithSignature("transferred(address,address,uint256)", ALICE, BOB, 30));
        vm.prank(CAROL);
        token.transferFrom(ALICE, BOB, 30);

        assertEq(token.balanceOf(BOB), 30);
    }

    /// @notice A transfer to an address the rule rejects fails at the token's canTransfer pre-check.
    function testTransferToUnlistedAddressReverts() public {
        vm.prank(AGENT);
        token.mint(ALICE, 100);

        vm.prank(ALICE);
        vm.expectRevert(TransferNotPossible.selector);
        token.transfer(CAROL, 10);
    }

    /// @notice Unlike CMTAT, T-REX's forcedTransfer notifies compliance, so a rule can block it: the token skips
    /// the canTransfer pre-check but the engine's transferred() still runs the rules and reverts.
    function testForcedTransferNotifiesComplianceAndCanBeBlocked() public {
        vm.startPrank(AGENT);
        token.mint(ALICE, 100);

        vm.expectRevert(
            abi.encodeWithSelector(
                RuleWhitelistMock.RuleWhitelist_InvalidTransfer.selector,
                ALICE,
                CAROL,
                10,
                whitelist.CODE_ADDRESS_TO_NOT_WHITELISTED()
            )
        );
        token.forcedTransfer(ALICE, CAROL, 10);

        vm.expectCall(address(engine), abi.encodeWithSignature("transferred(address,address,uint256)", ALICE, BOB, 10));
        token.forcedTransfer(ALICE, BOB, 10);
        vm.stopPrank();

        assertEq(token.balanceOf(BOB), 10);
    }

    /* ============ Access ============ */

    /// @notice Only the bound token may call the compliance callbacks.
    function testUnboundCallerCannotCallCallbacks() public {
        vm.startPrank(CAROL);
        vm.expectRevert(TokenBinding_UnauthorizedCaller.selector);
        engine.transferred(ALICE, BOB, 1);
        vm.expectRevert(TokenBinding_UnauthorizedCaller.selector);
        engine.created(BOB, 1);
        vm.expectRevert(TokenBinding_UnauthorizedCaller.selector);
        engine.destroyed(ALICE, 1);
        vm.stopPrank();
    }

    /* ============ Notification order ============ */

    /// @notice T-REX notifies compliance AFTER the state change (`_mint` then `created`). A CMTAT-style cap
    /// (`totalSupply() + value <= cap`) passes the pre-check, which runs before `_mint`, but counts the amount
    /// twice in `created`, and the mint reverts although it reaches the cap exactly.
    /// See doc/technical/RuleEngine-with-ERC3643.md section 4.9.
    function testComplianceIsNotifiedAfterTheMint() public {
        SupplyCapProbeRule probe = new SupplyCapProbeRule(IERC20(address(token)), 100);
        vm.prank(ADMIN);
        engine.addRule(IRule(address(probe)));

        // Before the mint, the engine's view projects the amount once: 0 + 100 <= 100.
        assertTrue(engine.canTransfer(address(0), BOB, 100), "pre-check should accept a mint up to the cap");

        // In created(), totalSupply() already includes the 100: 100 + 100 > 100.
        vm.prank(AGENT);
        vm.expectRevert(
            abi.encodeWithSelector(SupplyCapProbeRule.SupplyCapProbeRule_CapExceeded.selector, 100, 100, 100)
        );
        token.mint(BOB, 100);

        // Half the cap is the effective limit on T-REX for such a rule.
        vm.prank(AGENT);
        token.mint(BOB, 50);
        assertEq(token.totalSupply(), 50);
    }
}
