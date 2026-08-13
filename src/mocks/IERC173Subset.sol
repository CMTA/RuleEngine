// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @dev Test-only subset matching ERC-173 for interfaceId checks.
 */
interface IERC173Subset {
    /**
     * @notice Transfers ownership of the contract to a new account.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) external;

    /**
     * @notice Returns the address of the current owner.
     * @return The address of the current owner.
     */
    function owner() external view returns (address);
}
