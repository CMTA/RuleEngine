// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "CMTAT/interfaces/IRule.sol";
import "./CodeList.sol";
import "./AccessControlAbstract.sol";

/**
@title a whitelist manager
*/
contract RuleWhitelist is IRule, CodeList, AccessControlAbstract {

// Number of addresses in the whitelist at the moment
  uint256 private numAddressesWhitelisted;

  string constant TEXT_CODE_NOT_FOUND = 
  "Code not found";
  string constant TEXT_ADDRESS_FROM_NOT_WHITELISTED = 
  "The sender is not in the whitelist";
  string constant TEXT_ADDRESS_TO_NOT_WHITELISTED = 
  "The recipient is not in the whitelist";
  
  mapping(address => bool) whitelist;

  constructor(){
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(WHITELIST_ROLE, msg.sender);
  }

  /**
  * @dev add addresses to the whitelist
  * @param listWhitelistedAddress an array with the addresses to whitelist
  */
  function addAddressesToTheWhitelist(address[] calldata listWhitelistedAddress) 
  public onlyRole(WHITELIST_ROLE) {
   
    for(uint256 i = 0; i < listWhitelistedAddress.length; ++i){
        if(!whitelist[listWhitelistedAddress[i]]){
        whitelist[listWhitelistedAddress[i]] = true;
        ++numAddressesWhitelisted;
      }
    }
  }

  /**
  * @dev remove addresses from the whitelist
  * @param listWhitelistedAddress an array with the addresses to remove
  */
  function removeAddressesFromTheWhitelist(address[] calldata listWhitelistedAddress) public onlyRole(WHITELIST_ROLE) {
   for(uint256 i = 0; i < listWhitelistedAddress.length; ++i){
        if(whitelist[listWhitelistedAddress[i]]){
        whitelist[listWhitelistedAddress[i]] = false;
        --numAddressesWhitelisted;
      }
    }
  }

  /**
  * @dev add one address to the whitelist
  * @param _newWhitelistAddress the address to whitelist
  */
  function addAddressToTheWhitelist(address _newWhitelistAddress) public onlyRole(WHITELIST_ROLE){
    require(!whitelist[_newWhitelistAddress], "Address is already in the whitelist");
    if(!whitelist[_newWhitelistAddress]){
        whitelist[_newWhitelistAddress] = true;
        ++numAddressesWhitelisted;
    }
  }

  /**
  * @dev remove one address from the whitelist
  * @param _removeWhitelistAddress the address to remove
  *
  */
   function removeAddressFromTheWhitelist(address _removeWhitelistAddress) public onlyRole(WHITELIST_ROLE){
    require(whitelist[_removeWhitelistAddress], "Address is not in the whitelist");
    if(whitelist[_removeWhitelistAddress]){
        whitelist[_removeWhitelistAddress] = false;
        --numAddressesWhitelisted;
    }
  }

  /**
  * @dev Get the number of whitelisted addresses
  * @return number of whitelisted addresses
  *
  */
  function numberWhitelistedAddress() public view returns(uint256 )  {
    return numAddressesWhitelisted;
  }

  /**
  * @dev Know if an address is whitelisted or not
  * @param _targetAddress the concerned address
  * @return true if the address is whitelisted, false otherwise
  *
  */
  function addressIsWhitelisted(address _targetAddress) public view returns (bool) {
    return whitelist[_targetAddress];
  }
  
  
  function validateTransfer(
    address _from, address _to, uint256 _amount)
  public view override returns (bool isValid)
  {
    return detectTransferRestriction(_from, _to, _amount) == NO_ERROR;
  }

  function detectTransferRestriction(
    address _from, address _to, uint256 /*_amount */)
  public view override returns (uint8)
  {
    if(!whitelist[_from]){
        return CODE_ADDRESS_FROM_NOT_WHITELISTED;
    } 
    if(!whitelist[_to]){
        return CODE_ADDRESS_TO_NOT_WHITELISTED;
    }

    return NO_ERROR;
    
  }

  function canReturnTransferRestrictionCode(uint8 _restrictionCode) public pure override returns (bool) {
    if(
      _restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED 
      || 
      _restrictionCode == CODE_ADDRESS_TO_NOT_WHITELISTED
     ){
        return true;
    }
    return false;
  }

  function messageForTransferRestriction(uint8 _restrictionCode) external pure override returns (string memory) {
    if(_restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED  ){
        return TEXT_ADDRESS_FROM_NOT_WHITELISTED;
    }
    
    else if(_restrictionCode == CODE_ADDRESS_TO_NOT_WHITELISTED  ){
        return TEXT_ADDRESS_TO_NOT_WHITELISTED;
    }

    else {
        return TEXT_CODE_NOT_FOUND;
    }
    
  }
  /**
  * @dev Destroy the contract bytecode
  * Warning: this action is irreversible and very critical
  * You can call this function only if the contract is not used by any ruleEngine.
  * Otherwise, the calls from the RuleEngine will revert.
  */
  function kill() public onlyRole(DEFAULT_ADMIN_ROLE) {
        selfdestruct(payable(msg.sender));
  }
}
