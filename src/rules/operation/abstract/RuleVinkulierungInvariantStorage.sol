// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import "OZ/token/ERC20/IERC20.sol";

abstract contract RuleVinkulierungInvariantStorage  {
    struct AUTOMATIC_TRANSFER {
        bool isActivate;
        IERC20 cmtat;
    }
    struct ISSUANCE {
        bool  authorizedMintWithoutApproval;
        bool  authorizedBurnWithoutApproval;
    }

    struct TIME_LIMIT {
        uint256 timeLimitToApprove;
        uint256 timeLimitToTransfer;
    }

    struct AUTOMATIC_APPROVAL {
        bool isActivate;
        uint256 timeLimitBeforeAutomaticApproval;
    }

    struct OPTION {
        ISSUANCE issuance;
        TIME_LIMIT timeLimit;
        AUTOMATIC_APPROVAL automaticApproval;
        AUTOMATIC_TRANSFER automaticTransfer;
    }
    
    enum STATUS { NONE, WAIT, APPROVED,  DENIED, EXECUTED, CANCELLED }
    struct TransferRequest {
        bytes32 key;
        uint256 id;
        address from;
        address to;
        uint256 value;
        uint256 askTime;
        uint256 maxTime;
        STATUS status;
    }

    // Role
    bytes32 public constant RULE_ENGINE_CONTRACT_ROLE = keccak256("RULE_ENGINE_CONTRACT_ROLE");
    bytes32 public constant RULE_VINKULIERUNG_OPERATOR_ROLE = keccak256("RULE_VINKULIERUNG_OPERATOR_ROLE");


    // error
    error RuleVinkulierung_AdminWithAddressZeroNotAllowed();
    error RuleVinkulierung_TransferAlreadyApproved();
    error RuleVinkulierung_Wrong_Status();
    error RuleVinkulierung_timeExceeded();
    error RuleVinkulierung_TransferDenied();
    error RuleVinkulierung_InvalidId();


    // Event
    event transferProcessed(bytes32 indexed key, address indexed from, address indexed  to, uint256 value, uint256 id);
    event transferWaiting(bytes32 indexed key, address indexed  from, address  indexed  to, uint256 value, uint256 id);
    event transferApproved(bytes32 indexed key, address indexed from, address indexed  to, uint256 value, uint256 id );
    event transferDenied(bytes32 indexed key, address indexed from, address indexed to, uint256 value, uint256 id);
    event transferReset(bytes32 indexed key, address indexed from, address indexed to, uint256 value, uint256 id);
}  