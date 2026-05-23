// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract ERC3643ComplianceRolesStorage {
    /* ==== Role === */
    bytes32 public constant COMPLIANCE_MANAGER_ROLE = keccak256("COMPLIANCE_MANAGER_ROLE");
}
