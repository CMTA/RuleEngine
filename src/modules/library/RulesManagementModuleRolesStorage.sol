// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title RulesManagementModuleRolesStorage
 * @notice Holds the RBAC role identifier used by the rules management module.
 */
abstract contract RulesManagementModuleRolesStorage {
    /* ==== Role === */
    /**
     * @notice Role allowed to add, remove, set and clear rules.
     */
    bytes32 public constant RULES_MANAGEMENT_ROLE = keccak256("RULES_MANAGEMENT_ROLE");
}
