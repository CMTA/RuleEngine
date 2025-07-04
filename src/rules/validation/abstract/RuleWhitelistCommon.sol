// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol";
import "./RuleValidateTransfer.sol";

abstract contract RuleWhitelistCommon is
    RuleValidateTransfer,
    RuleWhitelistInvariantStorage
{
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
            _restrictionCode == CODE_ADDRESS_TO_NOT_WHITELISTED ||
            _restrictionCode == CODE_ADDRESS_SPENDER_NOT_WHITELISTED;
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
        } else if (_restrictionCode == CODE_ADDRESS_SPENDER_NOT_WHITELISTED) {
            return TEXT_ADDRESS_SPENDER_NOT_WHITELISTED;
        } else {
            return TEXT_CODE_NOT_FOUND;
        }
    }
}
