// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract RuleAddressListInvariantStorage {
    // custom errors
    error RuleAddressList_AdminWithAddressZeroNotAllowed();

    // Add/Remove
    bytes32 public constant ADDRESS_LIST_REMOVE_ROLE = keccak256("ADDRESS_LIST_REMOVE_ROLE");
    bytes32 public constant ADDRESS_LIST_ADD_ROLE = keccak256("ADDRESS_LIST_ADD_ROLE");
}
