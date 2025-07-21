// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract RuleAddressListInvariantStorage {
    /* ============ Events ============ */
    event AddAddressesToTheList(address[] listTargetAddresses);
    event RemoveAddressesFromTheList(address[] listTargetAddresses);
    event AddAddressToTheList(address targetAddress);
    event RemoveAddressFromTheList(address targetAddress);

    /* ============ Custom errors ============ */
    error RuleAddressList_AdminWithAddressZeroNotAllowed();

    /* ============ Role ============ */
    bytes32 public constant ADDRESS_LIST_REMOVE_ROLE =
        keccak256("ADDRESS_LIST_REMOVE_ROLE");
    bytes32 public constant ADDRESS_LIST_ADD_ROLE =
        keccak256("ADDRESS_LIST_ADD_ROLE");
}
