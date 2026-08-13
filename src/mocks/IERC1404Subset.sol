// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @dev Test-only subset matching IERC1404 for interfaceId checks.
 */
interface IERC1404Subset {
    /**
     * @notice Returns the restriction code applying to a transfer.
     * @param from The origin address.
     * @param to The destination address.
     * @param value The number of tokens to transfer.
     * @return The ERC-1404 restriction code, zero when the transfer is allowed.
     */
    function detectTransferRestriction(address from, address to, uint256 value) external view returns (uint8);

    /**
     * @notice Returns the human readable message for a restriction code.
     * @param restrictionCode The target restriction code.
     * @return The message describing the restriction.
     */
    function messageForTransferRestriction(uint8 restrictionCode) external view returns (string memory);
}
