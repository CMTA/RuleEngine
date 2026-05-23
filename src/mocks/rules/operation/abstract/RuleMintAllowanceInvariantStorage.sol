// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

// forge-lint: disable-next-line(unaliased-plain-import)
import "../../validation/abstract/RuleCommonInvariantStorage.sol";

abstract contract RuleMintAllowanceInvariantStorage is RuleCommonInvariantStorage {
    /* ============ Error ============ */
    error RuleMintAllowance_InsufficientAllowance(address minter, uint256 allowance, uint256 value);

    /* ============ Events ============ */
    event MintAllowanceSet(address indexed minter, uint256 allowance);
    event MintAllowanceConsumed(address indexed minter, uint256 consumed, uint256 remaining);

    /* ============ Restriction codes ============ */
    // It is very important that each rule uses a unique code
    uint8 public constant CODE_MINTER_INSUFFICIENT_ALLOWANCE = 81;

    /* ============ Restriction messages ============ */
    string constant TEXT_MINTER_INSUFFICIENT_ALLOWANCE = "MintAllowance: Insufficient allowance for minter";
}
