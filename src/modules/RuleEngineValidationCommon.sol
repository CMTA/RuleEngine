// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "../interfaces/IRuleEngineValidation.sol";
import "../interfaces/IRuleValidation.sol";
import "OZ/utils/structs/EnumerableSet.sol";
import "./RuleEngineInvariantStorage.sol";
/**
 * @title Implementation of a ruleEngine defined by the CMTAT
 */
abstract contract RuleEngineValidationCommon is
    AccessControl,
    IRuleEngineValidationCommon,
    RuleEngineInvariantStorage
{
    // Add the library methods
    using EnumerableSet for EnumerableSet.AddressSet;

    // Declare a set state variable
    EnumerableSet.AddressSet internal _rulesValidation;
    /// @dev Array of rules
    //address[] internal _rulesValidation;


     function _checkRuleValidation(address rule_) internal virtual{
         if (rule_ == address(0x0)) {
                revert RuleEngine_RuleAddressZeroNotAllowed();
            }
            if (_rulesValidation.contains(rule_)) {
                revert RuleEngine_RuleAlreadyExists();
            }
    }

    /*//////////////////////////////////////////////////////////////
                           PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Set all the rules, will overwrite all the previous rules. \n
     * Revert if one rule is a zero address or if the rule is already present
     * @dev take address[] instead of IRuleEngineValidation[] since it is not possible to cast IRuleEngineValidation[] -> address[]
     *
     */
    function setRulesValidation(
        address[] calldata rules_
    ) public virtual override onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        if (rules_.length == 0) {
            revert RuleEngine_ArrayIsEmpty();
        }
        uint256 rulesLength = _rulesValidation.length();
        if ( rulesLength > 0) {
            _clearRulesValidation();
        }
        for(uint256 i = 0; i < rules_.length; ++i){
            _checkRuleValidation(address(rules_[i]));
            _rulesValidation.add(address(rules_[i]));
            emit AddRule(rules_[i]);
        }
    }

    function rulesValidationIsPresent(IRuleValidation rule_) public view virtual returns (bool){
        return _rulesValidation.contains(address(rule_));
    }

    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function clearRulesValidation() public virtual  onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        _clearRulesValidation();
    }

    /**
     * @notice Add a rule to the array of rules
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function addRuleValidation(
        IRuleValidation rule_
    ) public virtual  onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
         _checkRuleValidation(address(rule_));
        _rulesValidation.add(address(rule_));
        emit AddRule(address(rule_));
    }

    /**
     * @notice Remove a rule from the array of rules
     * Revert if the rule found at the specified index does not match the rule in argument
     * @param rule_ address of the target rule
     * @dev To reduce the array size, the last rule is moved to the location occupied
     * by the rule to remove
     *
     *
     */
    function removeRuleValidation(
        IRuleValidation rule_
    ) public virtual  onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
         require(rulesValidationIsPresent(rule_), RuleEngine_RuleDoNotMatch());
        _removeRuleValidation(address(rule_));
    }

    /**
     * @return The number of rules inside the array
     */
    function rulesCountValidation() public view virtual override returns (uint256) {
        return _rulesValidation.length();
    }



    /**
     * @notice Get the index of a rule inside the list
     * @return index if the rule is found, _rulesValidation.length otherwise
     */
   /* function getRuleIndexValidation(
        IRuleValidation rule_
    ) public view virtual returns (uint256 index) {
        return RuleInternal._getRuleIndex(_rulesValidation, address(rule_));
    }*/

    /**
     * @notice Get the rule at the position specified by ruleId
     * @param ruleId index of the rule
     * @return a rule address
     */
    function ruleValidation(
        uint256 ruleId
    ) public view virtual override returns (address) {
        return _rulesValidation.at(ruleId);
    }


    /**
     * @notice Get all the rules
     * @return An array of rules
     */
    function rulesValidation()
        public
        view
        virtual 
        override
        returns (address[] memory)
    {
        return _rulesValidation.values();
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function _clearRulesValidation() internal virtual  {
        emit ClearRules();
        // O(N)
       _rulesValidation.clear();
    }

    /**
     * @notice Remove a rule from the array of rules
     * Revert if the rule found at the specified index does not match the rule in argument
     * @param rule_ address of the target rule
     * @dev To reduce the array size, the last rule is moved to the location occupied
     * by the rule to remove
     *
     *
     */
    function _removeRuleValidation(address rule_) internal virtual {
        _rulesValidation.remove(rule_);
        emit RemoveRule(address(rule_));
    }
}
