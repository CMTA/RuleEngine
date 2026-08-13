// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRule} from "../../interfaces/IRule.sol";

/**
 * @title RulesManagementModuleInvariantStorage
 * @notice Holds the errors, events and default limits used by the rules management module.
 */
abstract contract RulesManagementModuleInvariantStorage {
    /**
     * @notice Default upper bound on the number of rules a RuleEngine may hold.
     * @dev Bounds the per-transfer gas cost of iterating the rule set.
     */
    uint256 public constant DEFAULT_MAX_RULES = 10;

    /* ==== Errors === */
    error RuleEngine_RulesManagementModule_RuleAddressZeroNotAllowed();
    error RuleEngine_RulesManagementModule_RuleAlreadyExists();
    error RuleEngine_RulesManagementModule_RuleDoNotMatch();
    error RuleEngine_RulesManagementModule_ArrayIsEmpty();
    error RuleEngine_RulesManagementModule_OperationNotSuccessful();
    error RuleEngine_RulesManagementModule_MaxRulesExceeded(uint256 maxRules);
    error RuleEngine_RulesManagementModule_MaxRulesZeroNotAllowed();
    error RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges();

    /* ============ Events ============ */
    /**
     * @notice Emitted when a new rule is added to the rule set.
     * @param rule The address of the rule contract that was added.
     */
    event AddRule(IRule indexed rule);

    /**
     * @notice Emitted when a rule is removed from the rule set.
     * @param rule The address of the rule contract that was removed.
     */
    event RemoveRule(IRule indexed rule);

    /**
     * @notice Emitted when all rules are cleared from the rule set.
     */
    event ClearRules();

    /**
     * @notice Emitted when the maximum allowed number of rules is updated.
     * @param maxRules The new rule cap.
     */
    event SetMaxRules(uint256 maxRules);
}
