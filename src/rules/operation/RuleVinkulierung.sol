// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "../../interfaces/IRuleOperation.sol";
import "./../../modules/MetaTxModuleStandalone.sol"; 
import "./abstract/RuleVinkulierungInvariantStorage.sol";
import "./abstract/RuleVinkulierungOperator.sol";
import "CMTAT/interfaces/engine/IRuleEngine.sol";

// Emit id with the event
// Denied => Approve
/**
* @title a whitelist manager
*/

contract RuleVinkulierung is IRuleOperation, MetaTxModuleStandalone, RuleVinkulierungOperator {
    /**
    * Improvement:
    * - Update timeLimit
    * - Open/remove require askin
    */

    /**
    * @param admin Address of the contract (Access Control)
    * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
    */
    constructor(
        address admin,
        address forwarderIrrevocable,
        IRuleEngine ruleEngineContract,
        OPTION memory options_
    ) MetaTxModuleStandalone(forwarderIrrevocable) {
        if(admin == address(0)){
            revert RuleVinkulierung_AdminWithAddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RULE_VINKULIERUNG_OPERATOR_ROLE, admin);
        if(address(ruleEngineContract) != address(0x0)){
            _grantRole(RULE_ENGINE_CONTRACT_ROLE, address(ruleEngineContract));
        }
        if(options_.timeLimit.timeLimitToApprove == 0){
            options_.timeLimit.timeLimitToApprove = type(uint64).max;
        }
        if(options_.timeLimit.timeLimitToTransfer == 0){
            options_.timeLimit.timeLimitToTransfer = type(uint64).max;
        }
        options = options_;
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
        uint256 requestIdLocal = requestId;
        // Status NONE not enough because reset is possible
        if(_checkRequestStatus(key)){
             TransferRequest memory newTransferApproval = TransferRequest({
                key:key,
                id: requestIdLocal,
                from: from,
                to:to,
                value:value,
                askTime: block.timestamp,
                maxTime:0, 
                status: STATUS.WAIT
             }
            );
            transferRequests[key] = newTransferApproval;
            IdToKey[requestIdLocal] = key;
            emit transferWaiting(key, from, to, value, requestId);
            ++requestId;
        } else {
            // Overwrite previous approval
            transferRequests[key].askTime = block.timestamp;
            transferRequests[key].status = STATUS.WAIT;
            emit transferWaiting(key, from, to, value, transferRequests[key].id);
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
        for (uint i = 0; i < totalRequestCount; ++i) {
            if (transferRequests[IdToKey[i]].status == _targetStatus) {
                requestCount += 1;
            }
        }

        // We reserve the memory to store the trade
        TransferRequest[] memory requests = new TransferRequest[](requestCount);

        // We create an array with the list of trade
        for (uint i = 0; i < totalRequestCount; ++i) {
            if (transferRequests[IdToKey[i]].status == _targetStatus) {
                //uint currentId = i + 1;
                TransferRequest memory currentRequest = transferRequests[IdToKey[i]];
                requests[currentIndex] = currentRequest;
                currentIndex += 1;
            }
        }

        return requests;
    }



    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     * Add access control with the RuleEngine
     */
    function operateOnTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public override onlyRole(RULE_ENGINE_CONTRACT_ROLE) returns(bool isValid){
        // Mint & Burn
        if(
            (_from == address(0) && options.issuance.authorizedMintWithoutApproval)
            ||  (_to == address(0) && options.issuance.authorizedBurnWithoutApproval)
        ){
            return true;
        }
        bytes32 key = keccak256(abi.encode(_from, _to, _amount));
        bool automaticApprovalCondition = options.automaticApproval.isActivate && ((transferRequests[key].askTime + options.automaticApproval.timeLimitBeforeAutomaticApproval ) >= block.timestamp);
        bool transferApproved = (transferRequests[key].status == STATUS.APPROVED) 
            && (transferRequests[key].maxTime >= block.timestamp);
        if(automaticApprovalCondition || transferApproved)
        {
            _updateProcessedTransfer(key);
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
        override(ERC2771Context, Context)
        returns (address sender)
    {
        return ERC2771Context._msgSender();
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgData()
        internal
        view
        override(ERC2771Context, Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _contextSuffixLength() internal view override(ERC2771Context, Context) returns (uint256) {
        return ERC2771Context._contextSuffixLength();
    }
}
