// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @dev Test-only subset matching IERC1404 for interfaceId checks.
 */
interface IERC1404Subset {
    function detectTransferRestriction(address from, address to, uint256 value) external view returns (uint8);
    function messageForTransferRestriction(uint8 restrictionCode) external view returns (string memory);
}
