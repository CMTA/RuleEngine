// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {IERC3643Compliance} from "src/interfaces/IERC3643Compliance.sol";
import {ITokenBinding} from "src/interfaces/ITokenBinding.sol";
import {ITokenBindingExtended} from "src/interfaces/ITokenBindingExtended.sol";
import {IRulesManagementModule} from "src/interfaces/IRulesManagementModule.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {RuleMintAllowanceMock} from "src/mocks/rules/operation/RuleMintAllowanceMock.sol";
import {TokenBindingModuleInvariantStorage} from "src/modules/library/TokenBindingModuleInvariantStorage.sol";
import {ERC2771ModuleStandalone} from "src/modules/ERC2771ModuleStandalone.sol";

/**
 * @title ERC2771TokenGateTestBase
 * @notice Shared tests pinning that the trusted ERC-2771 forwarder cannot act as a token.
 * @dev The token-identity checks (`onlyBoundToken` and the token self-binding path) compare the raw
 * `msg.sender`, while administrative checks keep the ERC-2771 `_msgSender()`.
 *
 * A relayed call is simulated exactly as `ERC2771Context` sees it: the call comes from the forwarder
 * address, with the claimed sender appended to the calldata (`_relay`). No signature is involved:
 * these tests model a forwarder that relays whatever it is given (buggy, malicious or permissive),
 * which is the case the fix protects against.
 *
 * Each deployable variant inherits this contract and provides its constructor and the revert data of
 * its binding-manager check.
 */
