// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../RuleCommonInvariantStorage.sol";

abstract contract RuleWhitelistInvariantStorage is RuleCommonInvariantStorage {
    /* ============ String message ============ */
    string constant TEXT_ADDRESS_FROM_NOT_WHITELISTED =
        "The sender is not in the whitelist";
    string constant TEXT_ADDRESS_TO_NOT_WHITELISTED =
        "The recipient is not in the whitelist";
    string constant TEXT_ADDRESS_SPENDER_NOT_WHITELISTED =
        "The spender is not in the whitelist";

    /* ============ Code ============ */
    // It is very important that each rule uses an unique code
    uint8 public constant CODE_ADDRESS_FROM_NOT_WHITELISTED = 21;
    uint8 public constant CODE_ADDRESS_TO_NOT_WHITELISTED = 22;
    uint8 public constant CODE_ADDRESS_SPENDER_NOT_WHITELISTED = 23;
}
