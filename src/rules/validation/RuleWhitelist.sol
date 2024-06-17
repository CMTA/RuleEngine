// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./abstract/RuleAddressList/RuleAddressList.sol";
import "./abstract/RuleWhitelistCommon.sol";
/**
 * @title a whitelist manager
 */

contract RuleWhitelist is RuleAddressList, RuleWhitelistCommon
{
    /**
     * @param admin Address of the contract (Access Control)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     */
    constructor(
        address admin,
        address forwarderIrrevocable
    ) RuleAddressList(admin, forwarderIrrevocable) {}

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
        } else if (!addressIsListed(_to)) {
            return CODE_ADDRESS_TO_NOT_WHITELISTED;
        } else {
            return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }
}