abstract contract ERC2771TokenGateTestBase is Test, TokenBindingModuleInvariantStorage {
    address internal constant ADMIN = address(0xA11CE);
    address internal constant FORWARDER = address(0xF0F0);
    address internal constant TOKEN = address(0x7070);
    address internal constant TOKEN_2 = address(0x7071);
    address internal constant MINTER = address(0x3333);
    address internal constant HOLDER = address(0x4444);

    address internal engine;

    /* ============ Variant hooks ============ */

    /// @dev Deploys the variant with `admin` as admin/owner, `forwarder` as trusted forwarder and `token` bound.
    function _deployEngine(address admin, address forwarder, address token) internal virtual returns (address);

    /// @dev Revert data of the variant's binding-manager check when `caller` is not authorized.
    function _managerRevertData(address caller) internal view virtual returns (bytes memory);

    /* ============ Setup ============ */

    function setUp() public virtual {
        engine = _deployEngine(ADMIN, FORWARDER, TOKEN);
        assertTrue(ERC2771ModuleStandalone(engine).isTrustedForwarder(FORWARDER), "forwarder should be trusted");
        assertTrue(IERC3643Compliance(engine).isTokenBound(TOKEN), "token should be bound");
    }

    /* ============ Helpers ============ */

    /// @dev Calls the engine from the forwarder with `claimedSender` appended, as ERC-2771 does.
    function _relay(address claimedSender, bytes memory data) internal returns (bool ok, bytes memory ret) {
        vm.prank(FORWARDER);
        (ok, ret) = engine.call(abi.encodePacked(data, claimedSender));
    }

    function _assertRelayRevertsUnauthorizedCaller(bytes memory data) internal {
        (bool ok, bytes memory ret) = _relay(TOKEN, data);
        assertFalse(ok, "relayed callback should revert");
        assertEq(ret, abi.encodeWithSelector(TokenBinding_UnauthorizedCaller.selector));
    }

    /* ============ Callbacks: the forwarder cannot act as a bound token ============ */

    /// @notice All four callbacks reject a forwarder relaying a call with a bound token as the claimed sender.
    function testForwarderCannotImpersonateBoundTokenOnCallbacks() public {
        _assertRelayRevertsUnauthorizedCaller(
            abi.encodeWithSignature("transferred(address,address,address,uint256)", MINTER, HOLDER, MINTER, 1)
        );
        _assertRelayRevertsUnauthorizedCaller(
            abi.encodeWithSignature("transferred(address,address,uint256)", HOLDER, MINTER, 1)
        );
        _assertRelayRevertsUnauthorizedCaller(abi.encodeCall(IERC3643Compliance.created, (HOLDER, 1)));
        _assertRelayRevertsUnauthorizedCaller(abi.encodeCall(IERC3643Compliance.destroyed, (HOLDER, 1)));
    }

    /// @notice A bound token calling the engine directly is unaffected by the fix.
    function testBoundTokenCanStillCallCallbacksDirectly() public {
        vm.startPrank(TOKEN);
        IRuleEngine(engine).transferred(MINTER, HOLDER, MINTER, 1);
        IRuleEngine(engine).transferred(HOLDER, MINTER, 1);
        IERC3643Compliance(engine).created(HOLDER, 1);
        IERC3643Compliance(engine).destroyed(HOLDER, 1);
        vm.stopPrank();
    }

    /// @notice A forged mint callback cannot consume a stateful rule's state: the mint quota is untouched,
    /// while the same call made directly by the bound token debits it.
    function testForgedMintCallbackDoesNotConsumeMintAllowance() public {
        RuleMintAllowanceMock mintRule = new RuleMintAllowanceMock(ADMIN);
        vm.startPrank(ADMIN);
        mintRule.setMintAllowance(MINTER, 100);
        IRulesManagementModule(engine).addRule(IRule(address(mintRule)));
        vm.stopPrank();

        _assertRelayRevertsUnauthorizedCaller(
            abi.encodeWithSignature("transferred(address,address,address,uint256)", MINTER, address(0), HOLDER, 60)
        );
        assertEq(mintRule.mintAllowance(MINTER), 100, "forged callback must not consume the quota");

        vm.prank(TOKEN);
        IRuleEngine(engine).transferred(MINTER, address(0), HOLDER, 60);
        assertEq(mintRule.mintAllowance(MINTER), 40, "a real mint callback consumes the quota");
    }

    /* ============ Self-binding: the forwarder cannot act as an approved token ============ */

    /// @notice The forwarder cannot unbind a token approved for self-binding by claiming to be that token.
    function testForwarderCannotUnbindApprovedToken() public {
        vm.prank(ADMIN);
        ITokenBindingExtended(engine).setTokenSelfBindingApproval(TOKEN, true);

        (bool ok, bytes memory ret) = _relay(TOKEN, abi.encodeCall(ITokenBinding.unbindToken, (TOKEN)));
        assertFalse(ok, "relayed self-unbind should revert");
        // The self-binding path no longer matches, so the call falls through to the manager check,
        // which resolves the caller through _msgSender() (the claimed token) and rejects it.
        assertEq(ret, _managerRevertData(TOKEN));
        assertTrue(IERC3643Compliance(engine).isTokenBound(TOKEN), "token must remain bound");
    }

    /// @notice An approved token can still unbind and re-bind itself directly (ERC-3643 `setCompliance`).
    function testApprovedTokenCanStillSelfBindDirectly() public {
        vm.prank(ADMIN);
        ITokenBindingExtended(engine).setTokenSelfBindingApproval(TOKEN, true);

        vm.startPrank(TOKEN);
        IERC3643Compliance(engine).unbindToken(TOKEN);
        assertFalse(IERC3643Compliance(engine).isTokenBound(TOKEN));
        IERC3643Compliance(engine).bindToken(TOKEN);
        vm.stopPrank();
        assertTrue(IERC3643Compliance(engine).isTokenBound(TOKEN));
    }

    /* ============ Administration remains gasless ============ */

    /// @notice The binding manager can still bind and unbind a token through the forwarder.
    function testManagerCanStillBindThroughForwarder() public {
        (bool ok,) = _relay(ADMIN, abi.encodeCall(ITokenBinding.bindToken, (TOKEN_2)));
        assertTrue(ok, "relayed bindToken by the manager should succeed");
        assertTrue(IERC3643Compliance(engine).isTokenBound(TOKEN_2));

        (ok,) = _relay(ADMIN, abi.encodeCall(ITokenBinding.unbindToken, (TOKEN_2)));
        assertTrue(ok, "relayed unbindToken by the manager should succeed");
        assertFalse(IERC3643Compliance(engine).isTokenBound(TOKEN_2));
    }

    /// @notice A relayed bind by a non-manager is still rejected by the manager check.
    function testNonManagerCannotBindThroughForwarder() public {
        (bool ok, bytes memory ret) = _relay(HOLDER, abi.encodeCall(ITokenBinding.bindToken, (TOKEN_2)));
        assertFalse(ok);
        assertEq(ret, _managerRevertData(HOLDER));
    }
}
