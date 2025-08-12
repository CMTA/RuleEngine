// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {EnumerableSet} from "OZ/utils/structs/EnumerableSet.sol";
import {AccessControl}  from "OZ/access/AccessControl.sol";
/* ==== Interface and other library === */
import {IRuleEngineOperation} from "../interfaces/IRuleEngineOperation.sol";
import {IRuleOperation} from "../interfaces/IRuleOperation.sol";
import {RuleEngineInvariantStorageCommon} from "./library/RuleEngineInvariantStorageCommon.sol";
/**
 * @title RuleEngine - Operation part
 */
abstract contract RuleEngineOperation is
    AccessControl,
    RuleEngineInvariantStorageCommon,
    IRuleEngineOperation
{
    /* ==== Type declaration === */
    using EnumerableSet for EnumerableSet.AddressSet;

    /* ==== State Variables === */
    /// @dev Array of rules
    EnumerableSet.AddressSet internal _rulesOperation;

    /* ============ Events ============ */
    /// @notice Generate when a rule is added
    event AddRuleOperation(IRuleOperation indexed rule);
    /// @notice Generate when a rule is removed
    event RemoveRuleOperation(IRuleOperation indexed rule);
    /// @notice Generate when all the rules are cleared
    event ClearRulesOperation();
    


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State functions ============ */

    /**
    * @inheritdoc IRuleEngineOperation
    */
    function setRulesOperation(
        IRuleOperation[] calldata rules_
    ) public virtual override(IRuleEngineOperation) onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        if (rules_.length == 0) {
            revert RuleEngine_ArrayIsEmpty();
        }
        if (_rulesOperation.length() > 0) {
            _clearRulesOperation();
        }
        for(uint256 i = 0; i < rules_.length; ++i){
           _checkRule(address(rules_[i]));
            _rulesOperation.add(address(rules_[i]));
            emit AddRuleOperation(rules_[i]);
        }
       
    }

    /**
    * @inheritdoc IRuleEngineOperation
    */  
    function clearRulesOperation() public virtual override(IRuleEngineOperation) onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        _clearRulesOperation();
    }

    /**
    * @inheritdoc IRuleEngineOperation
    */
    function addRuleOperation(
        IRuleOperation rule_
    ) public virtual override(IRuleEngineOperation) onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        _checkRule(address(rule_));
        _rulesOperation.add(address(rule_));
        emit AddRuleOperation(rule_);
    }

   /**
    * @inheritdoc IRuleEngineOperation
    */
    function removeRuleOperation(
        IRuleOperation rule_
    ) public virtual override(IRuleEngineOperation) onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        require(_rulesOperation.contains(address(rule_)), RuleEngine_RuleDoNotMatch());
        _removeRuleOperation(rule_);
    }

    /* ============ View functions ============ */

   /**
    * @inheritdoc IRuleEngineOperation
    */
    function rulesCountOperation() public view virtual override(IRuleEngineOperation) returns (uint256) {
        return _rulesOperation.length();
    }

    /**
    * @inheritdoc IRuleEngineOperation
    */
    function ruleOperationIsPresent(IRuleOperation rule_) public view virtual override(IRuleEngineOperation) returns (bool){
        return _rulesOperation.contains(address(rule_));
    }


    /**
    * @inheritdoc IRuleEngineOperation
    */
    function ruleOperation(
        uint256 ruleId
    ) public view virtual override(IRuleEngineOperation) returns (address) {
        return _rulesOperation.at(ruleId);
    }

    /**
    * @inheritdoc IRuleEngineOperation
    */
    function rulesOperation()
        public
        view
        virtual
        override(IRuleEngineOperation)
        returns (address[] memory)
    {
        return _rulesOperation.values();
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function _clearRulesOperation() internal virtual {
        // we remove the last element first since it is more optimized.

        emit ClearRulesOperation();
        _rulesOperation.clear();
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
        uint256 rulesLength = _rulesOperation.length();
        for (uint256 i = 0; i < rulesLength; ++i) {
            IRuleOperation(_rulesOperation.at(i)).transferred(
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
     * @dev To reduce the array size, the last rule is moved to the location occupied
     * by the rule to remove
     *
     *
     */
    function _removeRuleOperation(IRuleOperation rule_) internal virtual {
        _rulesOperation.remove(address(rule_));
        emit RemoveRuleOperation(rule_);
    }

    function _checkRule(address rule_) internal{
          if (rule_ == address(0x0)) {
                revert RuleEngine_RuleAddressZeroNotAllowed();
            }
        if (_rulesOperation.contains(rule_)) {
            revert RuleEngine_RuleAlreadyExists();
        }
    }
}
