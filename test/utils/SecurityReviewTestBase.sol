// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test, Vm} from "forge-std/Test.sol";
import {ITokenBindingExtended} from "src/interfaces/ITokenBindingExtended.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {IRulesManagementModule} from "src/interfaces/IRulesManagementModule.sol";
import {RuleEngineBase} from "src/RuleEngineBase.sol";
import {RuleMintAllowanceMock} from "src/mocks/rules/operation/RuleMintAllowanceMock.sol";
import {TokenBindingModuleInvariantStorage} from "src/modules/library/TokenBindingModuleInvariantStorage.sol";
import {RuleCodeProbe} from "./RuleCodeProbe.sol";
import {RevertingViewRule} from "./RevertingViewRule.sol";
import {ReentrantAdminRule} from "./ReentrantAdminRule.sol";

/**
 * @title SecurityReviewTestBase
 * @notice Tests written for the v3.0.0-rc7 security review, run for every deployable variant. Each test names
 * the threat it covers (see the review report). Several are proofs of concept that pin the current behaviour
 * of a finding: they document what the engine does today, and must change if the finding is fixed.
 * @dev `_deployEngine` deploys the variant with `ADMIN` as admin/owner and `TOKEN` bound; a `*2771` variant uses
 * `FORWARDER`, which the fuzzed callers exclude.
 */
