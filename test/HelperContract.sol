//SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "src/RuleWhiteList.sol";

abstract contract HelperContract {
    address constant ZERO_ADDRESS = address(0);
    address constant DEFAULT_ADMIN_ADDRESS = address(1);
    address constant WHITELIST_OPERATOR_ADDRESS = address(2);
    address constant RULE_ENGINE_OPERATOR_ADDRESS = address(3);
    address constant ATTACKER = address(4);
    address constant ADDRESS1 = address(5);
    address constant ADDRESS2 = address(6);
    address constant ADDRESS3 = address(7);
    string constant RULE_ENGINE_ROLE_HASH =
        "0x774b3c5f4a8b37a7da21d72b7f2429e4a6d49c4de0ac5f2b831a1a539d0f0fd2";
    string constant WHITELIST_ROLE_HASH =
        "0xdc72ed553f2544c34465af23b847953efeb813428162d767f9ba5f4013be6760";
    string constant DEFAULT_ADMIN_ROLE_HASH =
        "0x0000000000000000000000000000000000000000000000000000000000000000";
    RuleWhitelist ruleWhitelist;
    CMTAT CMTAT_CONTRACT;
    bytes32 public constant RULE_ENGINE_ROLE =
        keccak256("RULE_ENGINE_ROLE");
    
    constructor() {}
}
