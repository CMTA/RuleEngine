// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title RuleAddressListInvariantStorage
 * @notice Events, errors and roles used by the address-list based rules.
 */
abstract contract RuleAddressListInvariantStorage {
    /* ============ Events ============ */
    /**
     * @notice Emitted when several addresses are added to the list.
     * @param listTargetAddresses The addresses added to the list.
     */
    event AddAddressesToTheList(address[] listTargetAddresses);

    /**
     * @notice Emitted when several addresses are removed from the list.
     * @param listTargetAddresses The addresses removed from the list.
     */
    event RemoveAddressesFromTheList(address[] listTargetAddresses);

    /**
     * @notice Emitted when a single address is added to the list.
     * @param targetAddress The address added to the list.
     */
    event AddAddressToTheList(address targetAddress);

    /**
     * @notice Emitted when a single address is removed from the list.
     * @param targetAddress The address removed from the list.
     */
    event RemoveAddressFromTheList(address targetAddress);

    /* ============ Custom errors ============ */
    error RuleAddressList_AdminWithAddressZeroNotAllowed();

    /* ============ Role ============ */
    /**
     * @notice Role allowed to remove addresses from the list.
     */
    bytes32 public constant ADDRESS_LIST_REMOVE_ROLE = keccak256("ADDRESS_LIST_REMOVE_ROLE");

    /**
     * @notice Role allowed to add addresses to the list.
     */
    bytes32 public constant ADDRESS_LIST_ADD_ROLE = keccak256("ADDRESS_LIST_ADD_ROLE");
}
