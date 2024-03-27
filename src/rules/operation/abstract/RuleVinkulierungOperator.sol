// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "./RuleVinkulierungInvariantStorage.sol";
import "CMTAT/interfaces/engine/IRuleEngine.sol";

// Emit id with the event
// Denied => Approve
/**
@title a RuleVinkulierung manager
*/

abstract contract RuleVinkulierungOperator is AccessControl, RuleVinkulierungInvariantStorage {
    // Time variable
    //uint256 internal timeLimitToApprove = 7 days;
    // uint256 internal timeLimitToTransfer = 30 days;

    OPTION internal options;

    mapping(bytes32 => TransferRequest) transferRequests;

    // Getter
    uint256 requestId;
    mapping(uint256 => bytes32) IdToKey;

    function setIssuanceOptions(ISSUANCE calldata issuance_) public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
        options.issuance.authorizedBurnWithoutApproval = issuance_.authorizedBurnWithoutApproval;
        options.issuance.authorizedMintWithoutApproval = issuance_.authorizedMintWithoutApproval;
    }

    function setAutomaticTransfer(AUTOMATIC_TRANSFER calldata automaticTransfer_) public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
         if(automaticTransfer_.isActivate !=  options.automaticTransfer.isActivate){
            options.automaticTransfer.isActivate = automaticTransfer_.isActivate;
         }
         // No need to put the cmtat to zero to deactivate automaticTransfer
         if(address(automaticTransfer_.cmtat) != address(options.automaticTransfer.cmtat)){
            options.automaticTransfer.cmtat = automaticTransfer_.cmtat;
         }
    }

    function setTimeLimit(TIME_LIMIT memory timeLimit_)  public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
         options.timeLimit.timeLimitToApprove = timeLimit_.timeLimitToApprove;
         options.timeLimit.timeLimitToTransfer = timeLimit_.timeLimitToTransfer;
    }

    function setAutomaticApproval(AUTOMATIC_APPROVAL memory automaticApproval_)  public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
         options.automaticApproval.isActivate = automaticApproval_.isActivate;
         options.automaticApproval.timeLimitBeforeAutomaticApproval = automaticApproval_.timeLimitBeforeAutomaticApproval;
    }


    function createTransferRequestWithApproval(
        address from, address to, uint256 value
    ) public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
        // WAIT => Will overwrite
        // APPROVED => will overwrite previous status with a new delay
        // DENIED => will overwrite
       bytes32 key =  keccak256(abi.encode(from, to, value));
        // Status NONE not enough because reset is possible
        if(_checkRequestStatus(key)){
             TransferRequest memory newTransferApproval = TransferRequest({
                key: key,
                id: requestId,
                from: from,
                to: to,
                value: value,
                askTime:0,
                maxTime : block.timestamp +  options.timeLimit.timeLimitToTransfer,
                status:STATUS.APPROVED
             });
            transferRequests[key] = newTransferApproval;
            IdToKey[requestId] = key;
            emit transferWaiting(key, from, to, value, requestId);
            ++requestId;
        } else {
            // Overwrite previous approval
            transferRequests[key].maxTime = block.timestamp +  options.timeLimit.timeLimitToTransfer;
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

    function approveTransferRequestWithId(
        uint256 requestId_, bool isApproved_
    ) public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
        if(requestId_ + 1 >  requestId) {
            revert RuleVinkulierung_InvalidId();
        }
        TransferRequest memory transferRequest = transferRequests[IdToKey[requestId_]];
        _approveRequest(transferRequest, isApproved_);
    }

    function resetRequestStatus(
        uint256 requestId_
    ) public onlyRole(RULE_VINKULIERUNG_OPERATOR_ROLE){
        if(requestId_ + 1 >  requestId) {
            revert RuleVinkulierung_InvalidId();
        }
        bytes32 key = IdToKey[requestId_];
        transferRequests[key].status = STATUS.NONE;
        emit transferReset(key,  transferRequests[key].from,  transferRequests[key].to,  transferRequests[key].value,   transferRequests[key].id );
    }

    function _checkRequestStatus(bytes32 key) internal view returns(bool) {
        return (transferRequests[key].status == STATUS.NONE) && (transferRequests[key].key == 0x0);
    }

    function _approveRequest(TransferRequest memory transferRequest , bool isApproved_) internal{
        // status
        if(transferRequest.status != STATUS.WAIT){
            revert RuleVinkulierung_Wrong_Status();
        }
        if(isApproved_){
            // Time
            if(block.timestamp > (transferRequest.askTime +  options.timeLimit.timeLimitToApprove)){
                revert RuleVinkulierung_timeExceeded();
            }
            // Set status
            transferRequests[transferRequest.key].status = STATUS.APPROVED;
            // Set max time
            transferRequests[transferRequest.key].maxTime = block.timestamp +  options.timeLimit.timeLimitToTransfer;
            emit transferApproved(transferRequest.key, transferRequest.from, transferRequest.to, transferRequest.value,  transferRequests[transferRequest.key].id );
            if(options.automaticTransfer.isActivate && address(options.automaticTransfer.cmtat) != address(0)){
                // Transfer with approval
                // External call
                if(options.automaticTransfer.cmtat.allowance(transferRequest.from, address(this)) >= transferRequest.value){
                     //_updateProcessedTransfer(transferRequest.key);
                     // Will call the ruleEngine and the rule again...
                    options.automaticTransfer.cmtat.transferFrom(transferRequest.from, transferRequest.to, transferRequest.value);
                } 
            }
        } else {
            transferRequests[transferRequest.key].status = STATUS.DENIED;
            emit transferDenied(transferRequest.key, transferRequest.from, transferRequest.to, transferRequest.value,  transferRequests[transferRequest.key].id );
        }
    }

    function _updateProcessedTransfer(bytes32 key) internal {
            // Reset to zero
            transferRequests[key].maxTime = 0;
            transferRequests[key].askTime = 0;
            // Change status
            transferRequests[key].status = STATUS.EXECUTED;
            // Emit event
            emit transferProcessed(key, transferRequests[key].from, transferRequests[key].to,  transferRequests[key].value, transferRequests[key].id);
    }
}
