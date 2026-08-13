// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleCommonInvariantStorage} from "../../validation/abstract/RuleCommonInvariantStorage.sol";

/**
 * @title RuleMintAllowanceInvariantStorage
 * @notice Errors, events, codes and messages for the mint-allowance rule.
 */
abstract contract RuleMintAllowanceInvariantStorage is RuleCommonInvariantStorage {
    /* ============ Error ============ */
    error RuleMintAllowance_InsufficientAllowance(address minter, uint256 allowance, uint256 value);
    error RuleMintAllowance_AdminAddressZeroNotAllowed();

    /* ============ Events ============ */
    /**
     * @notice Emitted when a minter's allowance is set.
     * @param minter The minter whose allowance changed.
     * @param allowance The new allowance.
     */
    event MintAllowanceSet(address indexed minter, uint256 allowance);
    /**
     * @notice Emitted when a minter consumes part of its allowance.
     * @param minter The minter consuming the allowance.
     * @param consumed The amount consumed.
     * @param remaining The allowance left after the operation.
     */
    event MintAllowanceConsumed(address indexed minter, uint256 consumed, uint256 remaining);

    /* ============ Restriction codes ============ */
    // It is very important that each rule uses a unique code
    /**
     * @notice Restriction code raised when a minter's allowance is insufficient.
     */
    uint8 public constant CODE_MINTER_INSUFFICIENT_ALLOWANCE = 81;

    /* ============ Restriction messages ============ */
    /**
     * @notice Message returned when a minter's allowance is insufficient.
     */
    string constant TEXT_MINTER_INSUFFICIENT_ALLOWANCE = "MintAllowance: Insufficient allowance for minter";
}
