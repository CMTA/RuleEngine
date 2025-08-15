// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol";
import {IRule} from "../../../../interfaces/IRule.sol";

abstract contract RuleWhitelistCommon is RuleWhitelistInvariantStorage, IRule {
    /**
     * @notice To know if the restriction code is valid for this rule or not
     * @param restrictionCode The target restriction code
     * @return true if the restriction code is known, false otherwise
     **/
    function canReturnTransferRestrictionCode(
        uint8 restrictionCode
    ) external pure override returns (bool) {
        return
            restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED ||
            restrictionCode == CODE_ADDRESS_TO_NOT_WHITELISTED ||
            restrictionCode == CODE_ADDRESS_SPENDER_NOT_WHITELISTED;
    }

    /**
     * @notice Return the corresponding message
     * @param restrictionCode The target restriction code
     * @return true if the transfer is valid, false otherwise
     **/
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) external pure override returns (string memory) {
        if (restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED) {
            return TEXT_ADDRESS_FROM_NOT_WHITELISTED;
        } else if (restrictionCode == CODE_ADDRESS_TO_NOT_WHITELISTED) {
            return TEXT_ADDRESS_TO_NOT_WHITELISTED;
        } else if (restrictionCode == CODE_ADDRESS_SPENDER_NOT_WHITELISTED) {
            return TEXT_ADDRESS_SPENDER_NOT_WHITELISTED;
        } else {
            return TEXT_CODE_NOT_FOUND;
        }
    }
}
