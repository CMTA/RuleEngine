// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RuleEngine} from "src/deployment/RuleEngine.sol";
import {RuleEngineOwnable} from "src/deployment/RuleEngineOwnable.sol";
import {RuleEngineOwnable2Step} from "src/deployment/RuleEngineOwnable2Step.sol";
import {RulesManagementModuleInvariantStorage} from "src/modules/library/RulesManagementModuleInvariantStorage.sol";

/**
 * @title RuleEngineMaxRulesEventTest
 * @notice C-1: deployment must emit {SetMaxRules} so the event log alone is sufficient
 *         to reconstruct the configured rule cap. Without it an event-only indexer sees
 *         no value until the first administrative change.
 */
contract RuleEngineMaxRulesEventTest is Test, RulesManagementModuleInvariantStorage {
    address constant ADMIN = address(1);
    address constant FORWARDER = address(0);

    function testRuleEngineEmitsInitialMaxRulesOnDeployment() public {
        vm.expectEmit(true, true, true, true);
        emit SetMaxRules(DEFAULT_MAX_RULES);
        new RuleEngine(ADMIN, FORWARDER, address(0));
    }

    function testRuleEngineOwnableEmitsInitialMaxRulesOnDeployment() public {
        vm.expectEmit(true, true, true, true);
        emit SetMaxRules(DEFAULT_MAX_RULES);
        new RuleEngineOwnable(ADMIN, FORWARDER, address(0));
    }

    function testRuleEngineOwnable2StepEmitsInitialMaxRulesOnDeployment() public {
        vm.expectEmit(true, true, true, true);
        emit SetMaxRules(DEFAULT_MAX_RULES);
        new RuleEngineOwnable2Step(ADMIN, FORWARDER, address(0));
    }
}
