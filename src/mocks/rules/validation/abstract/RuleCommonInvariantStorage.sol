// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

/**
 * @title RuleCommonInvariantStorage
 * @notice Restriction messages shared by every reference rule.
 */
abstract contract RuleCommonInvariantStorage {
    // Text
    /**
     * @notice Message returned when no rule claims the queried restriction code.
     */
    string constant TEXT_CODE_NOT_FOUND = "Unknown restriction code";

    // ERC-1404 reserves the code 0 as the "no restriction" sentinel
    // Same message as the one returned by CMTAT (ValidationModuleERC1404)
    /**
     * @notice Message returned for the reserved ERC-1404 code 0 (no restriction).
     */
    string constant TEXT_TRANSFER_OK = "NoRestriction";
}
