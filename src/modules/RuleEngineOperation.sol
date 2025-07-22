// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./RuleInternal.sol";
import "../interfaces/IRuleEngineOperation.sol";
import "../interfaces/IRuleOperation.sol";
import "OZ/access/AccessControl.sol";

/**
 * @title Implementation of a ruleEngine defined by the CMTAT
 */
abstract contract RuleEngineOperation is
    AccessControl,
    RuleInternal,
    IRuleEngineOperation
{
    /// @dev Array of rules
    address[] internal _rulesOperation;

    /**
     * @notice Set all the rules, will overwrite all the previous rules. \n
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function setRulesOperation(
        address[] calldata rules_
    ) public virtual onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        if (_rulesOperation.length > 0) {
            _clearRulesOperation();
        }
        _setRules(rules_);
        _rulesOperation = rules_;
    }

    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function clearRulesOperation() public virtual onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        _clearRulesOperation();
    }

    
    /**
     * @notice Add a rule to the array of rules
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function addRuleOperation(
        IRuleOperation rule_
    ) public virtual onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        RuleInternal._addRule(_rulesOperation, address(rule_));
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
    function removeRuleOperation(
        IRuleOperation rule_,
        uint256 index
    ) public virtual onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        _removeRuleOperation(address(rule_), index);
    }

 
    /**
     * @return The number of rules inside the array
     */
    function rulesCountOperation() public view virtual override returns (uint256) {
        return _rulesOperation.length;
    }

    /**
     * @notice Get the index of a rule inside the list
     * @return index if the rule is found, _rulesOperation.length otherwise
     */
    function getRuleIndexOperation(
        IRuleOperation rule_
    ) public view virtual returns (uint256 index) {
        return RuleInternal._getRuleIndex(_rulesOperation, address(rule_));
    }

    /**
     * @notice Get the rule at the position specified by ruleId
     * @param ruleId index of the rule
     * @return a rule address
     */
    function ruleOperation(
        uint256 ruleId
    ) public view virtual override returns (address) {
        return _rulesOperation[ruleId];
    }

    /**
     * @notice Get all the rules
     * @return An array of rules
     */
    function rulesOperation()
        public
        view
        virtual
        override
        returns (address[] memory)
    {
        return _rulesOperation;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function _clearRulesOperation() internal virtual {
        uint256 index;
        // we remove the last element first since it is more optimized.
        for (uint256 i = _rulesOperation.length; i > 0; --i) {
            unchecked {
                // don't underflow since i > 0
                index = i - 1;
            }
            _removeRuleOperation(_rulesOperation[index], index);
        }
        emit ClearRules(_rulesOperation);
    }


    /**
     * @notice Go through all the rule to know if a restriction exists on the transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     **/
    function _transferred(
        address from,
        address to,
        uint256 value
    ) internal virtual{
        uint256 rulesLength = _rulesOperation.length;
        for (uint256 i = 0; i < rulesLength; ++i) {
            IRuleOperation(_rulesOperation[i]).transferred(
                from,
                to,
                value
            );
        }
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
    function _removeRuleOperation(address rule_, uint256 index) internal virtual {
        RuleInternal._removeRule(_rulesOperation, rule_, index);
        emit RemoveRule(address(rule_));
    }
}
