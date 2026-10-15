// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {RuleEngineBase} from "src/RuleEngineBase.sol";
import {RulesManagementModuleInvariantStorage} from "src/modules/library/RulesManagementModuleInvariantStorage.sol";
import {RuleCodeProbe} from "./RuleCodeProbe.sol";

/**
 * @title Ownable2StepRuleGuardTestBase
 * @notice Security review, threat AC-3, for the two `Ownable2Step` deployables. The guard that keeps rule
 * accounts away from ownership runs in `transferOwnership`, at nomination. `acceptOwnership` is inherited from
 * OpenZeppelin and does not repeat it, so an address that becomes a rule while it is the pending owner can
 * still accept. These tests pin the current behaviour.
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

    /// @notice AC-3 (proof of concept). A nominee added as a rule before it accepts still becomes the owner, so
    /// the engine ends up owned by one of its own rules.
    function testNomineeAddedAsRuleBeforeAcceptingBecomesOwner() public {
        vm.startPrank(OWNER);
        Ownable2Step(address(engine)).transferOwnership(address(nominee));
        engine.addRule(nominee);
        vm.stopPrank();

        vm.prank(address(nominee));
        Ownable2Step(address(engine)).acceptOwnership();

        assertEq(Ownable2Step(address(engine)).owner(), address(nominee));
        assertTrue(engine.containsRule(nominee), "the owner is a rule of the engine it owns");
    }
}
