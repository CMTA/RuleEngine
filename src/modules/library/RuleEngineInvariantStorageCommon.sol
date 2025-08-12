// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract RuleEngineInvariantStorageCommon {
    /* ==== Errors === */
    error RuleEngine_RuleAddressZeroNotAllowed();
    error RuleEngine_RuleAlreadyExists();
    error RuleEngine_RuleDoNotMatch();
    error RuleEngine_ArrayIsEmpty();

    /* ==== Constant === */
    /// @notice Role to manage the ruleEngine
    bytes32 public constant RULE_ENGINE_OPERATOR_ROLE =
        keccak256("RULE_ENGINE_OPERATOR_ROLE");
}
