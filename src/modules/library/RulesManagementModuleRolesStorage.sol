// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract RulesManagementModuleRolesStorage {
    /* ==== Role === */
    bytes32 public constant RULES_MANAGEMENT_ROLE = keccak256("RULES_MANAGEMENT_ROLE");
}
