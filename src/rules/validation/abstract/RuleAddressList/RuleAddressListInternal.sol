// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @title a list manager
*/

abstract contract RuleAddressListInternal {
    error Rulelist_AddressAlreadylisted();
    error Rulelist_AddressNotPresent();
    
    mapping(address => bool) private list;
    // Number of addresses in the list at the moment
    uint256 private numAddressesList;


    /**
     * @notice Add addresses to the list
     * If one of addresses already exist, there is no change for this address. The transaction remains valid (no revert).
     * @param listAddresses an array with the addresses to list
     */
    function _addAddressesToThelist(
        address[] calldata listAddresses
    ) internal {
        uint256 numAddressesListLocal = numAddressesList;
        for (uint256 i = 0; i < listAddresses.length; ) {
            if (!list[listAddresses[i]]) {
                list[listAddresses[i]] = true;
                ++numAddressesListLocal;
            }
            unchecked {
                ++i;
            }
        }
        numAddressesList = numAddressesListLocal;
    }

    /**
     * @notice Remove addresses from the list
     * If the address does not exist in the list, there is no change for this address. 
     * The transaction remains valid (no revert).
     * @param listAddresses an array with the addresses to remove
     */
    function _removeAddressesFromThelist(
        address[] calldata listAddresses
    ) internal {
        uint256 numAddressesListLocal = numAddressesList;
        for (uint256 i = 0; i < listAddresses.length; ) {
            if (list[listAddresses[i]]) {
                list[listAddresses[i]] = false;
                --numAddressesListLocal;
            }
            unchecked {
                ++i;
            }
        }
        numAddressesList = numAddressesListLocal;
    }

    /**
     * @notice Add one address to the list
     * If the address already exists, the transaction is reverted to save gas.
     * @param _newlistAddress The address to list
     */
    function _addAddressToThelist(
        address _newlistAddress
    ) internal {
        if(list[_newlistAddress])
        {
            revert Rulelist_AddressAlreadylisted();
        }
        list[_newlistAddress] = true;
        ++numAddressesList;
    }

    /**
     * @notice Remove one address from the list
     * If the address does not exist in the list, the transaction is reverted to save gas.
     * @param _removelistAddress The address to remove
     *
     */
    function _removeAddressFromThelist(
        address _removelistAddress
    ) internal {
        if(!list[_removelistAddress]){
            revert Rulelist_AddressNotPresent();
        }
        list[_removelistAddress] = false;
        --numAddressesList;
    }

    /**
     * @notice Get the number of listed addresses
     * @return Number of listed addresses
     *
     */
    function _numberListedAddress() internal view returns (uint256) {
        return numAddressesList;
    }

    /**
     * @notice Know if an address is listed or not
     * @param _targetAddress The concerned address
     * @return True if the address is listed, false otherwise
     *
     */
    function _addressIsListed(
        address _targetAddress
    ) internal view returns (bool) {
        return list[_targetAddress];
    }
}
