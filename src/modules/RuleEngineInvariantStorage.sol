// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract RuleEngineInvariantStorage {
    error RuleEngine_RuleAddressZeroNotAllowed();
    error RuleEngine_RuleAlreadyExists();
    error RuleEngine_RuleDoNotMatch();
    error RuleEngine_AdminWithAddressZeroNotAllowed();
    error RuleEngine_ArrayIsEmpty();

    /// @notice Generate when a rule is added
    event AddRule(address indexed rule);
    /// @notice Generate when a rule is removed
    event RemoveRule(address indexed rule);
    /// @notice Generate when all the rules are cleared
    event ClearRules(address[] rulesRemoved);

    /// @notice Role to manage the ruleEngine
    bytes32 public constant RULE_ENGINE_OPERATOR_ROLE =
        keccak256("RULE_ENGINE_OPERATOR_ROLE");

    /// @notice token contract
    bytes32 public constant TOKEN_CONTRACT_ROLE =
        keccak256("TOKEN_CONTRACT_ROLE");
}
