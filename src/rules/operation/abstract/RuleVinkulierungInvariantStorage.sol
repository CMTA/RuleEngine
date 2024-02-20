// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;


abstract contract RuleVinkulierungInvariantStorage  {
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
    bytes32 public constant RULE_ENGINE_ROLE = keccak256("RULE_ENGINE_ROLE");


    // error
    error RuleVinkulierung_AdminWithAddressZeroNotAllowed();
    error RuleVinkulierung_TransferAlreadyApproved();
    error RuleVinkulierung_Wrong_Status();
    error RuleVinkulierung_timeExceeded();
    error RuleVinkulierung_TransferDenied();
    error RuleVinkulierung_InvalidId();


    // Event
    event transferProcessed(bytes32 indexed key, address indexed from, address indexed  to, uint256 value);
    event transferWaiting(bytes32 indexed key, address indexed  from,address  indexed  to, uint256 value);
    event transferApproved(bytes32 indexed key, address indexed from, address indexed  to, uint256 value);
    event transferDenied(bytes32 indexed key, address indexed from, address indexed to, uint256 value);
}  