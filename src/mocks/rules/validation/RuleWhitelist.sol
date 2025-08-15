// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./abstract/RuleAddressList/RuleAddressList.sol";
import "./abstract/RuleWhitelistCommon.sol";

/**
 * @title a whitelist manager
 */
contract RuleWhitelist is RuleAddressList, RuleWhitelistCommon {
    error RuleWhitelist_InvalidTransfer(
        address from,
        address to,
        uint256 value,
        uint8 code
    );

    /**
     * @param admin Address of the contract (Access Control)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     */
    constructor(
        address admin,
        address forwarderIrrevocable
    ) RuleAddressList(admin, forwarderIrrevocable) {}

    /**
     * @notice Validate a transfer
     * @param _from the origin address
     * @param _to the destination address
     * @param _amount to transfer
     * @return isValid => true if the transfer is valid, false otherwise
     **/
    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool isValid) {
        return
            detectTransferRestriction(_from, _to, _amount) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override returns (bool) {
        return
            detectTransferRestrictionFrom(spender, from, to, value) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Check if an addres is in the whitelist or not
     * @param from the origin address
     * @param to the destination address
     * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
     **/
    function detectTransferRestriction(
        address from,
        address to,
        uint256 /*value */
    ) public view override returns (uint8) {
        if (!addressIsListed(from)) {
            return CODE_ADDRESS_FROM_NOT_WHITELISTED;
        } else if (!addressIsListed(to)) {
            return CODE_ADDRESS_TO_NOT_WHITELISTED;
        } else {
            return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    function detectTransferRestrictionFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view override returns (uint8) {
        if (!addressIsListed(spender)) {
            return CODE_ADDRESS_SPENDER_NOT_WHITELISTED;
        } else {
            return detectTransferRestriction(from, to, value);
        }
    }

    function transferred(address from, address to, uint256 value) public view {
        uint8 code = detectTransferRestriction(from, to, value);
        require(
            code == uint8(REJECTED_CODE_BASE.TRANSFER_OK),
            RuleWhitelist_InvalidTransfer(from, to, value, code)
        );
    }

    function transferred(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view {
        uint8 code = detectTransferRestrictionFrom(spender, from, to, value);
        require(
            code == uint8(REJECTED_CODE_BASE.TRANSFER_OK),
            RuleWhitelist_InvalidTransfer(from, to, value, code)
        );
    }
}
