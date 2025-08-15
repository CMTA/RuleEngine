// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../RuleCommonInvariantStorage.sol";

abstract contract RuleBlacklistInvariantStorage is RuleCommonInvariantStorage {
    /* ============ String message ============ */
    string constant TEXT_ADDRESS_FROM_IS_BLACKLISTED =
        "The sender is blacklisted";
    string constant TEXT_ADDRESS_TO_IS_BLACKLISTED =
        "The recipient is blacklisted";
    string constant TEXT_ADDRESS_SPENDER_IS_BLACKLISTED =
        "The spender is blacklisted";

    /* ============ Code ============ */
    // It is very important that each rule uses an unique code
    uint8 public constant CODE_ADDRESS_FROM_IS_BLACKLISTED = 41;
    uint8 public constant CODE_ADDRESS_TO_IS_BLACKLISTED = 42;
    uint8 public constant CODE_ADDRESS_SPENDER_IS_BLACKLISTED = 43;
}
