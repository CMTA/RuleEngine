// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import "OZ/token/ERC20/IERC20.sol";

import "../../validation/abstract/RuleCommonInvariantStorage.sol";
import "src/mocks/rules/validation/RuleWhitelist.sol";

abstract contract RuleConditionalTransferLightInvariantStorage is
    RuleCommonInvariantStorage
{
    /* ============ Role ============ */
    bytes32 public constant RULE_ENGINE_CONTRACT_ROLE =
        keccak256("RULE_ENGINE_CONTRACT_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /* ============ State variables ============ */
    string constant TEXT_TRANSFER_REQUEST_NOT_APPROVED =
        "ConditionalTransferLight: The request is not approved";
    // Code
    // It is very important that each rule uses an unique code
    uint8 public constant CODE_TRANSFER_REQUEST_NOT_APPROVED = 71;

    /* ============ Custom error ============ */
    error TransferNotApproved();

    /* ============ Events ============ */
    event TransferApproved(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 count
    );
    event TransferExecuted(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 remaining
    );
}
