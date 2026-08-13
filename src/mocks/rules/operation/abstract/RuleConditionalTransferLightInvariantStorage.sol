// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {RuleCommonInvariantStorage} from "../../validation/abstract/RuleCommonInvariantStorage.sol";

/**
 * @title RuleConditionalTransferLightInvariantStorage
 * @notice Roles, codes, errors and events for the conditional-transfer rule.
 */
abstract contract RuleConditionalTransferLightInvariantStorage is RuleCommonInvariantStorage {
    /* ============ Role ============ */
    /**
     * @notice Role held by the RuleEngine allowed to consume approvals.
     */
    bytes32 public constant RULE_ENGINE_CONTRACT_ROLE = keccak256("RULE_ENGINE_CONTRACT_ROLE");
    /**
     * @notice Role allowed to approve transfers.
     */
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /* ============ State variables ============ */
    /**
     * @notice Message returned when the transfer was not approved.
     */
    string constant TEXT_TRANSFER_REQUEST_NOT_APPROVED = "ConditionalTransferLight: The request is not approved";
    // Code
    // It is very important that each rule uses an unique code
    /**
     * @notice Restriction code raised when the transfer was not approved.
     */
    uint8 public constant CODE_TRANSFER_REQUEST_NOT_APPROVED = 71;

    /* ============ Custom error ============ */
    error TransferNotApproved();
    error RuleConditionalTransferLight_AdminAddressZeroNotAllowed();

    /* ============ Events ============ */
    /**
     * @notice Emitted when an operator approves a transfer.
     * @param from The origin address of the approved transfer.
     * @param to The destination address of the approved transfer.
     * @param value The amount approved.
     * @param count The number of outstanding approvals after this one.
     */
    event TransferApproved(address indexed from, address indexed to, uint256 value, uint256 count);
    /**
     * @notice Emitted when an approved transfer is consumed.
     * @param from The origin address of the transfer.
     * @param to The destination address of the transfer.
     * @param value The amount transferred.
     * @param remaining The number of approvals still outstanding.
     */
    event TransferExecuted(address indexed from, address indexed to, uint256 value, uint256 remaining);
}
