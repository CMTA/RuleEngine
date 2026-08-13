// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title RuleEngineInvariantStorage
 * @notice Holds the custom errors shared by the RuleEngine deployable contracts.
 */
abstract contract RuleEngineInvariantStorage {
    /* ==== Errors === */
    error RuleEngine_AdminWithAddressZeroNotAllowed();
    error RuleEngine_RuleInvalidInterface();
}
