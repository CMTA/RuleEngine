// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "../lib/CMTAT/contracts/mocks/RuleEngine/interfaces/IRule.sol";
import "./modules/MetaTxModuleStandalone.sol";

/**
@title a whitelist manager
*/

contract RuleWhitelist is IRule, AccessControl, MetaTxModuleStandalone {
    // custom errors
    error RuleWhitelist_AdminWithAddressZeroNotAllowed();
    error RuleWhitelist_AddressAlreadyWhitelisted();
    error RuleWhitelist_AddressNotPresent();
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
    uint8 public constant CODE_ADDRESS_FROM_NOT_WHITELISTED = 20;
    uint8 public constant CODE_ADDRESS_TO_NOT_WHITELISTED = 30;

    mapping(address => bool) whitelist;

    /**
    * @param admin Address of the contract (Access Control)
    * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
    */
    constructor(
        address admin,
        address forwarderIrrevocable
    ) MetaTxModuleStandalone(forwarderIrrevocable) {
        if(admin == address(0)){
            revert RuleWhitelist_AdminWithAddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(WHITELIST_ROLE, admin);
    }

    /**
     * @notice Add addresses to the whitelist
     * If one of addresses already exist, there is no change for this address. The transaction remains valid (no revert).
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
     * If the address does not exist in the whitelist, there is no change for this address. 
     * The transaction remains valid (no revert).
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
     * If the address already exists, the transaction is reverted to save gas.
     * @param _newWhitelistAddress The address to whitelist
     */
    function addAddressToTheWhitelist(
        address _newWhitelistAddress
    ) public onlyRole(WHITELIST_ROLE) {
        if(whitelist[_newWhitelistAddress])
        {
            revert RuleWhitelist_AddressAlreadyWhitelisted();
        }
        whitelist[_newWhitelistAddress] = true;
        ++numAddressesWhitelisted;
    }

    /**
     * @notice Remove one address from the whitelist
     * If the address does not exist in the whitelist, the transaction is reverted to save gas.
     * @param _removeWhitelistAddress The address to remove
     *
     */
    function removeAddressFromTheWhitelist(
        address _removeWhitelistAddress
    ) public onlyRole(WHITELIST_ROLE) {
        if(!whitelist[_removeWhitelistAddress]){
            revert RuleWhitelist_AddressNotPresent();
        }
        whitelist[_removeWhitelistAddress] = false;
        --numAddressesWhitelisted;
    }

    /**
     * @notice Get the number of whitelisted addresses
     * @return Number of whitelisted addresses
     *
     */
    function numberWhitelistedAddress() external view returns (uint256) {
        return numAddressesWhitelisted;
    }

    /**
     * @notice Know if an address is whitelisted or not
     * @param _targetAddress The concerned address
     * @return True if the address is whitelisted, false otherwise
     *
     */
    function addressIsWhitelisted(
        address _targetAddress
    ) external view returns (bool) {
        return whitelist[_targetAddress];
    }

    /** 
    * @notice Validate a transfer
    * @param _from the origin address
    * @param _to the destination address
    * @param _amount to transfer
    * @return isValid => true if the transfer is valid, false otherwise
    **/
    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool isValid) {
        return
            detectTransferRestriction(_from, _to, _amount) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /** 
    * @notice Check if an addres is in the whitelist or not
    * @param _from the origin address
    * @param _to the destination address
    * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
    **/
    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 /*_amount */
    ) public view override returns (uint8) {
        if (!whitelist[_from]) {
            return CODE_ADDRESS_FROM_NOT_WHITELISTED;
        } else if (!whitelist[_to]) {
            return CODE_ADDRESS_TO_NOT_WHITELISTED;
        } else {
            return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    /** 
    * @notice To know if the restriction code is valid for this rule or not.
    * @param _restrictionCode The target restriction code
    * @return true if the restriction code is known, false otherwise
    **/
    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external pure override returns (bool) {
        return
            _restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED ||
            _restrictionCode == CODE_ADDRESS_TO_NOT_WHITELISTED;
    }

    /** 
    * @notice Return the corresponding message
    * @param _restrictionCode The target restriction code
    * @return true if the transfer is valid, false otherwise
    **/
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
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
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
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
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
