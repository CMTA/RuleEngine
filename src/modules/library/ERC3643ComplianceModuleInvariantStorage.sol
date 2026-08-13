// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title ERC3643ComplianceModuleInvariantStorage
 * @notice Holds the custom errors raised by the ERC-3643 compliance module.
 */
abstract contract ERC3643ComplianceModuleInvariantStorage {
    /* ==== Errors === */
    error RuleEngine_ERC3643Compliance_InvalidTokenAddress();
    error RuleEngine_ERC3643Compliance_TokenAlreadyBound();
    error RuleEngine_ERC3643Compliance_TokenNotBound();
    error RuleEngine_ERC3643Compliance_UnauthorizedCaller();
}
