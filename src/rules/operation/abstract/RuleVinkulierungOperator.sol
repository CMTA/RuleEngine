// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
//import "../../../interfaces/IRuleOperation.sol";
import "./RuleVinkulierungInvariantStorage.sol";
import "CMTAT/interfaces/engine/IRuleEngine.sol";

// Emit id with the event
// Denied => Approve
/**
@title a whitelist manager
*/

abstract contract RuleVinkulierungOperator is AccessControl, RuleVinkulierungInvariantStorage {

    /**
    Improvement:
    - Update timeLimit
    - Open/remove require askin
    */
   
    // Time variable
    uint256 internal timeLimitToApprove = 7 days;
    uint256 internal timeLimitToTransfer = 30 days;

    mapping(bytes32 => TransferRequest) transferRequests;

    // Getter
    uint256 requestId;
    mapping(uint256 => bytes32) IdToKey;


    function updateTimeLimitForApproval(uint256 newTimeLimit) public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
        timeLimitToApprove = newTimeLimit;
    }

    function updateTimeLimitToTransfer(uint256 newTimeLimitToTransfer) public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
        timeLimitToTransfer  = newTimeLimitToTransfer;
    }


    function createTransferRequestWithApproval(
        address from, address to, uint256 value
    ) public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
        // WAIT => Will overwrite
        // APPROVED => will overwrite previous status with a new delay
        // DENIED => will overwrite
       bytes32 key =  keccak256(abi.encode(from, to, value));
            if(transferRequests[key].status == STATUS.NONE){
             TransferRequest memory newTransferApproval = TransferRequest({
                key: key,
                id: requestId,
                from: from,
                to: to,
                value: value,
                askTime:0,
                maxTime : block.timestamp + timeLimitToTransfer,
                status:STATUS.APPROVED
             });
            transferRequests[key] = newTransferApproval;
            IdToKey[requestId] = key;
            emit transferWaiting(key, from, to, value, requestId);
            ++requestId;
        } else {
            // Overwrite previous approval
            transferRequests[key].maxTime = block.timestamp + timeLimitToTransfer;
            transferRequests[key].status = STATUS.APPROVED;
            emit transferWaiting(key, from, to, value, transferRequests[key].id);
        }
    }


    function approveTransferRequest(
        address from, address to, uint256 value, bool isApproved_
    ) public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE) {
        bytes32 key =  keccak256(abi.encode(from, to, value));
        TransferRequest memory transferRequest = transferRequests[key];
        _approveRequest(transferRequest, isApproved_);
    }

    function _approveRequest(TransferRequest memory transferRequest , bool isApproved_) internal{
        // status
        if(transferRequest.status != STATUS.WAIT){
            revert RuleVinkulierung_Wrong_Status();
        }
        if(isApproved_){
             // Time
            if(block.timestamp > (transferRequest.askTime + timeLimitToApprove)){
                revert RuleVinkulierung_timeExceeded();
            }
            // Set status
            transferRequests[transferRequest.key].status = STATUS.APPROVED;
            // Set max time
            transferRequests[transferRequest.key].maxTime = block.timestamp + timeLimitToTransfer;
            emit transferApproved(transferRequest.key, transferRequest.from, transferRequest.to, transferRequest.value,  transferRequests[transferRequest.key].id );
        } else {
            transferRequests[transferRequest.key].status = STATUS.DENIED;
            emit transferDenied(transferRequest.key, transferRequest.from, transferRequest.to, transferRequest.value,  transferRequests[transferRequest.key].id );
        }

    }

    function approveTransferRequestWithId(
        uint256 requestId_, bool isApproved_
    ) public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
        if(requestId_ + 1 >  requestId) {
            revert RuleVinkulierung_InvalidId();
        }
        TransferRequest memory transferRequest = transferRequests[IdToKey[requestId_]];
        _approveRequest(transferRequest, isApproved_);
    }
}
