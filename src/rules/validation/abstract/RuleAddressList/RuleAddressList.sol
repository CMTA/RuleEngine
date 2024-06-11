// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "./../../../../modules/MetaTxModuleStandalone.sol";
import "./RuleAddressListInternal.sol";
import "./invariantStorage/RuleAddressListInvariantStorage.sol";

/**
@title an addresses list manager
*/

abstract contract RuleAddressList is
    AccessControl,
    MetaTxModuleStandalone,
    RuleAddressListInternal,
    RuleAddressListInvariantStorage
{
    // Number of addresses in the whitelist at the moment
    uint256 private numAddressesWhitelisted;

    /**
     * @param admin Address of the contract (Access Control)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     */
    constructor(
        address admin,
        address forwarderIrrevocable
    ) MetaTxModuleStandalone(forwarderIrrevocable) {
        if (admin == address(0)) {
            revert RuleAddressList_AdminWithAddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADDRESS_LIST_ROLE, admin);
    }

    /**
     * @notice Add addresses to the whitelist
     * If one of addresses already exist, there is no change for this address. The transaction remains valid (no revert).
     * @param listWhitelistedAddress an array with the addresses to whitelist
     */
    function addAddressesToTheList(
        address[] calldata listWhitelistedAddress
    ) public onlyRole(ADDRESS_LIST_ROLE) {
        _addAddressesToThelist(listWhitelistedAddress);
    }

    /**
     * @notice Remove addresses from the whitelist
     * If the address does not exist in the whitelist, there is no change for this address.
     * The transaction remains valid (no revert).
     * @param listWhitelistedAddress an array with the addresses to remove
     */
    function removeAddressesFromTheList(
        address[] calldata listWhitelistedAddress
    ) public onlyRole(ADDRESS_LIST_ROLE) {
        _removeAddressesFromThelist(listWhitelistedAddress);
    }

    /**
     * @notice Add one address to the whitelist
     * If the address already exists, the transaction is reverted to save gas.
     * @param _newWhitelistAddress The address to whitelist
     */
    function addAddressToTheList(
        address _newWhitelistAddress
    ) public onlyRole(ADDRESS_LIST_ROLE) {
        _addAddressToThelist(_newWhitelistAddress);
    }

    /**
     * @notice Remove one address from the whitelist
     * If the address does not exist in the whitelist, the transaction is reverted to save gas.
     * @param _removeWhitelistAddress The address to remove
     *
     */
    function removeAddressFromTheList(
        address _removeWhitelistAddress
    ) public onlyRole(ADDRESS_LIST_ROLE) {
        _removeAddressFromThelist(_removeWhitelistAddress);
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

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
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
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
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
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
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
