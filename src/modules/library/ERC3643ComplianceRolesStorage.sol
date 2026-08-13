// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title ERC3643ComplianceRolesStorage
 * @notice Holds the RBAC role identifier used by the ERC-3643 compliance module.
 */
abstract contract ERC3643ComplianceRolesStorage {
    /* ==== Role === */
    /**
     * @notice Role allowed to bind and unbind tokens on the compliance contract.
     */
    bytes32 public constant COMPLIANCE_MANAGER_ROLE = keccak256("COMPLIANCE_MANAGER_ROLE");
}
