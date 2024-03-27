// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract RuleAddressListInvariantStorage{
    // custom errors
    error RuleAddressList_AdminWithAddressZeroNotAllowed();

    
    // Role
    bytes32 public constant ADDRESS_LIST_ROLE = keccak256("ADDRESS_LIST_ROLE");

}