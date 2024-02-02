// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./RuleInternal.sol";
import "../interfaces/IRuleEngineOperation.sol";
import "../interfaces/IRuleOperation.sol";
import "../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
/**
@title Implementation of a ruleEngine defined by the CMTAT
*/
abstract contract RuleEngineOperation is AccessControl, RuleInternal, IRuleEngineOperation {
    /// @dev Array of rules
    address[] internal _rulesOperation;

    /**
     * @notice Set all the rules, will overwrite all the previous rules. \n
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function setRulesOperation(
        address[] calldata rules_
    ) public onlyRole(RULE_ENGINE_ROLE) {
        if(rules_.length == 0){
            revert RuleEngine_ArrayIsEmpty();
        }
        for (uint256 i = 0; i < rules_.length; ) {
            if( address(rules_[i]) == address(0x0)){
                revert  RuleEngine_RuleAddressZeroNotAllowed();
            }
            if(_ruleIsPresent[rules_[i]]){
                revert RuleEngine_RuleAlreadyExists();
            }
            _ruleIsPresent[rules_[i]] = true;
            emit AddRule(rules_[i]);
            unchecked {
                ++i;
            }
        }
        _rulesOperation = rules_;
    }

    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function clearRulesOperation() public onlyRole(RULE_ENGINE_ROLE) {
        emit ClearRules(_rulesOperation);
        _rulesOperation  = new address[](0);
    }

    /**
     * @notice Add a rule to the array of rules
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function addRuleOperation(address rule_) public onlyRole(RULE_ENGINE_ROLE) {
       RuleInternal.addRule( _rulesOperation, rule_);
        emit AddRule(rule_);
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
    ) public onlyRole(RULE_ENGINE_ROLE) {
        RuleInternal.removeRule(_rulesOperation, address(rule_), index); 
        emit RemoveRule(address(rule_));
    }

    /**
    * @return The number of rules inside the array
    */
    function rulesOperationCount() external view override returns (uint256) {
        return _rulesOperation.length;
    }

    /**
    * @notice Get the index of a rule inside the list
    * @return index if the rule is found, _rulesOperation.length otherwise
    */
    function getRuleOperationIndex(address rule_) external view returns (uint256 index) {
        return RuleInternal.getRuleIndex(_rulesOperation, rule_);
    }

    /**
    * @notice Get the rule at the position specified by ruleId
    * @param ruleId index of the rule
    * @return a rule address
    */
    function ruleOperation(uint256 ruleId) external view override returns (address) {
        return _rulesOperation[ruleId];
    }

    /**
    * @notice Get all the rules
    * @return An array of rules
    */
    function rulesOperation() external view override returns (address[] memory) {
        return _rulesOperation;
    }

    
    /** 
    * @notice Go through all the rule to know if a restriction exists on the transfer
    * @param _from the origin address
    * @param _to the destination address
    * @param _amount to transfer
    **/
    function _operateOnTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        uint256 rulesLength = _rulesOperation.length;
        for (uint256 i = 0; i < rulesLength; ) {
            IRuleOperation(_rulesOperation[i]).operateOnTransfer(
                _from,
                _to,
                _amount
            );
            unchecked {
                ++i;
            }
        }
    }
}