// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "../../interfaces/IRuleOperation.sol";
import "./../../modules/MetaTxModuleStandalone.sol";
import "./abstract/RuleVinkulierungInvariantStorage.sol";

/**
@title a whitelist manager
*/

contract RuleVinkulierung is IRuleOperation, AccessControl, MetaTxModuleStandalone, RuleVinkulierungInvariantStorage {

    /**
    Improvement:
    - Update timeLimit
    - Open/remove require askin
    */
   
    // Time variable
    uint256 timeLimitToApprove = 7 days;
    uint256 timeLimitToTransfer = 30 days;

    mapping(bytes32 => TransferRequest) transferRequests;

    // Getter
    uint256 requestId;
    mapping(uint256 => bytes32) IdToKey;


    
    /**
    * @param admin Address of the contract (Access Control)
    * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
    */
    constructor(
        address admin,
        address forwarderIrrevocable,
        address ruleEngineContract
    ) MetaTxModuleStandalone(forwarderIrrevocable) {
        if(admin == address(0)){
            revert RuleVinkulierung_AdminWithAddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RULE_ENGINE_ROLE, ruleEngineContract);
    }

    function createTransferRequest(
        address to, uint256 value
    ) public {
        // WAIT => Will set a new delay to approve
        // APPROVED => will overwrite previous status
        // DENIED => KO
        address from = _msgSender();
        bytes32 key = keccak256(abi.encode(from, to, value));
        if(transferRequests[key].status == STATUS.DENIED){
           revert RuleVinkulierung_TransferDenied();
        }
        if(transferRequests[key].status == STATUS.NONE){
             TransferRequest memory newTransferApproval = TransferRequest({
                key:key,
                id: requestId,
                from: from,
                to:to,
                value:value,
                askTime: block.timestamp,
                maxTime:0, 
                status: STATUS.WAIT
             }
            );
            transferRequests[key] = newTransferApproval;
            IdToKey[requestId] = key;
            ++requestId;
        } else {
            // Overwrite previous approval
            transferRequests[key].from = from;
            transferRequests[key].to = to;
            transferRequests[key].value = value;
            transferRequests[key].askTime = block.timestamp;
            transferRequests[key].status = STATUS.WAIT;
        }
        emit transferWaiting(key, from, to, value);
    }

    function createTransferRequestWithApproval(
        address to, uint256 value
    ) public {
        // WAIT => Will overwrite
        // APPROVED => will overwrite previous status with a new delay
        // DENIED => will overwrite
       address from = _msgSender();
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
            ++requestId;
            transferRequests[key] = newTransferApproval;
        } else {
            // Overwrite previous approval
            transferRequests[key].from = from;
            transferRequests[key].to = to;
            transferRequests[key].value = value;
            transferRequests[key].maxTime = block.timestamp + timeLimitToTransfer;
            transferRequests[key].status = STATUS.APPROVED;
        }
    }

    function getRequestTrade(address from, address to, uint256 value) public view returns (TransferRequest memory) {
        bytes32 key = keccak256(abi.encode(from, to, value));
        return transferRequests[key];
    }

    /**
     * @notice get Trade by status
     * @param  _targetStatus The status of the transactions you want to retrieve
     * @return array with corresponding transactions
     */
    function getRequestByStatus(STATUS _targetStatus) public view returns (TransferRequest[] memory) {
        uint totalRequestCount = requestId;
        uint requestCount = 0;
        uint currentIndex = 0;

        // We count the number of requests matching the criteria
        for (uint i = 0; i < totalRequestCount; i++) {
            if (transferRequests[IdToKey[i + 1]].status == _targetStatus) {
                requestCount += 1;
            }
        }

        // We reserve the memory to store the trade
        TransferRequest[] memory requests = new TransferRequest[](requestCount);

        // We create an array with the list of trade
        for (uint i = 0; i < totalRequestCount; i++) {
            if (transferRequests[IdToKey[i + 1]].status == _targetStatus) {
                uint currentId = i + 1;
                TransferRequest memory currentRequest = transferRequests[IdToKey[currentId]];
                requests[currentIndex] = currentRequest;
                currentIndex += 1;
            }
        }

        return requests;
    }

    function approveTransferRequest(
        address from, address to, uint256 value, bool isApproved_
    ) public {
        bytes32 key =  keccak256(abi.encode(from, to, value));
        // status
        if(transferRequests[key].status != STATUS.WAIT){
            revert RuleVinkulierung_Wrong_Status();
        }
        if(isApproved_){
             // Time
            if(transferRequests[key].askTime > timeLimitToApprove){
                revert RuleVinkulierung_timeExceeded();
            }
            // Set status
            transferRequests[key].status = STATUS.APPROVED;
            // Set max time
            transferRequests[key].maxTime = block.timestamp + timeLimitToTransfer;
            emit transferApproved(key, from, to, value);
        } else {
             transferRequests[key].status = STATUS.DENIED;
        }
    }

    function approveTransferRequestWithId(
        uint256 requestId_, bool isApproved_
    ) public {
        if(requestId_ + 1 >  requestId) {
            revert RuleVinkulierung_InvalidId();
        }
        TransferRequest memory transferRequest = transferRequests[IdToKey[requestId_]];
        if(isApproved_){
            // status
            if(transferRequest.status != STATUS.WAIT){
                revert RuleVinkulierung_Wrong_Status();
            }
            // Time
            if(transferRequest.askTime > timeLimitToApprove){
                revert RuleVinkulierung_timeExceeded();
            }
            // Set status
            transferRequests[transferRequest.key].status = STATUS.APPROVED;
            // Set max time
            transferRequests[transferRequest.key].maxTime = block.timestamp + timeLimitToTransfer;

            emit transferApproved(transferRequest.key, transferRequest.from, transferRequest.to, transferRequest.value);
        } else{
            transferRequests[transferRequest.key].status = STATUS.DENIED;
        }
    }


    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     * Add access control with the RuleEngine
     */
    function operateOnTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public override onlyRole(RULE_ENGINE_ROLE) returns(bool isValid){
        bytes32 key = keccak256(abi.encode(_from, _to, _amount));
        if(transferRequests[key].status == STATUS.APPROVED && transferRequests[key].maxTime <= block.timestamp){
            // we archive the demand
            // transferRequestsArchive.push(transferRequests[key]);
            // Reset to zero
            transferRequests[key].maxTime = 0;
            transferRequests[key].askTime = 0;
            // Change status
            transferRequests[key].status = STATUS.EXECUTED;
            // Emit event
            emit transferProcessed(key, _from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgSender()
        internal
        view
        override(MetaTxModuleStandalone, Context)
        returns (address sender)
    {
        return MetaTxModuleStandalone._msgSender();
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgData()
        internal
        view
        override(MetaTxModuleStandalone, Context)
        returns (bytes calldata)
    {
        return MetaTxModuleStandalone._msgData();
    }
}
