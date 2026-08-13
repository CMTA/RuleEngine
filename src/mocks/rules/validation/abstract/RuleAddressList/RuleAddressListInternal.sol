// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title a list manager
 */

abstract contract RuleAddressListInternal {
    error Rulelist_AddressAlreadylisted();
    error Rulelist_AddressNotPresent();

    /**
     * @notice Membership flag per address.
     */
    mapping(address => bool) private list;
    // Number of addresses in the list at the moment
    /**
     * @notice Number of addresses currently in the list.
     */
    uint256 private numAddressesList;

    /**
     * @notice Add addresses to the list
     * If one of addresses already exist, there is no change for this address. The transaction remains valid (no revert).
     * @param listTargetAddresses an array with the addresses to list
     */
    function _addAddressesToThelist(address[] calldata listTargetAddresses) internal virtual {
        uint256 numAddressesListLocal = numAddressesList;
        for (uint256 i = 0; i < listTargetAddresses.length; ++i) {
            if (!list[listTargetAddresses[i]]) {
                list[listTargetAddresses[i]] = true;
                ++numAddressesListLocal;
            }
        }
        numAddressesList = numAddressesListLocal;
    }

    /**
     * @notice Remove addresses from the list
     * If the address does not exist in the list, there is no change for this address.
     * The transaction remains valid (no revert).
     * @param listTargetAddresses an array with the addresses to remove
     */
    function _removeAddressesFromThelist(address[] calldata listTargetAddresses) internal virtual {
        uint256 numAddressesListLocal = numAddressesList;
        for (uint256 i = 0; i < listTargetAddresses.length; ++i) {
            if (list[listTargetAddresses[i]]) {
                list[listTargetAddresses[i]] = false;
                --numAddressesListLocal;
            }
        }
        numAddressesList = numAddressesListLocal;
    }

    /**
     * @notice Add one address to the list
     * If the address already exists, the transaction is reverted to save gas.
     * @param targetAddress The address to list
     */
    function _addAddressToThelist(address targetAddress) internal virtual {
        if (list[targetAddress]) {
            revert Rulelist_AddressAlreadylisted();
        }
        list[targetAddress] = true;
        ++numAddressesList;
    }

    /**
     * @notice Remove one address from the list
     * If the address does not exist in the list, the transaction is reverted to save gas.
     * @param targetAddress The address to remove
     *
     */
    function _removeAddressFromThelist(address targetAddress) internal virtual {
        if (!list[targetAddress]) {
            revert Rulelist_AddressNotPresent();
        }
        list[targetAddress] = false;
        --numAddressesList;
    }

    /**
     * @notice Get the number of listed addresses
     * @return Number of listed addresses
     *
     */
    function _numberListedAddress() internal view virtual returns (uint256) {
        return numAddressesList;
    }

    /**
     * @notice Know if an address is listed or not
     * @param _targetAddress The concerned address
     * @return True if the address is listed, false otherwise
     *
     */
    function _addressIsListed(address _targetAddress) internal view virtual returns (bool) {
        return list[_targetAddress];
    }
}
