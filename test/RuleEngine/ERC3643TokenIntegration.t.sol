// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RuleEngine} from "src/deployment/RuleEngine.sol";
import {ERC3643TokenMock} from "src/mocks/ERC3643TokenMock.sol";
import {RuleWhitelistMock} from "src/mocks/rules/validation/RuleWhitelistMock.sol";
import {RuleMintAllowanceMock} from "src/mocks/rules/operation/RuleMintAllowanceMock.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {ERC3643ComplianceModuleInvariantStorage} from "src/modules/library/ERC3643ComplianceModuleInvariantStorage.sol";

/**
 * @title ERC3643TokenIntegrationTest
 * @notice Drives the RuleEngine through the ERC-3643 entry points, using a token whose compliance
 * interaction is modelled on `Token.sol` from the reference implementation in `lib/ERC-3643` (4.1.3).
 * @dev Covers the entry points an ERC-3643 token actually uses: the `setCompliance` self-binding
 * dance, `transferred(from, to, value)` for transfers, and `created` / `destroyed` for mint and
 * burn. An ERC-3643 token never reaches the 4-argument `transferred(spender, ...)` overload, which
 * belongs to CMTAT's `IRuleEngine`.
 */
contract ERC3643TokenIntegrationTest is Test, ERC3643ComplianceModuleInvariantStorage {
    RuleEngine engine;
    ERC3643TokenMock token;
    RuleWhitelistMock whitelist;

    address constant ADMIN = address(1);
    address constant ALICE = address(2);
    address constant BOB = address(3);
    address constant CAROL = address(4);

    function setUp() public {
        vm.startPrank(ADMIN);
        engine = new RuleEngine(ADMIN, address(0), address(0));
        token = new ERC3643TokenMock();

        whitelist = new RuleWhitelistMock(ADMIN, address(0));
        address[] memory listed = new address[](3);
        listed[0] = ALICE;
        listed[1] = BOB;
        // address(0) must be listed for mint and burn to pass the whitelist: the rule treats the
        // zero address as an ordinary participant, and an ERC-3643 mint is pre-checked as
        // canTransfer(address(0), to, amount). See testMintIsBlockedWhenZeroAddressNotListed.
        listed[2] = address(0);
        whitelist.addAddressesToTheList(listed);
        engine.addRule(IRule(address(whitelist)));

        // The token binds itself in setCompliance, so it needs self-binding approval first.
        engine.setTokenSelfBindingApproval(address(token), true);
        vm.stopPrank();

        token.setCompliance(address(engine));
    }

    /* ============ Binding ============ */

    /// @notice The documented setCompliance sequence binds the token to the engine.
    function testSetComplianceBindsTheToken() public view {
        assertTrue(engine.isTokenBound(address(token)), "token should be bound after setCompliance");
        assertEq(engine.getTokenBound(), address(token));
    }

    /// @notice Re-pointing the token at a second engine unbinds it from the first.
    function testSetComplianceUnbindsThePreviousEngine() public {
        vm.startPrank(ADMIN);
        RuleEngine engine2 = new RuleEngine(ADMIN, address(0), address(0));
        engine2.setTokenSelfBindingApproval(address(token), true);
        vm.stopPrank();

        token.setCompliance(address(engine2));

        assertFalse(engine.isTokenBound(address(token)), "old engine should no longer be bound");
        assertTrue(engine2.isTokenBound(address(token)), "new engine should be bound");
    }

    /// @notice Without self-binding approval the token cannot bind itself.
    function testSetComplianceRevertsWithoutSelfBindingApproval() public {
        vm.prank(ADMIN);
        RuleEngine engine2 = new RuleEngine(ADMIN, address(0), address(0));

        ERC3643TokenMock token2 = new ERC3643TokenMock();
        vm.expectRevert();
        token2.setCompliance(address(engine2));
    }

    /* ============ transferred ============ */

    /// @notice A transfer between whitelisted addresses is allowed and notifies the engine.
    function testTransferBetweenListedAddressesSucceeds() public {
        token.mint(ALICE, 100);

        vm.prank(ALICE);
        token.transfer(BOB, 40);

        assertEq(token.balanceOf(ALICE), 60);
        assertEq(token.balanceOf(BOB), 40);
    }

    /// @notice A transfer to a non-whitelisted address is rejected by the rule via the engine.
    function testTransferToUnlistedAddressReverts() public {
        token.mint(ALICE, 100);

        vm.prank(ALICE);
        vm.expectRevert();
        token.transfer(CAROL, 10);
    }

    /// @notice Only a bound token may call the ERC-3643 callbacks.
    function testUnboundCallerCannotCallTransferred() public {
        vm.prank(CAROL);
        vm.expectRevert(RuleEngine_ERC3643Compliance_UnauthorizedCaller.selector);
        engine.transferred(ALICE, BOB, 1);
    }

    /* ============ created / destroyed ============ */

    /// @notice Mint routes through created() and is accepted for a listed recipient.
    function testMintRoutesThroughCreated() public {
        token.mint(BOB, 25);
        assertEq(token.balanceOf(BOB), 25);
    }

    /// @notice Burn routes through destroyed().
    function testBurnRoutesThroughDestroyed() public {
        token.mint(ALICE, 30);
        token.burn(ALICE, 10);
        assertEq(token.balanceOf(ALICE), 20);
    }

    /// @notice created() and destroyed() are restricted to bound tokens.
    function testUnboundCallerCannotCallCreatedOrDestroyed() public {
        vm.startPrank(CAROL);
        vm.expectRevert(RuleEngine_ERC3643Compliance_UnauthorizedCaller.selector);
        engine.created(BOB, 1);

        vm.expectRevert(RuleEngine_ERC3643Compliance_UnauthorizedCaller.selector);
        engine.destroyed(ALICE, 1);
        vm.stopPrank();
    }

    /**
     * @notice The zero address must be whitelisted for an ERC-3643 token to mint.
     * @dev {RuleWhitelistMock} treats `address(0)` as an ordinary participant, and the reference
     * ERC-3643 token pre-checks a mint as `canTransfer(address(0), to, amount)`. An issuer who
     * whitelists only real holders therefore cannot mint at all. This test pins that operational
     * requirement so the behaviour is not changed unnoticed.
     */
    function testMintIsBlockedWhenZeroAddressNotListed() public {
        vm.startPrank(ADMIN);
        RuleEngine engine2 = new RuleEngine(ADMIN, address(0), address(0));
        RuleWhitelistMock whitelist2 = new RuleWhitelistMock(ADMIN, address(0));
        address[] memory listed = new address[](1);
        listed[0] = BOB; // real holder only, zero address deliberately omitted
        whitelist2.addAddressesToTheList(listed);
        engine2.addRule(IRule(address(whitelist2)));

        ERC3643TokenMock token2 = new ERC3643TokenMock();
        engine2.setTokenSelfBindingApproval(address(token2), true);
        vm.stopPrank();
        token2.setCompliance(address(engine2));

        // The mint pre-check reports the origin (address(0)) as not whitelisted.
        assertEq(engine2.detectTransferRestriction(address(0), BOB, 10), whitelist2.CODE_ADDRESS_FROM_NOT_WHITELISTED());
        assertFalse(engine2.canTransfer(address(0), BOB, 10));

        vm.expectRevert(ERC3643TokenMock.ERC3643TokenMock_ComplianceNotFollowed.selector);
        token2.mint(BOB, 10);
    }

    /* ============ H-1: the mint pre-check fails open ============ */

    /**
     * @notice Regression guard for H-1 (see doc/security/audits/tools/v3.0.0-rc5/CLAUDE_ANALYSIS.md).
     * @dev The reference ERC-3643 token pre-checks a mint with `canTransfer(address(0), to, amount)`,
     * which carries no spender. A spender-keyed rule cannot evaluate the mint on that path and
     * answers "no restriction", so the pre-check passes while the spender-aware path rejects.
     * This test pins that documented behaviour so a change to it is noticed.
     */
    function testMintPreCheckFailsOpenForSpenderKeyedRule() public {
        vm.startPrank(ADMIN);
        RuleMintAllowanceMock mintRule = new RuleMintAllowanceMock(ADMIN);
        mintRule.setMintAllowance(address(token), 10);
        engine.addRule(IRule(address(mintRule)));
        vm.stopPrank();

        uint256 overAllowance = 500;

        // The 3-argument path the ERC-3643 token uses reports no restriction.
        assertTrue(
            engine.canTransfer(address(0), BOB, overAllowance), "canTransfer fails open: no spender on this path"
        );
        assertEq(engine.detectTransferRestriction(address(0), BOB, overAllowance), 0);

        // The 4-argument path, which has the spender, reports the restriction.
        assertFalse(engine.canTransferFrom(address(token), address(0), BOB, overAllowance));
        assertEq(engine.detectTransferRestrictionFrom(address(token), address(0), BOB, overAllowance), 81);
    }
}
