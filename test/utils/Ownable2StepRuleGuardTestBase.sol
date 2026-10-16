// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {RuleEngineBase} from "src/RuleEngineBase.sol";
import {RulesManagementModuleInvariantStorage} from "src/modules/library/RulesManagementModuleInvariantStorage.sol";
import {RuleCodeProbe} from "./RuleCodeProbe.sol";

/**
 * @title Ownable2StepRuleGuardTestBase
 * @notice Security review, threat AC-3 / finding F-1, for the two `Ownable2Step` deployables. The guard that
 * keeps rule accounts away from ownership runs at nomination (`transferOwnership`) and again at acceptance
 * (`acceptOwnership`), so an address that becomes a rule while it is the pending owner cannot accept.
 */
abstract contract Ownable2StepRuleGuardTestBase is Test {
    address internal constant OWNER = address(0xA11CE);

    RuleEngineBase internal engine;
    RuleCodeProbe internal nominee;

    /// @dev Deploys the variant with `owner_` as owner and no token bound.
    function _deployEngine(address owner_) internal virtual returns (address);

    function setUp() public virtual {
        engine = RuleEngineBase(_deployEngine(OWNER));
        nominee = new RuleCodeProbe(10, "nominee");
    }

    /// @notice AC-3. Nominating an address that is already a rule is rejected.
    function testCannotNominateACurrentRule() public {
        vm.startPrank(OWNER);
        engine.addRule(nominee);
        vm.expectRevert(
            RulesManagementModuleInvariantStorage.RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges
                .selector
        );
        Ownable2Step(address(engine)).transferOwnership(address(nominee));
        vm.stopPrank();
    }

    /// @notice F-1 regression (was the AC-3 proof of concept). A nominee added as a rule before it accepts
    /// cannot accept: the engine can no longer end up owned by one of its own rules.
    function testNomineeAddedAsRuleBeforeAcceptingCannotAccept() public {
        vm.startPrank(OWNER);
        Ownable2Step(address(engine)).transferOwnership(address(nominee));
        engine.addRule(nominee);
        vm.stopPrank();

        vm.expectRevert(
            RulesManagementModuleInvariantStorage.RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges
                .selector
        );
        vm.prank(address(nominee));
        Ownable2Step(address(engine)).acceptOwnership();

        assertEq(Ownable2Step(address(engine)).owner(), OWNER);
        assertEq(Ownable2Step(address(engine)).pendingOwner(), address(nominee));
    }

    /// @notice F-1. Once the owner removes the nominee from the rule set, the pending transfer completes.
    function testNomineeCanAcceptOnceRemovedFromRules() public {
        vm.startPrank(OWNER);
        Ownable2Step(address(engine)).transferOwnership(address(nominee));
        engine.addRule(nominee);
        engine.removeRule(nominee);
        vm.stopPrank();

        vm.prank(address(nominee));
        Ownable2Step(address(engine)).acceptOwnership();
        assertEq(Ownable2Step(address(engine)).owner(), address(nominee));
    }
}
