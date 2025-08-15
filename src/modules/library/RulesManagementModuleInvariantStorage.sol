// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRule} from "../../interfaces/IRule.sol";

abstract contract RulesManagementModuleInvariantStorage {
    /* ==== Errors === */
    error RuleEngine_RulesManagementModule_RuleAddressZeroNotAllowed();
    error RuleEngine_RulesManagementModule_RuleAlreadyExists();
    error RuleEngine_RulesManagementModule_RuleDoNotMatch();
    error RuleEngine_RulesManagementModule_ArrayIsEmpty();
    error RuleEngine_RulesManagementModule_OperationNotSuccessful();


    /* ============ Events ============ */
    /// @notice Generate when a rule is added
    event AddRule(IRule indexed rule);
    /// @notice Generate when a rule is removed
    event RemoveRule(IRule indexed rule);
    /// @notice Generate when all the rules are cleared
    event ClearRules();

    /* ==== Constant === */
    /// @notice Role to manage the ruleEngine
    bytes32 public constant RULES_MANAGEMENT_ROLE =
        keccak256("RULES_MANAGEMENT_ROLE");
}
