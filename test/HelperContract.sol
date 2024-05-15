//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/CMTAT_STANDALONE.sol";

import "src/modules/RuleEngineInvariantStorage.sol";
// RuleConditionalTransfer
import "src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol";
import "src/rules/operation/RuleConditionalTransfer.sol";
// RuleSanctionList
import "src/rules/validation/RuleSanctionList.sol";
// RUleBlackList
import "src/rules/validation/RuleBlacklist.sol";
// RuleWhitelist
import "src/rules/validation/RuleWhitelist.sol";
import "src/rules/validation/abstract/RuleAddressList/RuleWhitelistInvariantStorage.sol";
import "src/rules/validation/abstract/RuleAddressList/RuleAddressListInvariantStorage.sol";

import "src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol";
import "src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol";
// Rule interface
import "src/interfaces/IRuleValidation.sol";
import "src/interfaces/IRuleOperation.sol";
/**
* @title Constants used by the tests
*/
abstract contract HelperContract is RuleWhitelistInvariantStorage, RuleBlacklistInvariantStorage, RuleAddressListInvariantStorage, RuleSanctionlistInvariantStorage, RuleEngineInvariantStorage, RuleConditionalTransferInvariantStorage  {
    // EOA to perform tests
    address constant ZERO_ADDRESS = address(0);
    address constant DEFAULT_ADMIN_ADDRESS = address(1);
    address constant WHITELIST_OPERATOR_ADDRESS = address(2);
    address constant RULE_ENGINE_OPERATOR_ADDRESS = address(3);
    address constant SANCTIONLIST_OPERATOR_ADDRESS = address(8);
    address constant CONDITIONAL_TRANSFER_OPERATOR_ADDRESS = address(9);
    address constant ATTACKER = address(4);
    address constant ADDRESS1 = address(5);
    address constant ADDRESS2 = address(6);
    address constant ADDRESS3 = address(7);
    // role string
    string constant RULE_ENGINE_ROLE_HASH =
        "0x774b3c5f4a8b37a7da21d72b7f2429e4a6d49c4de0ac5f2b831a1a539d0f0fd2";
    string constant WHITELIST_ROLE_HASH =
        "0xdc72ed553f2544c34465af23b847953efeb813428162d767f9ba5f4013be6760";
    string constant DEFAULT_ADMIN_ROLE_HASH =
        "0x0000000000000000000000000000000000000000000000000000000000000000";
    
    uint256 DEFAULT_TIME_LIMIT_TO_APPROVE = 7 days;              
    uint256 DEFAULT_TIME_LIMIT_TO_TRANSFER = 7 days;
    // contract
    RuleBlacklist ruleBlacklist;
    RuleWhitelist ruleWhitelist;
    RuleConditionalTransfer ruleConditionalTransfer;
    CMTAT_STANDALONE CMTAT_CONTRACT;

    //bytes32 public constant RULE_ENGINE_ROLE = keccak256("RULE_ENGINE_ROLE");

    uint8 constant NO_ERROR = 0;

    // Forwarder
    string ERC2771ForwarderDomain = 'ERC2771ForwarderDomain';

    error Rulelist_AddressAlreadylisted();
    error Rulelist_AddressNotPresent();
    constructor() {}
}
