//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

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
    string constant RULE_ENGINE_ROLE_HASH = "0xacd8e63c87cd69425697967e0428694fc91f0f3cf09ccac63f65401cfa956c94";
    string constant WHITELIST_ROLE_HASH = "0xd5fd42827a296da4efc38d4948bb7299b7d1683149226f9a69c0d6f3b7d621ee";
     string constant DEFAULT_ADMIN_ROLE_HASH =
        "0x0000000000000000000000000000000000000000000000000000000000000000";
    RuleWhitelist ruleWhitelist;
    CMTAT CMTAT_CONTRACT;
    constructor() {}
}