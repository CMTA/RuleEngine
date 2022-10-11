// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "CMTAT/interfaces/IRule.sol";
import "./CodeList.sol";
contract RuleWhitelist is IRule, CodeList {

// Number of addresses in the whitelist at the moment
  uint256 private numAddressesWhitelisted;

  string constant TEXT_CODE_NOT_FOUND = 
  "Code not found";
  string constant TEXT_ADDRESS_FROM_NOT_WHITELISTED = 
  "The sender is not in the whitelist";
  string constant TEXT_ADDRESS_TO_NOT_WHITELISTED = 
  "The recipient is not in the whitelist";
  
  mapping(address => bool) whitelist;

  function addListAddressToTheWhitelist(address[] calldata listWhitelistedAddress) 
  public{
   
    for(uint256 i = 0; i < listWhitelistedAddress.length; ++i){
        if(!whitelist[listWhitelistedAddress[i]]){
        whitelist[listWhitelistedAddress[i]] = true;
        ++numAddressesWhitelisted;
      }
    }
  }

  function removeListAddressToTheWhitelist(address[] calldata listWhitelistedAddress) public {
    // require(whitelist[_removeWhitelistAddress], "Address is not in the whitelist");
   for(uint256 i = 0; i < listWhitelistedAddress.length; ++i){
        if(whitelist[listWhitelistedAddress[i]]){
        whitelist[listWhitelistedAddress[i]] = false;
        --numAddressesWhitelisted;
      }
    }
  }


  function addOneAddressToTheWhitelist(address _newWhitelistAddress) public {
    require(_newWhitelistAddress != address(0), "Address 0 is not allowed");
    require(!whitelist[_newWhitelistAddress], "Address is already in the whitelist");
    if(!whitelist[_newWhitelistAddress]){
        whitelist[_newWhitelistAddress] = true;
        ++numAddressesWhitelisted;
    }
  }

   function removeOneAddressToTheWhitelist(address _removeWhitelistAddress) public {
    require(whitelist[_removeWhitelistAddress], "Address is not in the whitelist");
    if(whitelist[_removeWhitelistAddress]){
        whitelist[_removeWhitelistAddress] = false;
        --numAddressesWhitelisted;
    }
  }

  function numberWhitelistedAddress() public view returns(uint256 )  {
    return numAddressesWhitelisted;
  }

  function addressIsWhitelisted(address _targetAddress) public view returns (bool) {
    return whitelist[_targetAddress];
  }
  
  
  function isTransferValid(
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
      ||
      _restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED
    
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

    else if(_restrictionCode == CODE_ADDRESS_FROM_NOT_WHITELISTED  ){
        return TEXT_ADDRESS_TO_NOT_WHITELISTED;
    }

    else {
        return TEXT_CODE_NOT_FOUND;
    }
    
  }
}
