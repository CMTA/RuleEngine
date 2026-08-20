// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {IERC1404} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";

/**
 * @title ERC1404InterfaceId
 * @dev ERC-165 interface IDs for ERC-1404 interfaces.
 * Computed from the interface itself rather than hardcoded.
 * The ID of the ERC-1404 *extension* is provided by CMTAT in `ERC1404ExtendInterfaceId`.
 */
library ERC1404InterfaceId {
    /**
     * @notice ERC-165 interface ID of the ERC-1404 restriction interface.
     * @dev `IERC1404` inherits nothing, so its own ID is already the flattened one:
     * detectTransferRestriction and messageForTransferRestriction. Equals `0xab84a5c8`.
     */
    bytes4 public constant IERC1404_INTERFACE_ID = type(IERC1404).interfaceId;
}
