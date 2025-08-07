// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

// OpenZeppelin
import {EnumerableSet} from "OZ/utils/structs/EnumerableSet.sol";
import {AccessControl}  from "OZ/access/AccessControl.sol";
// Other
import {IRuleEngineOperation} from "../interfaces/IRuleEngineOperation.sol";
import {IRuleOperation} from "../interfaces/IRuleOperation.sol";
import {RuleEngineInvariantStorage} from "./RuleEngineInvariantStorage.sol";
/**
 * @title RuleEngine - Operation part
 */
abstract contract RuleEngineOperation is
    AccessControl,
    RuleEngineInvariantStorage,
    IRuleEngineOperation
{
       
    /// @dev Array of rules
    //address[] internal _rulesOperation;
    // Add the library methods
    using EnumerableSet for EnumerableSet.AddressSet;

    // Declare a set state variable
    EnumerableSet.AddressSet internal _rulesOperation;

    /* ============ State functions ============ */
    /**
     * @notice Set all the rules, will overwrite all the previous rules. \n
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function setRulesOperation(
        address[] calldata rules_
    ) public virtual onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        if (rules_.length == 0) {
            revert RuleEngine_ArrayIsEmpty();
        }
        if (_rulesOperation.length() > 0) {
            _clearRulesOperation();
        }
        for(uint256 i = 0; i < rules_.length; ++i){
           _checkRule(address(rules_[i]));
            _rulesOperation.add(address(rules_[i]));
            emit AddRule(rules_[i]);
        }
       
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
        _checkRule(address(rule_));
        _rulesOperation.add(address(rule_));
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
    function removeRuleOperation(
        IRuleOperation rule_
    ) public virtual onlyRole(RULE_ENGINE_OPERATOR_ROLE) {
        require(rulesOperationIsPresent(rule_), RuleEngine_RuleDoNotMatch());
        _removeRuleOperation(address(rule_));
    }

    /* ============ View functions ============ */
    /**
     * @return The number of rules inside the array
     */
    function rulesCountOperation() public view virtual override returns (uint256) {
        return _rulesOperation.length();
    }

    function rulesOperationIsPresent(IRuleOperation rule_) public view virtual returns (bool){
        return _rulesOperation.contains(address(rule_));
    }


    /**
     * @notice Get the rule at the position specified by ruleId
     * @param ruleId index of the rule
     * @return a rule address
     */
    function ruleOperation(
        uint256 ruleId
    ) public view virtual override returns (address) {
        return _rulesOperation.at(ruleId);
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

        emit ClearRules();
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
    function _removeRuleOperation(address rule_) internal virtual {
        _rulesOperation.remove(rule_);
        emit RemoveRule(address(rule_));
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
