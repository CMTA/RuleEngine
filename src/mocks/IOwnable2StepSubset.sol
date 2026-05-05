// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @dev Test-only subset for Ownable2Step-specific ERC-165 checks.
 */
interface IOwnable2StepSubset {
    function pendingOwner() external view returns (address);
    function acceptOwnership() external;
}
