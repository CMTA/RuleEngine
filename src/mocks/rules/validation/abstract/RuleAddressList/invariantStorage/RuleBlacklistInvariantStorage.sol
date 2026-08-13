// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {RuleCommonInvariantStorage} from "../../RuleCommonInvariantStorage.sol";

/**
 * @title RuleBlacklistInvariantStorage
 * @notice Restriction codes and messages for the blacklist rule.
 */
abstract contract RuleBlacklistInvariantStorage is RuleCommonInvariantStorage {
    /* ============ String message ============ */
    /**
     * @notice Message returned when the sender is blacklisted.
     */
    string constant TEXT_ADDRESS_FROM_IS_BLACKLISTED = "The sender is blacklisted";
    /**
     * @notice Message returned when the recipient is blacklisted.
     */
    string constant TEXT_ADDRESS_TO_IS_BLACKLISTED = "The recipient is blacklisted";
    /**
     * @notice Message returned when the spender is blacklisted.
     */
    string constant TEXT_ADDRESS_SPENDER_IS_BLACKLISTED = "The spender is blacklisted";

    /* ============ Code ============ */
    // It is very important that each rule uses an unique code
    /**
     * @notice Restriction code raised when the sender is blacklisted.
     */
    uint8 public constant CODE_ADDRESS_FROM_IS_BLACKLISTED = 41;
    /**
     * @notice Restriction code raised when the recipient is blacklisted.
     */
    uint8 public constant CODE_ADDRESS_TO_IS_BLACKLISTED = 42;
    /**
     * @notice Restriction code raised when the spender is blacklisted.
     */
    uint8 public constant CODE_ADDRESS_SPENDER_IS_BLACKLISTED = 43;
}
