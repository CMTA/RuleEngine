// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import "./RuleEngineInvariantStorage.sol";

/**
 * @title Implementation of a ruleEngine defined by the CMTAT
 */
abstract contract RuleInternal is RuleEngineInvariantStorage {
    /// @dev Indicate if a rule already exists
    // Can be shared betwen RuleOperation and RuleValidation since it is a mapping
    mapping(address => bool) _ruleIsPresent;

    /**
     * @notice Set all the rules, will overwrite all the previous rules. \n
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function _setRules(address[] calldata rules_) internal {
        if (rules_.length == 0) {
            revert RuleEngine_ArrayIsEmpty();
        }
        for (uint256 i = 0; i < rules_.length; ) {
            if (address(rules_[i]) == address(0x0)) {
                revert RuleEngine_RuleAddressZeroNotAllowed();
            }
            if (_ruleIsPresent[rules_[i]]) {
                revert RuleEngine_RuleAlreadyExists();
            }
            _ruleIsPresent[rules_[i]] = true;
            emit AddRule(rules_[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Add a rule to the array of rules
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function _addRule(address[] storage _rules, address rule_) internal {
        if (address(rule_) == address(0x0)) {
            revert RuleEngine_RuleAddressZeroNotAllowed();
        }
        if (_ruleIsPresent[rule_]) {
            revert RuleEngine_RuleAlreadyExists();
        }
        _rules.push(rule_);
        _ruleIsPresent[rule_] = true;
    }

    /**
     * @notice Remove a rule from the array of rules
     * Revert if the rule found at the specified index does not match the rule in argument
     * @param rule_ address of the target rule
     * @param index the position inside the array of rule
     * @dev To reduce the array size, the last rule is moved to the location occupied
     * by the rule to remove
     *
     *
     */
    function _removeRule(
        address[] storage _rules,
        address rule_,
        uint256 index
    ) internal {
        if (_rules[index] != rule_) {
            revert RuleEngine_RuleDoNotMatch();
        }
        if (index != _rules.length - 1) {
            _rules[index] = _rules[_rules.length - 1];
        }
        _rules.pop();
        _ruleIsPresent[rule_] = false;
        emit RemoveRule(rule_);
    }

    /**
     * @notice Get the index of a rule inside the list
     * @return index if the rule is found, _rules.length otherwise
     */
    function getRuleIndex(
        address[] storage _rules,
        address rule_
    ) internal view returns (uint256 index) {
        uint256 rulesLength = _rules.length;
        for (index = 0; index < rulesLength; ) {
            if (_rules[index] == rule_) {
                return index;
            }
            unchecked {
                ++index;
            }
        }
        return _rules.length;
    }
}
