// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "./RuleConditionalTransferInvariantStorage.sol";
import "OZ/token/ERC20/utils/SafeERC20.sol"; 

/**
* @title a RuleConditionalTransfer manager
*/

abstract contract RuleConditionalTransferOperator is AccessControl, RuleConditionalTransferInvariantStorage {
    // Security
    using SafeERC20 for IERC20;
    
    OPTION internal options;

   
    // Getter
    uint256 public requestId;
    mapping(uint256 => bytes32) public IdToKey;
    mapping(bytes32 => TransferRequest) public transferRequests;


    function setIssuanceOptions(ISSUANCE calldata issuance_) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
        if(options.issuance.authorizedMintWithoutApproval != issuance_.authorizedMintWithoutApproval ){
            options.issuance.authorizedMintWithoutApproval = issuance_.authorizedMintWithoutApproval;
        }
        if(options.issuance.authorizedBurnWithoutApproval != issuance_.authorizedBurnWithoutApproval ){
            options.issuance.authorizedBurnWithoutApproval = issuance_.authorizedBurnWithoutApproval;
        }
    }

    function setAutomaticTransfer(AUTOMATIC_TRANSFER calldata automaticTransfer_) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
         if(automaticTransfer_.isActivate !=  options.automaticTransfer.isActivate){
            options.automaticTransfer.isActivate = automaticTransfer_.isActivate;
         }
         // No need to put the cmtat to zero to deactivate automaticTransfer
         if(address(automaticTransfer_.cmtat) != address(options.automaticTransfer.cmtat)){
            options.automaticTransfer.cmtat = automaticTransfer_.cmtat;
         }
    }

    /**
    * @notice set time limit for new requests (Approval and transfer)
    * Don't affect already created requests
    */
    function setTimeLimit(TIME_LIMIT memory timeLimit_)  public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
        if(options.timeLimit.timeLimitToApprove != timeLimit_.timeLimitToApprove){
            options.timeLimit.timeLimitToApprove = timeLimit_.timeLimitToApprove;
        }
        if(options.timeLimit.timeLimitToTransfer != timeLimit_.timeLimitToTransfer){
            options.timeLimit.timeLimitToTransfer = timeLimit_.timeLimitToTransfer;
        }
    }

    function setAutomaticApproval(AUTOMATIC_APPROVAL memory automaticApproval_)  public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
        if(options.automaticApproval.isActivate  != automaticApproval_.isActivate ){
             options.automaticApproval.isActivate = automaticApproval_.isActivate;
        }
        if(options.automaticApproval.timeLimitBeforeAutomaticApproval != automaticApproval_.timeLimitBeforeAutomaticApproval){
            options.automaticApproval.timeLimitBeforeAutomaticApproval = automaticApproval_.timeLimitBeforeAutomaticApproval;
        }
    }


    function createTransferRequestWithApproval(
        TransferRequestKeyElement calldata keyElement
    ) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
       _createTransferRequestWithApproval(keyElement);
    }

    /**
    @param keyElement contains from, to, value
    @param partialValue amount approved. Put 0 if all the amount specified by value is approved.
    @param isApproved_ approved (true) or refused (false). Put true if you use partialApproval
    */
    function approveTransferRequest(
        TransferRequestKeyElement calldata keyElement, uint256 partialValue, bool isApproved_
    ) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE) {
        _approveTransferRequestKeyElement(keyElement, partialValue, isApproved_);
    }

    function approveTransferRequestWithId(
        uint256 requestId_, bool isApproved_
    ) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
        if(requestId_ + 1 >  requestId) {
            revert RuleConditionalTransfer_InvalidId();
        }
        TransferRequest memory transferRequest = transferRequests[IdToKey[requestId_]];
        _approveRequest(transferRequest, isApproved_);
    } 


    function resetRequestStatus(
        uint256 requestId_
    ) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
        if(requestId_ + 1 >  requestId) {
            revert RuleConditionalTransfer_InvalidId();
        }
        bytes32 key = IdToKey[requestId_];
        _resetRequestStatus(key);
    }

    /***** Batch function */

    function approveTransferRequestBatchWithId(
        uint256[] calldata requestId_, bool[] calldata isApproved_
    ) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
        if(requestId_.length == 0){
            revert RuleConditionalTransfer_EmptyArray();
        }
        if(requestId_.length != isApproved_.length){
            revert RuleConditionalTransfer_InvalidLengthArray();
        }
        // Check id validity before performing actions
        for(uint256 i = 0; i < requestId_.length; ++i){
            if(requestId_[i] + 1 >  requestId) {
                revert RuleConditionalTransfer_InvalidId();
            }
        }
        for(uint256 i = 0; i < requestId_.length; ++i){
             TransferRequest memory transferRequest = transferRequests[IdToKey[requestId_[i]]];
            _approveRequest(transferRequest, isApproved_[i]);
        }
    }


    function approveTransferRequestBatch(
        TransferRequestKeyElement[] calldata keyElements, uint256[] calldata partialValues, bool[] calldata isApproved_
    ) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE) {
        if(keyElements.length == 0){
            revert RuleConditionalTransfer_EmptyArray();
        }
        if((keyElements.length != partialValues.length) || (partialValues.length != isApproved_.length)){
            revert RuleConditionalTransfer_InvalidLengthArray();
        }
        for(uint256 i = 0; i < keyElements.length; ++i){
            _approveTransferRequestKeyElement(keyElements[i], partialValues[i], isApproved_[i]);
        }
    }


    function createTransferRequestWithApprovalBatch(
         TransferRequestKeyElement[] calldata keyElements
    ) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
        if(keyElements.length == 0){
            revert RuleConditionalTransfer_EmptyArray();
        }
        for(uint256 i = 0; i < keyElements.length; ++i){
            _createTransferRequestWithApproval(keyElements[i]);
        }
    }


    function resetRequestStatusBatch(
        uint256[] memory requestIds
    ) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
        if(requestIds.length == 0){
            revert RuleConditionalTransfer_EmptyArray();
        }
        // Check id validity before performing actions
        for(uint256 i = 0; i < requestIds.length; ++i){
            if(requestIds[i] + 1 >  requestId) {
                revert RuleConditionalTransfer_InvalidId();
            }
        }
        for(uint256 i = 0; i < requestIds.length; ++i){
            bytes32 key = IdToKey[requestIds[i]];
            _resetRequestStatus(key);
        }
    }


    /*** Internal functions ****/

    function _approveTransferRequestKeyElement(
        TransferRequestKeyElement calldata keyElement, uint256 partialValue, bool isApproved_
    ) internal {
        if(partialValue > keyElement.value){
            revert RuleConditionalTransfer_InvalidValueApproved();
        }
        bytes32 key =  keccak256(abi.encode(keyElement.from, keyElement.to, keyElement.value));
        TransferRequest memory transferRequest = transferRequests[key];
        if(partialValue > 0 ){
            if(! isApproved_){
                revert RuleConditionalTransfer_CannotDeniedPartially();
            }
            // Denied the first request
            _approveRequest(transferRequest, false);
            // Create new request
            _createTransferRequestWithApproval(TransferRequestKeyElement({from: keyElement.from, to: keyElement.to, value: partialValue}));
        }else{
            _approveRequest(transferRequest, isApproved_);
        }
    }

    function _createTransferRequestWithApproval(
        TransferRequestKeyElement memory keyElement
    ) public onlyRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE){
        // WAIT => Will overwrite
        // APPROVED => will overwrite previous status with a new delay
        // DENIED => will overwrite
       bytes32 key =  keccak256(abi.encode(keyElement.from, keyElement.to, keyElement.value));
        // Status NONE not enough because reset is possible
        if(_checkRequestStatus(key)){
             TransferRequest memory newTransferApproval = TransferRequest({
                key: key,
                id: requestId,
                from: keyElement.from,
                to: keyElement.to,
                value: keyElement.value,
                askTime:0,
                maxTime : block.timestamp +  options.timeLimit.timeLimitToTransfer,
                status:STATUS.APPROVED
             });
            transferRequests[key] = newTransferApproval;
            IdToKey[requestId] = key;
            emit transferApproved(key, keyElement.from, keyElement.to, keyElement.value, requestId);
            ++requestId;
        } else {
            // Overwrite previous approval
            transferRequests[key].maxTime = block.timestamp +  options.timeLimit.timeLimitToTransfer;
            transferRequests[key].status = STATUS.APPROVED;
            emit transferApproved(key, keyElement.from, keyElement.to, keyElement.value, transferRequests[key].id);
        }
    }

    function _resetRequestStatus(
        bytes32 key
    ) internal {
        transferRequests[key].status = STATUS.NONE;
        emit transferReset(key,  transferRequests[key].from,  transferRequests[key].to,  transferRequests[key].value,   transferRequests[key].id );
    }

    function _checkRequestStatus(bytes32 key) internal view returns(bool) {
        return (transferRequests[key].status == STATUS.NONE) && (transferRequests[key].key == 0x0);
    }

    function _approveRequest(TransferRequest memory transferRequest , bool isApproved_) internal{
        // status
        if(transferRequest.status != STATUS.WAIT){
            revert RuleConditionalTransfer_Wrong_Status();
        }
        if(isApproved_){
            // Time
            if(block.timestamp > (transferRequest.askTime +  options.timeLimit.timeLimitToApprove)){
                revert RuleConditionalTransfer_timeExceeded();
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
                    options.automaticTransfer.cmtat.safeTransferFrom(transferRequest.from, transferRequest.to, transferRequest.value);
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
