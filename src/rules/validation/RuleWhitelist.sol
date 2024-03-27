// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../interfaces/IRuleEngineValidation.sol";
import "../../interfaces/IRuleValidation.sol";
import "./abstract/RuleAddressList/RuleWhitelistInvariantStorage.sol";
import "./abstract/RuleAddressList/RuleAddressList.sol";
/**
@title a whitelist manager
*/

contract RuleWhitelist is IRuleValidation, RuleAddressList, RuleWhitelistInvariantStorage {
    /**
    * @param admin Address of the contract (Access Control)
    * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
    */
    constructor(
        address admin,
        address forwarderIrrevocable
    )  RuleAddressList(admin, forwarderIrrevocable) {
    }

    /** 
    * @notice Validate a transfer
    * @param _from the origin address
    * @param _to the destination address
    * @param _amount to transfer
    * @return isValid => true if the transfer is valid, false otherwise
    **/
    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool isValid) {
        return
            detectTransferRestriction(_from, _to, _amount) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /** 
    * @notice Check if an addres is in the whitelist or not
    * @param _from the origin address
    * @param _to the destination address
    * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
    **/
    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 /*_amount */
    ) public view override returns (uint8) {
        if (!addressIsListed(_from)) {
            return CODE_ADDRESS_FROM_NOT_WHITELISTED;
        } else if (! addressIsListed(_to)) {
            return CODE_ADDRESS_TO_NOT_WHITELISTED;
        } else {
            return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    /** 
    * @notice To know if the restriction code is valid for this rule or not.
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
