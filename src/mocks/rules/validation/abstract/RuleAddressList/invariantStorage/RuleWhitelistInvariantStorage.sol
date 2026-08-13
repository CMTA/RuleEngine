// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {RuleCommonInvariantStorage} from "../../RuleCommonInvariantStorage.sol";

/**
 * @title RuleWhitelistInvariantStorage
 * @notice Restriction codes and messages for the whitelist rule.
 */
abstract contract RuleWhitelistInvariantStorage is RuleCommonInvariantStorage {
    /* ============ String message ============ */
    /**
     * @notice Message returned when the sender is not whitelisted.
     */
    string constant TEXT_ADDRESS_FROM_NOT_WHITELISTED = "The sender is not in the whitelist";
    /**
     * @notice Message returned when the recipient is not whitelisted.
     */
    string constant TEXT_ADDRESS_TO_NOT_WHITELISTED = "The recipient is not in the whitelist";
    /**
     * @notice Message returned when the spender is not whitelisted.
     */
    string constant TEXT_ADDRESS_SPENDER_NOT_WHITELISTED = "The spender is not in the whitelist";

    /* ============ Code ============ */
    // It is very important that each rule uses an unique code
    /**
     * @notice Restriction code raised when the sender is not whitelisted.
     */
    uint8 public constant CODE_ADDRESS_FROM_NOT_WHITELISTED = 21;
    /**
     * @notice Restriction code raised when the recipient is not whitelisted.
     */
    uint8 public constant CODE_ADDRESS_TO_NOT_WHITELISTED = 22;
    /**
     * @notice Restriction code raised when the spender is not whitelisted.
     */
    uint8 public constant CODE_ADDRESS_SPENDER_NOT_WHITELISTED = 23;
}
