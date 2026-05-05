// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title Ownable2StepInterfaceId
 * @dev ERC-165 interface ID for Ownable2Step-specific functions only.
 */
library Ownable2StepInterfaceId {
    // bytes4(keccak256("acceptOwnership()")) ^ bytes4(keccak256("pendingOwner()"))
    bytes4 public constant IOWNABLE2STEP_INTERFACE_ID = 0x9ab669ef;
}