abstract contract SecurityReviewTestBase is Test {
    address internal constant ADMIN = address(0xA11CE);
    address internal constant FORWARDER = address(0xF0F0);
    address internal constant TOKEN = address(0x7070);
    address internal constant TOKEN_2 = address(0x7071);
    address internal constant MINTER = address(0x3333);
    address internal constant HOLDER = address(0x4444);

    bytes32 internal constant DEFAULT_ADMIN_ROLE = bytes32(0);
    bytes32 internal constant RULES_MANAGEMENT_ROLE = keccak256("RULES_MANAGEMENT_ROLE");
    bytes32 internal constant COMPLIANCE_MANAGER_ROLE = keccak256("COMPLIANCE_MANAGER_ROLE");

    RuleEngineBase internal engine;
    RuleCodeProbe internal probe;

    /* ============ Variant hooks ============ */

    /// @dev Deploys the variant with `admin` as admin/owner and `token` bound.
    function _deployEngine(address admin, address token) internal virtual returns (address);

    /// @dev Revert data of the variant when `caller` lacks `role` (RBAC) or is not the owner (ownable variants).
    function _unauthorizedRevertData(address caller, bytes32 role) internal view virtual returns (bytes memory);

    /// @dev Makes `ADMIN` give up control: renounce `DEFAULT_ADMIN_ROLE` (RBAC) or ownership (ownable variants).
    function _renounceAdministration() internal virtual;

    function setUp() public virtual {
        engine = RuleEngineBase(_deployEngine(ADMIN, TOKEN));
        probe = new RuleCodeProbe(10, "probe");
    }

    /* ============ AC-6: every admin entry point rejects every other caller ============ */

    /// @notice AC-6. A random caller is rejected by the eleven administrative entry points, with the exact error
    /// of the variant's guard: rule management needs RULES_MANAGEMENT_ROLE, the cap needs DEFAULT_ADMIN_ROLE,
    /// binding needs COMPLIANCE_MANAGER_ROLE; the ownable variants need the owner for all of them.
    function testFuzz_NonAuthorizedCallerCannotAdminister(address caller) public {
        vm.assume(caller != ADMIN && caller != FORWARDER);
        IRule[] memory rs = new IRule[](1);
        rs[0] = probe;
        address[] memory ts = new address[](1);
        ts[0] = TOKEN_2;

        _expectUnauthorized(caller, RULES_MANAGEMENT_ROLE);
        engine.addRule(probe);
        _expectUnauthorized(caller, RULES_MANAGEMENT_ROLE);
        engine.removeRule(probe);
        _expectUnauthorized(caller, RULES_MANAGEMENT_ROLE);
        engine.setRules(rs);
        _expectUnauthorized(caller, RULES_MANAGEMENT_ROLE);
        engine.clearRules();
        _expectUnauthorized(caller, DEFAULT_ADMIN_ROLE);
        engine.setMaxRules(5);
        _expectUnauthorized(caller, COMPLIANCE_MANAGER_ROLE);
        engine.bindToken(TOKEN_2);
        _expectUnauthorized(caller, COMPLIANCE_MANAGER_ROLE);
        engine.unbindToken(TOKEN);
        _expectUnauthorized(caller, COMPLIANCE_MANAGER_ROLE);
        engine.bindTokens(ts);
        _expectUnauthorized(caller, COMPLIANCE_MANAGER_ROLE);
        engine.unbindTokens(ts);
        _expectUnauthorized(caller, COMPLIANCE_MANAGER_ROLE);
        engine.setTokenSelfBindingApproval(TOKEN_2, true);
        _expectUnauthorized(caller, COMPLIANCE_MANAGER_ROLE);
        engine.setTokenSelfBindingApprovalBatch(ts, true);
    }

    /// @notice Invariant 4. A random caller that is not a bound token is rejected by the four token callbacks.
    function testFuzz_UnboundCallerCannotDriveRules(address caller) public {
        vm.assume(caller != TOKEN && caller != FORWARDER);
        bytes4 unauthorized = TokenBindingModuleInvariantStorage.TokenBinding_UnauthorizedCaller.selector;

        vm.prank(caller);
        vm.expectRevert(unauthorized);
        engine.transferred(HOLDER, MINTER, 1);
        vm.prank(caller);
        vm.expectRevert(unauthorized);
        engine.transferred(MINTER, HOLDER, MINTER, 1);
        vm.prank(caller);
        vm.expectRevert(unauthorized);
        engine.created(HOLDER, 1);
        vm.prank(caller);
        vm.expectRevert(unauthorized);
        engine.destroyed(HOLDER, 1);
    }

    /* ============ TB-2 / F-2: an administrative unbind revokes the self-binding approval ============ */

    /// @notice F-2 regression (was the TB-2 proof of concept). When the manager unbinds a token approved for
    /// self-binding, the approval is revoked with a `TokenSelfBindingApprovalSet(token, false)` event, so the
    /// token cannot bind itself again.
    function testManagerUnbindRevokesSelfBindingApproval() public {
        vm.startPrank(ADMIN);
        engine.setTokenSelfBindingApproval(TOKEN_2, true);
        engine.bindToken(TOKEN_2);
        vm.expectEmit(address(engine));
        emit ITokenBindingExtended.TokenSelfBindingApprovalSet(TOKEN_2, false);
        engine.unbindToken(TOKEN_2);
        vm.stopPrank();
        assertFalse(engine.isTokenSelfBindingApproved(TOKEN_2));

        _expectUnauthorized(TOKEN_2, COMPLIANCE_MANAGER_ROLE);
        engine.bindToken(TOKEN_2);
        assertFalse(engine.isTokenBound(TOKEN_2));
    }

    /// @notice F-2. The batch `unbindTokens` revokes the approvals the same way.
    function testManagerBatchUnbindRevokesSelfBindingApproval() public {
        address[] memory ts = new address[](1);
        ts[0] = TOKEN_2;
        vm.startPrank(ADMIN);
        engine.setTokenSelfBindingApproval(TOKEN_2, true);
        engine.bindToken(TOKEN_2);
        engine.unbindTokens(ts);
        vm.stopPrank();

        assertFalse(engine.isTokenSelfBindingApproved(TOKEN_2));
        _expectUnauthorized(TOKEN_2, COMPLIANCE_MANAGER_ROLE);
        engine.bindToken(TOKEN_2);
    }

    /// @notice F-2. A token that unbinds itself (ERC-3643 `setCompliance` moving away) keeps its approval and can
    /// bind itself again later.
    function testTokenUnbindingItselfKeepsApproval() public {
        vm.prank(ADMIN);
        engine.setTokenSelfBindingApproval(TOKEN_2, true);

        vm.startPrank(TOKEN_2);
        engine.bindToken(TOKEN_2);
        engine.unbindToken(TOKEN_2);
        assertTrue(engine.isTokenSelfBindingApproved(TOKEN_2));
        engine.bindToken(TOKEN_2);
        vm.stopPrank();
        assertTrue(engine.isTokenBound(TOKEN_2));
    }

    /// @notice F-2. Unbinding a token that was never approved emits no approval event.
    function testManagerUnbindOfUnapprovedTokenEmitsNoApprovalEvent() public {
        vm.recordLogs();
        vm.prank(ADMIN);
        engine.unbindToken(TOKEN);
        Vm.Log[] memory logs = vm.getRecordedLogs();
        assertEq(logs.length, 1, "TokenUnbound only");
        assertFalse(engine.isTokenSelfBindingApproved(TOKEN));
    }

    /// @notice TB-2. Revoking the approval explicitly before unbinding also keeps the token out.
    function testRevokingApprovalPreventsRebind() public {
        vm.startPrank(ADMIN);
        engine.setTokenSelfBindingApproval(TOKEN_2, true);
        engine.bindToken(TOKEN_2);
        engine.setTokenSelfBindingApproval(TOKEN_2, false);
        engine.unbindToken(TOKEN_2);
        vm.stopPrank();

        _expectUnauthorized(TOKEN_2, COMPLIANCE_MANAGER_ROLE);
        engine.bindToken(TOKEN_2);
        assertFalse(engine.isTokenBound(TOKEN_2));
    }

    /* ============ TB-3: any address can be bound ============ */

    /// @notice TB-3 (proof of concept). Binding does not check the rule set: an address can be a rule and a
    /// bound token at the same time.
    function testRuleAddressCanBeBoundAsToken() public {
        vm.startPrank(ADMIN);
        engine.addRule(probe);
        engine.bindToken(address(probe));
        vm.stopPrank();
        assertTrue(engine.containsRule(probe));
        assertTrue(engine.isTokenBound(address(probe)));
    }

    /// @notice TB-3 (proof of concept). A bound externally owned account drives a stateful rule with no token
    /// movement: here it consumes a minter's allowance. Binding is a trust decision of the manager.
    function testBoundEoaConsumesStatefulRuleState() public {
        address eoa = address(0xE0A);
        RuleMintAllowanceMock allowance = new RuleMintAllowanceMock(ADMIN);
        vm.startPrank(ADMIN);
        allowance.setMintAllowance(MINTER, 100);
        engine.addRule(IRule(address(allowance)));
        engine.bindToken(eoa);
        vm.stopPrank();

        vm.prank(eoa);
        engine.transferred(MINTER, address(0), HOLDER, 60);
        assertEq(allowance.mintAllowance(MINTER), 40, "allowance consumed without any mint");
    }

    /* ============ RE-2: views propagate a rule's revert ============ */

    /// @notice RE-2 (proof of concept). When a rule's view reverts, the engine's ERC-1404 and ERC-3643 views
    /// revert instead of returning a restriction code, while the enforcement path, which does not call those
    /// views, still accepts the operation.
    function testViewsRevertWhenARuleViewReverts() public {
        RevertingViewRule rule = new RevertingViewRule();
        vm.prank(ADMIN);
        engine.addRule(rule);
        bytes4 err = RevertingViewRule.RevertingViewRule_ViewReverted.selector;

        vm.expectRevert(err);
        engine.detectTransferRestriction(HOLDER, MINTER, 1);
        vm.expectRevert(err);
        engine.detectTransferRestrictionFrom(MINTER, HOLDER, MINTER, 1);
        vm.expectRevert(err);
        engine.canTransfer(HOLDER, MINTER, 1);
        vm.expectRevert(err);
        engine.canTransferFrom(MINTER, HOLDER, MINTER, 1);
        vm.expectRevert(err);
        engine.messageForTransferRestriction(1);

        vm.prank(TOKEN);
        engine.transferred(HOLDER, MINTER, 1);
    }

    /* ============ RE-4 / AC-2: a rule cannot reconfigure the engine from a callback ============ */

    /// @notice RE-4 / AC-2. A rule that calls `addRule` from its `transferred` hook is rejected by the guard,
    /// because a rule account holds no role and no ownership; the token operation reverts with that error.
    function testRuleCannotReconfigureEngineFromCallback() public {
        ReentrantAdminRule rule = new ReentrantAdminRule(IRulesManagementModule(address(engine)), probe);
        vm.prank(ADMIN);
        engine.addRule(rule);

        vm.expectRevert(_unauthorizedRevertData(address(rule), RULES_MANAGEMENT_ROLE));
        vm.prank(TOKEN);
        engine.transferred(HOLDER, MINTER, 1);
        assertFalse(engine.containsRule(probe));
    }

    /* ============ AC-4: giving up administration freezes the configuration ============ */

    /// @notice AC-4. Once the administrator renounces, nobody can change the rule set or the bindings; the bound
    /// token keeps operating under the rules in place.
    function testRenouncingAdministrationFreezesConfiguration() public {
        vm.prank(ADMIN);
        engine.addRule(probe);
        _renounceAdministration();

        _expectUnauthorized(ADMIN, RULES_MANAGEMENT_ROLE);
        engine.removeRule(probe);
        _expectUnauthorized(ADMIN, COMPLIANCE_MANAGER_ROLE);
        engine.unbindToken(TOKEN);

        probe.setCodes(42, 0);
        vm.prank(TOKEN);
        vm.expectRevert(abi.encodeWithSelector(RuleCodeProbe.RuleCodeProbe_Rejected.selector, uint8(42)));
        engine.transferred(HOLDER, MINTER, 1);
    }

    /* ============ CM-2: ERC-3643 mint carries no operator ============ */

    /// @notice CM-2. The ERC-3643 `created` callback carries no operator, so a spender-keyed rule (mint
    /// allowance) is not applied to it; the CMTAT 4-argument path, which carries the minter, is.
    function testErc3643CreatedDoesNotReachSpenderKeyedRule() public {
        RuleMintAllowanceMock allowance = new RuleMintAllowanceMock(ADMIN);
        vm.startPrank(ADMIN);
        allowance.setMintAllowance(MINTER, 100);
        engine.addRule(IRule(address(allowance)));
        vm.stopPrank();

        vm.prank(TOKEN);
        engine.created(HOLDER, 60);
        assertEq(allowance.mintAllowance(MINTER), 100, "created: no operator, nothing consumed");

        vm.prank(TOKEN);
        engine.transferred(MINTER, address(0), HOLDER, 60);
        assertEq(allowance.mintAllowance(MINTER), 40, "4-argument mint: minter's allowance consumed");
    }

    /* ============ Helpers ============ */

    function _expectUnauthorized(address caller, bytes32 role) internal {
        vm.prank(caller);
        vm.expectRevert(_unauthorizedRevertData(caller, role));
    }
}
