// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./abstract/RuleAddressList/RuleAddressList.sol";
import "./abstract/RuleWhitelistCommon.sol";
import {ERC165, IERC165, AccessControl} from "OZ/access/AccessControl.sol";
import {RuleInterfaceId} from "../../../modules/library/RuleInterfaceId.sol";
//import {ERC165, IERC165} from "@OZ/utils/introspection/ERC165.sol";
/**
 * @title a whitelist manager
 */
contract RuleWhitelist is RuleAddressList, RuleWhitelistCommon {
    bytes4 private RULE_ENGINE_INTERFACE_ID = 0x20c49ce7;
    bytes4 private ERC1404EXTEND_INTERFACE_ID = 0x78a8de7d;
    error RuleWhitelist_InvalidTransfer(
        address from,
        address to,
        uint256 value,
        uint8 code
    );

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, IERC165) returns (bool) {
        return interfaceId == RULE_ENGINE_INTERFACE_ID || interfaceId == ERC1404EXTEND_INTERFACE_ID || interfaceId == RuleInterfaceId.IRULE_INTERFACE_ID || super.supportsInterface(interfaceId);
    }

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
