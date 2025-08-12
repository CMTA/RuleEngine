// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

// OpenZeppelin
import {AccessControl} from "OZ/access/AccessControl.sol";
import "OZ/utils/structs/EnumerableSet.sol";
// Other
import {IRuleEngineValidation} from "../interfaces/IRuleEngineValidation.sol";
import {IRuleValidation} from "../interfaces/IRuleValidation.sol";
import {RuleEngineInvariantStorageCommon} from "./library/RuleEngineInvariantStorageCommon.sol";

abstract contract RuleEngineValidation is
    AccessControl,
    IRuleEngineValidation,
    RuleEngineInvariantStorageCommon
{
    // Add the library methods
    using EnumerableSet for EnumerableSet.AddressSet;

    // Declare a set state variable
    EnumerableSet.AddressSet internal _rulesValidation;

     /// @notice Generate when a rule is added
    event AddRuleValidation(IRuleValidation indexed rule);
    /// @notice Generate when a rule is removed
    event RemoveRuleValidation(IRuleValidation indexed rule);
    /// @notice Generate when all the rules are cleared
    event ClearRulesValidation();

    /*//////////////////////////////////////////////////////////////
                           PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ State functions ============ */
    /**
     * @notice Set all the rules, will overwrite all the previous rules. \n
     * Revert if one rule is a zero address or if the rule is already present
     * @dev take address[] instead of IRuleEngineValidation[] since it is not possible to cast IRuleEngineValidation[] -> address[]
     *
     */
    function setRulesValidation(
        IRuleValidation[] calldata rules_
    ) public virtual override(IRuleEngineValidation) onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
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
            emit AddRuleValidation(rules_[i]);
        }
    }



    function clearRulesValidation() public virtual override(IRuleEngineValidation) onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        _clearRulesValidation();
    }


    function addRuleValidation(
        IRuleValidation rule_
    ) public virtual override(IRuleEngineValidation) onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
         _checkRuleValidation(address(rule_));
        _rulesValidation.add(address(rule_));
        emit AddRuleValidation(rule_);
    }


    function removeRuleValidation(
        IRuleValidation rule_
    ) public virtual override(IRuleEngineValidation)  onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
         require(rulesValidationIsPresent(rule_), RuleEngine_RuleDoNotMatch());
        _removeRuleValidation(rule_);
    }

    /* ============ View functions ============ */


    function rulesValidationIsPresent(IRuleValidation rule_) public view virtual override(IRuleEngineValidation) returns (bool){
        return _rulesValidation.contains(address(rule_));
    }


 
    function rulesCountValidation() public view virtual override(IRuleEngineValidation) returns (uint256) {
        return _rulesValidation.length();
    }

 
    function ruleValidation(
        uint256 ruleId
    ) public view virtual override(IRuleEngineValidation) returns (address) {
        return _rulesValidation.at(ruleId);
    }



    function rulesValidation()
        public
        view
        virtual 
        override(IRuleEngineValidation)
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
        emit ClearRulesValidation();
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
    function _removeRuleValidation(IRuleValidation rule_) internal virtual {
        _rulesValidation.remove(address(rule_));
        emit RemoveRuleValidation(rule_);
    }

    function _checkRuleValidation(address rule_) internal virtual{
         if (rule_ == address(0x0)) {
                revert RuleEngine_RuleAddressZeroNotAllowed();
            }
            if (_rulesValidation.contains(rule_)) {
                revert RuleEngine_RuleAlreadyExists();
            }
    }

}
