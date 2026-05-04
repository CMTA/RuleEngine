// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @dev Test-only subset matching ERC-173 for interfaceId checks.
 */
interface IERC173Subset {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
}
