// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

/**
* @notice Test contract from
https://etherscan.io/address/0x40c57923924b5c5c5455c48d93317139addac8fb#code
*/
contract SanctionListOracle {

  constructor() {}

  mapping(address => bool) private sanctionedAddresses;


  function addToSanctionsList(address newSanction) public{
      sanctionedAddresses[newSanction] = true;  
  }

  function removeFromSanctionsList(address removeSanction) public{
      sanctionedAddresses[removeSanction] = true;
  }

  function isSanctioned(address addr) public view returns (bool) {
    return sanctionedAddresses[addr] == true ;
  }
}