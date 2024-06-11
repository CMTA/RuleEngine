// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "./RuleInternal.sol";
import "../interfaces/IRuleEngineValidation.sol";
import "../interfaces/IRuleValidation.sol";

/**
 * @title Implementation of a ruleEngine defined by the CMTAT
 */
abstract contract RuleEngineValidationCommon is
    AccessControl,
    RuleInternal,
    IRuleEngineValidationCommon
{
    /// @dev Array of rules
    address[] internal _rulesValidation;

    /**
     * @notice Set all the rules, will overwrite all the previous rules. \n
     * Revert if one rule is a zero address or if the rule is already present
     * @dev take address[] instead of IRuleEngineValidation[] since it is not possible to cast IRuleEngineValidation[] -> address[]
     *
     */
    function setRulesValidation(
        address[] calldata rules_
    ) public override onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        if (_rulesValidation.length > 0) {
            _clearRulesValidation();
        }
        _setRules(rules_);
        _rulesValidation = rules_;
    }

    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function clearRulesValidation() public onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        _clearRulesValidation();
    }

    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function _clearRulesValidation() internal {
        uint256 index;
        // we remove the last element first since it is more optimized.
        for (uint256 i = _rulesValidation.length; i > 0; --i) {
            unchecked {
                // don't underflow since i > 0
                index = i - 1;
            }
            _removeRuleValidation(_rulesValidation[index], index);
        }
        emit ClearRules(_rulesValidation);
    }

    /**
     * @notice Add a rule to the array of rules
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function addRuleValidation(
        IRuleValidation rule_
    ) public onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        RuleInternal._addRule(_rulesValidation, address(rule_));
        emit AddRule(address(rule_));
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
    function removeRuleValidation(
        IRuleValidation rule_,
        uint256 index
    ) public onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        _removeRuleValidation(address(rule_), index);
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
    function _removeRuleValidation(address rule_, uint256 index) internal {
        RuleInternal._removeRule(_rulesValidation, rule_, index);
        emit RemoveRule(address(rule_));
    }

    /**
     * @return The number of rules inside the array
     */
    function rulesCountValidation() external view override returns (uint256) {
        return _rulesValidation.length;
    }

    /**
     * @notice Get the index of a rule inside the list
     * @return index if the rule is found, _rulesValidation.length otherwise
     */
    function getRuleIndexValidation(
        IRuleValidation rule_
    ) external view returns (uint256 index) {
        return RuleInternal.getRuleIndex(_rulesValidation, address(rule_));
    }

    /**
     * @notice Get the rule at the position specified by ruleId
     * @param ruleId index of the rule
     * @return a rule address
     */
    function ruleValidation(
        uint256 ruleId
    ) external view override returns (address) {
        return _rulesValidation[ruleId];
    }

    /**
     * @notice Get all the rules
     * @return An array of rules
     */
    function rulesValidation()
        external
        view
        override
        returns (address[] memory)
    {
        return _rulesValidation;
    }
}
