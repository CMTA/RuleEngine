//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/CMTAT_STANDALONE.sol";
import "src/RuleWhitelist.sol";

/**
@title Constants used by the tests
*/
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
    CMTAT_STANDALONE CMTAT_CONTRACT;
    bytes32 public constant RULE_ENGINE_ROLE = keccak256("RULE_ENGINE_ROLE");
    // RuleWhiteList message
    string constant TEXT_CODE_NOT_FOUND = "Code not found";
    string constant TEXT_ADDRESS_FROM_NOT_WHITELISTED =
        "The sender is not in the whitelist";
    string constant TEXT_ADDRESS_TO_NOT_WHITELISTED =
        "The recipient is not in the whitelist";
    // RuleWhiteList code list
    uint8 constant CODE_ADDRESS_FROM_NOT_WHITELISTED = 20;
    uint8 constant CODE_ADDRESS_TO_NOT_WHITELISTED = 30;
    uint8 constant NO_ERROR = 0;

    // RuleWhiteList role
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");

    // RuleEngine event
    event AddRule(IRule indexed rule);
    event RemoveRule(IRule indexed rule);
    event ClearRules(IRule[] rulesRemoved);

    // Custom error RuleEngine
    error RuleEngine_RuleAddressZeroNotAllowed();
    error RuleEngine_RuleAlreadyExists();
    error RuleEngine_RuleDoNotMatch();
    error RuleEngine_AdminWithAddressZeroNotAllowed();
    error RuleEngine_ArrayIsEmpty();

    // custom errors RuleWhitelist
    error RuleWhitelist_AdminWithAddressZeroNotAllowed();
    error RuleWhitelist_AddressAlreadyWhitelisted();
    error RuleWhitelist_AddressNotPresent();



    constructor() {}
}
