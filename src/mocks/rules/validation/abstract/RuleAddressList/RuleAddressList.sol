// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "../../../../../modules/ERC2771ModuleStandalone.sol";
import "./RuleAddressListInternal.sol";
import "./invariantStorage/RuleAddressListInvariantStorage.sol";

/**
@title an addresses list manager
*/

abstract contract RuleAddressList is
    AccessControl,
    ERC2771ModuleStandalone,
    RuleAddressListInternal,
    RuleAddressListInvariantStorage
{
    // Number of addresses in the list at the moment
    uint256 private numAddressesWhitelisted;

    /**
     * @param admin Address of the contract (Access Control)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     */
    constructor(
        address admin,
        address forwarderIrrevocable
    ) ERC2771ModuleStandalone(forwarderIrrevocable) {
        if (admin == address(0)) {
            revert RuleAddressList_AdminWithAddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /**
     * @notice Add addresses to the list
     * If one of addresses already exist, there is no change for this address. The transaction remains valid (no revert).
     * @param listTargetAddresses an array with the addresses to list
     */
    function addAddressesToTheList(
        address[] calldata listTargetAddresses
    ) public onlyRole(ADDRESS_LIST_ADD_ROLE) {
        _addAddressesToThelist(listTargetAddresses);
        emit AddAddressesToTheList(listTargetAddresses);
    }

    /**
     * @notice Remove addresses from the list
     * If the address does not exist in the list, there is no change for this address.
     * The transaction remains valid (no revert).
     * @param listTargetAddresses an array with the addresses to remove
     */
    function removeAddressesFromTheList(
        address[] calldata listTargetAddresses
    ) public onlyRole(ADDRESS_LIST_REMOVE_ROLE) {
        _removeAddressesFromThelist(listTargetAddresses);
        emit RemoveAddressesFromTheList(listTargetAddresses);
    }

    /**
     * @notice Add one address to the list
     * If the address already exists, the transaction is reverted to save gas.
     * @param targetAddress The address to list
     */
    function addAddressToTheList(
        address targetAddress
    ) public onlyRole(ADDRESS_LIST_ADD_ROLE) {
        _addAddressToThelist(targetAddress);
        emit AddAddressToTheList(targetAddress);
    }

    /**
     * @notice Remove one address from the list
     * If the address does not exist in the list, the transaction is reverted to save gas.
     * @param targetAddress The address to remove
     *
     */
    function removeAddressFromTheList(
        address targetAddress
    ) public onlyRole(ADDRESS_LIST_REMOVE_ROLE) {
        _removeAddressFromThelist(targetAddress);
        emit RemoveAddressFromTheList(targetAddress);
    }

    /**
     * @notice Get the number of listed addresses
     * @return Number of listed addresses
     *
     */
    function numberListedAddress() public view returns (uint256) {
        return _numberListedAddress();
    }

    /**
     * @notice Know if an address is listed or not
     * @param _targetAddress The concerned address
     * @return True if the address is listed, false otherwise
     *
     */
    function addressIsListed(
        address _targetAddress
    ) public view returns (bool) {
        return _addressIsListed(_targetAddress);
    }

    /**
     * @notice batch version of {addressIsListed}
     *
     */
    function addressIsListedBatch(
        address[] memory _targetAddresses
    ) public view returns (bool[] memory) {
        bool[] memory isListed = new bool[](_targetAddresses.length);
        for (uint256 i = 0; i < _targetAddresses.length; ++i) {
            isListed[i] = _addressIsListed(_targetAddresses[i]);
        }
        return isListed;
    }

    /* ============ ACCESS CONTROL ============ */
    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControl) returns (bool) {
        // The Default Admin has all roles
        if (AccessControl.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        }
        return AccessControl.hasRole(role, account);
    }

    /*//////////////////////////////////////////////////////////////
                           ERC-2771
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev This surcharge is not necessary if you do not use the ERC2771Module
     */
    function _msgSender()
        internal
        view
        override(ERC2771Context, Context)
        returns (address sender)
    {
        return ERC2771Context._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the ERC2771Module
     */
    function _msgData()
        internal
        view
        override(ERC2771Context, Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the ERC2771Module
     */
    function _contextSuffixLength()
        internal
        view
        override(ERC2771Context, Context)
        returns (uint256)
    {
        return ERC2771Context._contextSuffixLength();
    }
}
