// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "CMTAT/interfaces/IRule.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "./modules//MetaTxModuleStandalone.sol";
/**
@title a whitelist manager
*/

contract RuleWhitelist is IRule, AccessControl, MetaTxModuleStandalone {
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
    // Number of addresses in the whitelist at the moment
    uint256 private numAddressesWhitelisted;

    string constant TEXT_CODE_NOT_FOUND = "Code not found";
    string constant TEXT_ADDRESS_FROM_NOT_WHITELISTED =
        "The sender is not in the whitelist";
    string constant TEXT_ADDRESS_TO_NOT_WHITELISTED =
        "The recipient is not in the whitelist";

    // Code 
    // It is very important that each rule uses an unique code
    uint8 constant public CODE_ADDRESS_FROM_NOT_WHITELISTED = 20;
    uint8 constant public CODE_ADDRESS_TO_NOT_WHITELISTED = 30;
    uint8 constant public NO_ERROR = 0;

    mapping(address => bool) whitelist;

    constructor(address admin, address forwarderIrrevocable) MetaTxModuleStandalone(forwarderIrrevocable) {
        require(admin != address(0), "Address 0 not allowed");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(WHITELIST_ROLE, admin);
    }

    /**
     * @notice Add addresses to the whitelist
     * @param listWhitelistedAddress an array with the addresses to whitelist
     */
    function addAddressesToTheWhitelist(
        address[] calldata listWhitelistedAddress
    ) public onlyRole(WHITELIST_ROLE) {
        uint256 numAddressesWhitelistedLocal = numAddressesWhitelisted;
        for (uint256 i = 0; i < listWhitelistedAddress.length; ) {
            if (!whitelist[listWhitelistedAddress[i]]) {
                whitelist[listWhitelistedAddress[i]] = true;
                ++numAddressesWhitelistedLocal;
            }
            unchecked {
                ++i;
            }
        }
        numAddressesWhitelisted = numAddressesWhitelistedLocal;
    }

    /**
     * @notice Remove addresses from the whitelist
     * @param listWhitelistedAddress an array with the addresses to remove
     */
    function removeAddressesFromTheWhitelist(
        address[] calldata listWhitelistedAddress
    ) public onlyRole(WHITELIST_ROLE) {
        uint256 numAddressesWhitelistedLocal = numAddressesWhitelisted;
        for (uint256 i = 0; i < listWhitelistedAddress.length; ) {
            if (whitelist[listWhitelistedAddress[i]]) {
                whitelist[listWhitelistedAddress[i]] = false;
                --numAddressesWhitelistedLocal;
            }
            unchecked {
                ++i;
            }
        }
        numAddressesWhitelisted = numAddressesWhitelistedLocal;
    }

    /**
     * @notice Add one address to the whitelist
     * @param _newWhitelistAddress the address to whitelist
     */
    function addAddressToTheWhitelist(
        address _newWhitelistAddress
    ) public onlyRole(WHITELIST_ROLE) {
        require(
            !whitelist[_newWhitelistAddress],
            "Address is already in the whitelist"
        );
        whitelist[_newWhitelistAddress] = true;
        ++numAddressesWhitelisted;
    }

    /**
     * @notice Remove one address from the whitelist
     * @param _removeWhitelistAddress the address to remove
     *
     */
    function removeAddressFromTheWhitelist(
        address _removeWhitelistAddress
    ) public onlyRole(WHITELIST_ROLE) {
        require(
            whitelist[_removeWhitelistAddress],
            "Address is not in the whitelist"
        );
        whitelist[_removeWhitelistAddress] = false;
        --numAddressesWhitelisted;
    }

    /**
     * @notice Get the number of whitelisted addresses
     * @return number of whitelisted addresses
     *
     */
    function numberWhitelistedAddress() external view returns (uint256) {
        return numAddressesWhitelisted;
    }

    /**
     * @notice Know if an address is whitelisted or not
     * @param _targetAddress the concerned address
     * @return true if the address is whitelisted, false otherwise
     *
     */
    function addressIsWhitelisted(
        address _targetAddress
    ) external view returns (bool) {
        return whitelist[_targetAddress];
    }

    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool isValid) {
        return detectTransferRestriction(_from, _to, _amount) == NO_ERROR;
    }

    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 /*_amount */
    ) public view override returns (uint8) {
        if (!whitelist[_from]) {
            return CODE_ADDRESS_FROM_NOT_WHITELISTED;
        }else if (!whitelist[_to]) {
            return CODE_ADDRESS_TO_NOT_WHITELISTED;
        }else{
            return NO_ERROR;
        }
    }

    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external pure override returns (bool) {
        return _restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED ||
            _restrictionCode == CODE_ADDRESS_TO_NOT_WHITELISTED;
    }

    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external pure override returns (string memory) {
        if (_restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED) {
            return TEXT_ADDRESS_FROM_NOT_WHITELISTED;
        } else if (_restrictionCode == CODE_ADDRESS_TO_NOT_WHITELISTED) {
            return TEXT_ADDRESS_TO_NOT_WHITELISTED;
        } else {
            return TEXT_CODE_NOT_FOUND;
        }
    }

    /** 
    @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgSender()
        internal
        view
        override(MetaTxModuleStandalone, Context)
        returns (address sender)
    {
        return MetaTxModuleStandalone._msgSender();
    }

    /** 
    @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgData()
        internal
        view
        override(MetaTxModuleStandalone, Context)
        returns (bytes calldata)
    {
        return MetaTxModuleStandalone._msgData();
    }
}
