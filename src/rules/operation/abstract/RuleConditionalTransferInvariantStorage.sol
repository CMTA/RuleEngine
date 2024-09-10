// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import "OZ/token/ERC20/IERC20.sol";

import "../../validation/abstract/RuleCommonInvariantStorage.sol";
import "src/rules/validation/RuleWhitelist.sol";

abstract contract RuleConditionalTransferInvariantStorage is
    RuleCommonInvariantStorage
{
    /* ============ Struct ============ */
    /**
     * perform automatically a transfer if the transfer request is approved.
     * To perform the transfer, the token holder has to approve the rule to spend tokens on his behalf (standard ERC-20 approval).
     * If the allowance is not sufficient, the request will be approved, but without performing the transfer.
     */
    struct AUTOMATIC_TRANSFER {
        bool isActivate;
        IERC20 cmtat;
    }

    struct ISSUANCE {
        // Authorize mint without the need of approval
        bool authorizedMintWithoutApproval;
        // Authorize burn without the need of approval
        bool authorizedBurnWithoutApproval;
    }

    struct TIME_LIMIT {
        // time limit for an operator to approve a request
        uint256 timeLimitToApprove;
        // once a request is approved, time limit for the token holder to perform the transfer
        uint256 timeLimitToTransfer;
    }

    struct AUTOMATIC_APPROVAL {
        bool isActivate;
        /**
         * If the transfer is not approved or denied within {timeLimitBeforeAutomaticApproval},
         * the request is considered as approved during a transfer.
         */
        uint256 timeLimitBeforeAutomaticApproval;
    }

    struct OPTION {
        ISSUANCE issuance;
        TIME_LIMIT timeLimit;
        AUTOMATIC_APPROVAL automaticApproval;
        AUTOMATIC_TRANSFER automaticTransfer;
    }

    struct TransferRequestKeyElement {
        address from;
        address to;
        uint256 value;
    }

    struct TransferRequest {
        bytes32 key;
        uint256 id;
        TransferRequestKeyElement keyElement;
        uint256 askTime;
        uint256 maxTime;
        STATUS status;
    }
    /* ============ Enum ============ */
    enum STATUS {
        NONE,
        WAIT,
        APPROVED,
        DENIED,
        EXECUTED
    }

    /* ============ Role ============ */
    bytes32 public constant RULE_ENGINE_CONTRACT_ROLE =
        keccak256("RULE_ENGINE_CONTRACT_ROLE");
    bytes32 public constant RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE =
        keccak256("RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE");

    /* ============ State variables ============ */
    string constant TEXT_TRANSFER_REQUEST_NOT_APPROVED =
        "The request is not approved";
    // Code
    // It is very important that each rule uses an unique code
    uint8 public constant CODE_TRANSFER_REQUEST_NOT_APPROVED = 51;

    /* ============ Custom error ============ */
    error RuleConditionalTransfer_AdminWithAddressZeroNotAllowed();
    error RuleConditionalTransfer_TransferAlreadyApproved();
    error RuleConditionalTransfer_Wrong_Status();
    error RuleConditionalTransfer_timeExceeded();
    error RuleConditionalTransfer_TransferDenied();
    error RuleConditionalTransfer_InvalidId();
    error RuleConditionalTransfer_InvalidSender();
    error RuleConditionalTransfer_InvalidValueApproved();
    error RuleConditionalTransfer_CannotDeniedPartially();
    error RuleConditionalTransfer_InvalidLengthArray();
    error RuleConditionalTransfer_EmptyArray();

    /* ============ Events ============ */
    event transferProcessed(
        bytes32 indexed key,
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 id
    );
    event transferWaiting(
        bytes32 indexed key,
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 id
    );
    event transferApproved(
        bytes32 indexed key,
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 id
    );
    event transferDenied(
        bytes32 indexed key,
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 id
    );
    event transferReset(
        bytes32 indexed key,
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 id
    );

    event WhitelistConditionalTransfer(
        RuleWhitelist indexed whitelistConditionalTransfer
    );
}
