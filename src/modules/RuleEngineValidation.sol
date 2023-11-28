// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./RuleInternal.sol";
import "../../lib/CMTAT/contracts/mocks/RuleEngine/interfaces/IRule.sol";
/**
@title Implementation of a ruleEngine defined by the CMTAT
*/
contract RuleEngineValidation is AccessControl, RuleInternal {
    /// @dev Array of rules
    address[] internal _rules;
    /// @notice Generate when a rule is added
    event AddRule(address indexed rule);
    /// @notice Generate when a rule is removed
    event RemoveRule(address indexed rule);
    /// @notice Generate when all the rules are cleared
    event ClearRules(address[] rulesRemoved);


    /**
     * @notice Set all the rules, will overwrite all the previous rules. \n
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function setRules(
        address[] calldata rules_
    ) external override onlyRole(RULE_ENGINE_ROLE) {
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
        _rules = rules_;
    }

    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function clearRules() public onlyRole(RULE_ENGINE_ROLE) {
        emit ClearRules(_rules);
        _rules = new address[](0);
    }

    /**
     * @notice Add a rule to the array of rules
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function addRule(address rule_) public onlyRole(RULE_ENGINE_ROLE) {
        if( address(rule_) == address(0x0))
        {
            revert RuleEngine_RuleAddressZeroNotAllowed();
        }
        if( _ruleIsPresent[rule_])
        {
            revert RuleEngine_RuleAlreadyExists();
        }
        _rules.push(rule_);
        _ruleIsPresent[rule_] = true;
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
    function removeRule(
        address rule_,
        uint256 index
    ) public onlyRole(RULE_ENGINE_ROLE) {
        RuleInternal.removeRule(_rules, rule_); 
        emit RemoveRule(rule_);
    }

    /**
    * @return The number of rules inside the array
    */
    function rulesCount() external view override returns (uint256) {
        return _rules.length;
    }

    /**
    * @notice Get the index of a rule inside the list
    * @return index if the rule is found, _rules.length otherwise
    */
    function getRuleIndex(address rule_) external view returns (uint256 index) {
        return RuleInternal.getRuleIndex(_rules, rule_);
    }

    /**
    * @notice Get the rule at the position specified by ruleId
    * @param ruleId index of the rule
    * @return a rule address
    */
    function rule(uint256 ruleId) external view override returns (address) {
        return _rules[ruleId];
    }

    /**
    * @notice Get all the rules
    * @return An array of rules
    */
    function rules() external view override returns (address[] memory) {
        return _rules;
    }

    /** 
    * @notice Go through all the rule to know if a restriction exists on the transfer
    * @param _from the origin address
    * @param _to the destination address
    * @param _amount to transfer
    * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
    **/
    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (uint8) {
        uint256 rulesLength = _rules.length;
        for (uint256 i = 0; i < rulesLength; ) {
            uint8 restriction = IRule(_rules[i]).detectTransferRestriction(
                _from,
                _to,
                _amount
            );
            if (restriction > 0) {
                return restriction;
            }
            unchecked {
                ++i;
            }
        }
        //return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        return uint8(0);
    }

    /** 
    * @notice Validate a transfer
    * @param _from the origin address
    * @param _to the destination address
    * @param _amount to transfer
    * @return True if the transfer is valid, false otherwise
    **/
    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool) {
        //return detectTransferRestriction(_from, _to, _amount) == uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        return detectTransferRestriction(_from, _to, _amount) == uint8(0);
    }

    /** 
    * @notice Return the message corresponding to the code
    * @param _restrictionCode The target restriction code
    * @return True if the transfer is valid, false otherwise
    **/
    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external view override returns (string memory) {
        uint256 rulesLength = _rules.length;
        for (uint256 i = 0; i < rulesLength; ) {
            if (IRule(_rules[i]).canReturnTransferRestrictionCode(_restrictionCode)) {
                return
                    IRule(_rules[i]).messageForTransferRestriction(_restrictionCode);
            }
            unchecked {
                ++i;
            }
        }
        return "Unknown restriction code";
    }
}