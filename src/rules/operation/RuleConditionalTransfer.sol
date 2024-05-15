// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "../../interfaces/IRuleOperation.sol";
import "./../../modules/MetaTxModuleStandalone.sol"; 
import "./abstract/RuleConditionalTransferInvariantStorage.sol";
import "./abstract/RuleConditionalTransferOperator.sol";
import "../validation/abstract/RuleValidateTransfer.sol";
import "CMTAT/interfaces/engine/IRuleEngine.sol";

/**
* @title a whitelist manager
*/

contract RuleConditionalTransfer is  RuleValidateTransfer, IRuleOperation, RuleConditionalTransferOperator, MetaTxModuleStandalone {
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
            revert RuleConditionalTransfer_AdminWithAddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE, admin);
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

    /**
    * @notice Create a request of transfer for yourselves
    * @param to recipient of tokens
    * @param value amount of tokens to transfer
    */
    function createTransferRequest(
        address to, uint256 value
    ) public {
        // WAIT => Will set a new delay to approve
        // APPROVED => will overwrite previous status
        // DENIED => reject
        address from = _msgSender();
        bytes32 key = keccak256(abi.encode(from, to, value));
        if(transferRequests[key].status == STATUS.DENIED){
           revert RuleConditionalTransfer_TransferDenied();
        }
        if(_checkRequestStatus(key)){
             uint256 requestIdLocal = requestId;
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

    /**
    * @notice Batch version of {createTransferRequest}
    */
    function createTransferRequestBatch(address[] memory tos, uint256[] memory values) public{
        if(tos.length == 0){
            revert RuleConditionalTransfer_EmptyArray();
        }
        if(tos.length != values.length){
            revert RuleConditionalTransfer_InvalidLengthArray();
        }
        for(uint256 i = 0; i < tos.length; ++i){
            createTransferRequest(tos[i], values[i]);
        }
    }

    /**
    * @notice allow a token holder to cancel/reset his own request
    */
    function cancelTransferRequest(
        uint256 requestId_
    ) public {
        _cancelTransferRequest(requestId_);
    }

    /**
    * @notice allow a token holder to cancel/reset his own request
    */
    function cancelTransferRequestBatch(
        uint256[] memory requestIds
    ) public {
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
            _cancelTransferRequest(requestIds[i]);
        }
        
    }

    function _cancelTransferRequest(
        uint256 requestId_
    ) internal {
        if(requestId_ + 1 >  requestId) {
            revert RuleConditionalTransfer_InvalidId();
        }
        bytes32 key = IdToKey[requestId_];
        // Check Sender
        if(transferRequests[key].from != _msgSender()){
            revert RuleConditionalTransfer_InvalidSender();
        }
        // Check status
        if(transferRequests[key].status != STATUS.WAIT
        && transferRequests[key].status != STATUS.APPROVED
        ){
            revert RuleConditionalTransfer_Wrong_Status();
        }
        _resetRequestStatus(key);
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
        // No need of approval if from and to are in the whitelist
        if(address(whitelistConditionalTransfer) != address(0)){
            if(whitelistConditionalTransfer.addressIsListed(_from) && whitelistConditionalTransfer.addressIsListed(_to)){
                return true;
            }      
        }

        // Mint & Burn
        if(_validateBurnMint(_from, _to)) {
            return true;
        }
        bytes32 key = keccak256(abi.encode(_from, _to, _amount));
        if(_validateApproval(key)) {
                _updateProcessedTransfer(key);
                return true;
        } else {
                return false;
        }
    }

    /** 
    * @notice Check if the transfer is valid
    * @param _from the origin address
    * @param _to the destination address
    * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
    **/
    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (uint8) {
        // No need of approval if from and to are in the whitelist
        if(address(whitelistConditionalTransfer) != address(0)){
            if(whitelistConditionalTransfer.addressIsListed(_from) && whitelistConditionalTransfer.addressIsListed(_to)){
                return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
            }      
        }
        bytes32 key = keccak256(abi.encode(_from, _to, _amount));
        if (!_validateBurnMint(_from,_to) && !_validateApproval(key)) {
            return CODE_TRANSFER_REQUEST_NOT_APPROVED;
        }
        else {
            return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    /** 
    * @notice To know if the restriction code is valid for this rule or not.
    * @param _restrictionCode The target restriction code
    * @return true if the restriction code is known, false otherwise
    **/
    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external pure override returns (bool) {
        return
            _restrictionCode == CODE_TRANSFER_REQUEST_NOT_APPROVED;
    }

    /** 
    * @notice Return the corresponding message
    * @param _restrictionCode The target restriction code
    * @return true if the transfer is valid, false otherwise
    **/
    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external pure override returns (string memory) {
        if (_restrictionCode == CODE_TRANSFER_REQUEST_NOT_APPROVED) {
            return TEXT_TRANSFER_REQUEST_NOT_APPROVED;
        } else {
            return TEXT_CODE_NOT_FOUND;
        }
    }

    /**
     * 
     * @dev 
     * Test burn and mint condition
     * Returns true if the transfer is valid, and false otherwise.
     *
     */
    function _validateBurnMint(
        address _from,
        address _to
    ) internal view returns(bool isValid){
        // Mint & Burn
        if(
            (_from == address(0) && options.issuance.authorizedMintWithoutApproval)
            ||  (_to == address(0) && options.issuance.authorizedBurnWithoutApproval)
        ){
            return true;
        }
        return false;
    }

    /**
     * 
     * @dev 
     * Test transfer approval condition
     * Returns true if the transfer is valid, and false otherwise.
     */
    function _validateApproval(
        bytes32 key
    ) internal view returns(bool isValid){
        bool automaticApprovalCondition = options.automaticApproval.isActivate && ((transferRequests[key].askTime + options.automaticApproval.timeLimitBeforeAutomaticApproval ) >= block.timestamp);
        bool isTransferApproved = (transferRequests[key].status == STATUS.APPROVED) 
            && (transferRequests[key].maxTime >= block.timestamp);
        if(automaticApprovalCondition || isTransferApproved)
        {
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
