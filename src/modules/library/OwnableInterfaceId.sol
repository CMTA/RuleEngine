// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title OwnableInterfaceId
 * @dev ERC-165 interface IDs used by ownable RuleEngine variants.
 */
library OwnableInterfaceId {
    /**
     * @notice ERC-165 interface ID of ERC-173 (contract ownership).
     */
    bytes4 public constant IERC173_INTERFACE_ID = 0x7f5828d0;
}
