// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @dev Test-only subset for Ownable2Step-specific ERC-165 checks.
 */
interface IOwnable2StepSubset {
    /**
     * @notice Accepts a pending ownership transfer.
     * @dev Callable by the pending owner to complete the two-step handover.
     */
    function acceptOwnership() external;

    /**
     * @notice Returns the account currently awaiting acceptance of ownership.
     * @return The address of the pending owner.
     */
    function pendingOwner() external view returns (address);
}
