// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "../../interfaces/IRuleEngineValidation.sol";
import "../../modules/RuleEngineValidationCommon.sol";
import "../../interfaces/IRuleValidation.sol";
import "./abstract/RuleValidateTransfer.sol";
import "./abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol";
import "./abstract/RuleAddressList/RuleAddressList.sol";
/**
* @title Implementation of a ruleEngine defined by the CMTAT
*/
contract RuleWhitelistWrapper is RuleEngineValidationCommon, RuleValidateTransfer, RuleWhitelistInvariantStorage  {

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
        address[] memory targetAddress = new address[](2);
        bool[] memory isListed = new bool[](2);
        bool[] memory result = new bool[](2);
        targetAddress[0] = _from;
        targetAddress[1] = _to;
        uint256 rulesLength = _rulesValidation.length;
        // For each whitelist rule, we ask if from or to are in the whitelist
        for (uint256 i = 0; i < rulesLength; ++i ) {
            // External call
            isListed = RuleAddressList(_rulesValidation[i]).addressIsListedBatch(targetAddress);
            if(isListed[0] && !result[0]){
                // Update if from is in the list
                result[0] = true;
            }
            if(isListed[1] && !result[1]){
                // Update if to is in the list
                result[1] = true;
            }
        }
        if (!result[0]) {
            return CODE_ADDRESS_FROM_NOT_WHITELISTED;
        } else if (!result[1]) {
            return CODE_ADDRESS_TO_NOT_WHITELISTED;
        } else {
            return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

        /** 
    * @notice To know if the restriction code is valid for this rule or not
    * @param _restrictionCode The target restriction code
    * @return true if the restriction code is known, false otherwise
    **/
    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external pure override returns (bool) {
        return
            _restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED ||
            _restrictionCode == CODE_ADDRESS_TO_NOT_WHITELISTED;
    }

    /** 
    * @notice Return the corresponding message
    * @param _restrictionCode The target restriction code
    * @return true if the transfer is valid, false otherwise
    **/
    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external pure override returns (string memory) {
        if (_restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED) {
            return TEXT_ADDRESS_FROM_NOT_WHITELISTED;
        } else if (_restrictionCode == CODE_ADDRESS_TO_NOT_WHITELISTED) {
            return TEXT_ADDRESS_TO_NOT_WHITELISTED;
        } else {
            return TEXT_CODE_NOT_FOUND;
        }
    }
}