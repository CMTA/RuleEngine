// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract ERC3643ComplianceModuleInvariantStorage {
    /* ==== Errors === */
    error RuleEngine_ERC3643Compliance_InvalidTokenAddress();
    error RuleEngine_ERC3643Compliance_TokenAlreadyBound();
    error RuleEngine_ERC3643Compliance_TokenNotBound();
    error RuleEngine_ERC3643Compliance_UnauthorizedCaller();
    error RuleEngine_ERC3643Compliance_OperationNotSuccessful();
}
