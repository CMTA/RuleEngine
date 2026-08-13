// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {RuleAddressList} from "./abstract/RuleAddressList/RuleAddressList.sol";
import {RuleWhitelistCommon} from "./abstract/RuleWhitelistCommon.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {RuleInterfaceId} from "../../../modules/library/RuleInterfaceId.sol";

//import {ERC165, IERC165} from "@OZ/utils/introspection/ERC165.sol";
/**
 * @title a whitelist manager
 */
contract RuleWhitelistMock is RuleAddressList, RuleWhitelistCommon {
    /**
     * @notice ERC-165 interface ID of the CMTAT RuleEngine interface.
     */
    bytes4 private constant RULE_ENGINE_INTERFACE_ID = 0x20c49ce7;
    /**
     * @notice ERC-165 interface ID of the extended ERC-1404 interface.
     */
    bytes4 private constant ERC1404EXTEND_INTERFACE_ID = 0x78a8de7d;
    error RuleWhitelist_InvalidTransfer(address from, address to, uint256 value, uint8 code);

    /**
     * @notice Deploys the whitelist rule.
     * @param admin Address of the contract (Access Control)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     */
    constructor(address admin, address forwarderIrrevocable) RuleAddressList(admin, forwarderIrrevocable) {}

    /**
     * @notice Validates a transfer and reverts when the whitelist forbids it.
     * @param from the origin address
     * @param to the destination address
     * @param value the amount to transfer
     */
    function transferred(address from, address to, uint256 value) public {
        uint8 code = detectTransferRestriction(from, to, value);
        require(code == uint8(REJECTED_CODE_BASE.TRANSFER_OK), RuleWhitelist_InvalidTransfer(from, to, value, code));
    }

    /**
     * @notice Validates a spender-initiated transfer and reverts when the whitelist forbids it.
     * @param spender the spender address (transferFrom)
     * @param from the origin address
     * @param to the destination address
     * @param value the amount to transfer
     */
    function transferred(address spender, address from, address to, uint256 value) public {
        uint8 code = detectTransferRestrictionFrom(spender, from, to, value);
        require(code == uint8(REJECTED_CODE_BASE.TRANSFER_OK), RuleWhitelist_InvalidTransfer(from, to, value, code));
    }

    /**
     * @notice ERC-165 interface detection.
     * @param interfaceId The interface identifier to check.
     * @return True if the interface is supported, false otherwise.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, IERC165) returns (bool) {
        return interfaceId == RULE_ENGINE_INTERFACE_ID || interfaceId == ERC1404EXTEND_INTERFACE_ID
            || interfaceId == RuleInterfaceId.IRULE_INTERFACE_ID || AccessControl.supportsInterface(interfaceId);
    }

    /**
     * @notice Validate a transfer
     * @param _from the origin address
     * @param _to the destination address
     * @param _amount to transfer
     * @return isValid => true if the transfer is valid, false otherwise
     *
     */
    function canTransfer(address _from, address _to, uint256 _amount) public view override returns (bool isValid) {
        return detectTransferRestriction(_from, _to, _amount) == uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Validate a spender-initiated transfer
     * @param spender the spender address (transferFrom)
     * @param from the origin address
     * @param to the destination address
     * @param value the amount to transfer
     * @return true if the transfer is valid, false otherwise
     */
    function canTransferFrom(address spender, address from, address to, uint256 value)
        public
        view
        virtual
        override
        returns (bool)
    {
        return detectTransferRestrictionFrom(spender, from, to, value) == uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Check if an addres is in the whitelist or not
     * @param from the origin address
     * @param to the destination address
     * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
     *
     */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 /*value */
    )
        public
        view
        override
        returns (uint8)
    {
        if (!addressIsListed(from)) {
            return CODE_ADDRESS_FROM_NOT_WHITELISTED;
        } else if (!addressIsListed(to)) {
            return CODE_ADDRESS_TO_NOT_WHITELISTED;
        } else {
            return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    /**
     * @notice Check if a spender-initiated transfer is valid
     * @param spender the spender address (transferFrom)
     * @param from the origin address
     * @param to the destination address
     * @param value the amount to transfer
     * @return The restriction code or REJECTED_CODE_BASE.TRANSFER_OK
     */
    function detectTransferRestrictionFrom(address spender, address from, address to, uint256 value)
        public
        view
        override
        returns (uint8)
    {
        // Mint (from == address(0)) and burn (to == address(0)) are exempt from spender check
        if (from != address(0) && to != address(0) && !addressIsListed(spender)) {
            return CODE_ADDRESS_SPENDER_NOT_WHITELISTED;
        } else {
            return detectTransferRestriction(from, to, value);
        }
    }
}
