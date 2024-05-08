// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
* @title General functions of the RuleWhitelist
*/
contract RuleConditionalTransferTest is Test, HelperContract {
    RuleEngine ruleEngineMock;
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;
    uint256 defaultValue = 10;
    bytes32 defaultKey = keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));

    // Arrange
    function setUp() public {
        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: 7 days,
            timeLimitToTransfer: 30 days
        });
        
       AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: false,
            timeLimitBeforeAutomaticApproval: 0
        });

        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval:false,
            authorizedBurnWithoutApproval:false
        });
        AUTOMATIC_TRANSFER memory automaticTransfer_ = AUTOMATIC_TRANSFER({
            isActivate:false,
            cmtat: IERC20(address(0))
        });

        OPTION memory options = OPTION({
            issuance:issuanceOption_,
            timeLimit: timeLimit_,
            automaticApproval: automaticApproval_,
            automaticTransfer:automaticTransfer_
        });
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleConditionalTransfer = new RuleConditionalTransfer(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,                    
            options
        );
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleConditionalTransfer.grantRole(RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE, CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
    }

    function _createTransferRequest() internal{
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer.getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.from, ADDRESS1);
        assertEq(transferRequest.to, ADDRESS2);
        assertEq(transferRequest.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.WAIT));

        TransferRequest[] memory transferRequests = ruleConditionalTransfer.getRequestByStatus(STATUS.WAIT);
        assertEq(transferRequests[0].key , defaultKey);
        assertEq(transferRequests.length , 1);
    }

    function testCanCreateTransferRequest() public {
        _createTransferRequest();
    }

    /**
    * @dev test first
    */
    function testCanCreateTransferRequestWithApproval() public {
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        uint256 value = 10;
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(key, ADDRESS1, ADDRESS2, value, 0);
        ruleConditionalTransfer.createTransferRequestWithApproval(ADDRESS1, ADDRESS2, value);
    }

    /**
    * @dev test overwrite branch, previous approval
     */
    function testCanCreateTransferRequestWithApprovalAgain() public {
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        uint256 value = 10;
        // Arrange
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(key, ADDRESS1, ADDRESS2, value, 0);
        ruleConditionalTransfer.createTransferRequestWithApproval(ADDRESS1, ADDRESS2, value);

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(key, ADDRESS1, ADDRESS2, value, 0);
        ruleConditionalTransfer.createTransferRequestWithApproval(ADDRESS1, ADDRESS2, value);
    }
    


    /**** Request approval ****** */
    function testCanApproveRequestCreatedByHolder() public {
        // Arrange
        _createTransferRequest();
        
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0,true);
    }


    function testCanPartiallyApproveRequestCreatedByHolder() public {
        // Arrange
        _createTransferRequest();
        uint256 partialValue = 5;
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, partialValue));
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        emit transferWaiting(key, ADDRESS1, ADDRESS2, partialValue, 1);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, partialValue,true);
    }

    function testCanCreateAndApproveRequestCreatedByHolderAgain() public {
        // Arrange
        // First request
        _createTransferRequest();
        
        // First approval
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0, true);

        // Second request
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);

        // Second approval
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0, true);

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer.getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.from, ADDRESS1);
        assertEq(transferRequest.to, ADDRESS2);
        assertEq(transferRequest.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.APPROVED));
    }

    /****** ID *******/
    function testCanApproveRequestCreatedByHolderWithId() public {
        // Arrange
        _createTransferRequest();
        
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequestWithId( 0, true);


        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer.getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.from, ADDRESS1);
        assertEq(transferRequest.to, ADDRESS2);
        assertEq(transferRequest.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.APPROVED));
    }

    function testCannotApproveOrDeniedRequestCreatedByHolderWithWrongId() public {
        // Arrange
        _createTransferRequest();
        
        // Act
        // Approve
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidId.selector);
        ruleConditionalTransfer.approveTransferRequestWithId( 1, true);
        // Denied
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidId.selector);
        ruleConditionalTransfer.approveTransferRequestWithId( 1, false);
    }


    function testCanDeniedRequestCreatedByHolderWithId() public {
        // Arrange
        _createTransferRequest();
        
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequestWithId( 0, false);

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer.getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.from, ADDRESS1);
        assertEq(transferRequest.to, ADDRESS2);
        assertEq(transferRequest.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.DENIED));
    }

    /***** with key ******/
    function testCanDeniedRequestCreatedByHolder() public {
        // Arrange
        _createTransferRequest();
        
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2,  defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0,false);

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer.getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.from, ADDRESS1);
        assertEq(transferRequest.to, ADDRESS2);
        assertEq(transferRequest.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.DENIED));

        TransferRequest[] memory transferRequests = ruleConditionalTransfer.getRequestByStatus(STATUS.DENIED);
        assertEq(transferRequests[0].key , defaultKey);
        assertEq(transferRequests.length , 1);
    }

    function testCannotHolderCreateRequestIfDenied() public {
        // Arrange
        _createTransferRequest();
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2,  defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0,false);
    

        // Act
        vm.prank(ADDRESS1);
        vm.expectRevert(RuleConditionalTransfer_TransferDenied.selector);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);
    }

    /***** Reset  ********/

    function testHolderCanResetHisRequest() public {
        // Arrange
        _createTransferRequest();

        // Act 
        // Reset
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferReset(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.cancelTransferRequest(0);

        // Arrange
        // Second request with approval
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0,true);

        // Reset
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferReset(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.cancelTransferRequest(0);
    }

    function testHolderCannotResetRequestCreatedByOther() public {
        // Arrange
        _createTransferRequest();

        // Act 
        // Reset
        vm.prank(ADDRESS2);
        vm.expectRevert(RuleConditionalTransfer_InvalidSender.selector);
        ruleConditionalTransfer.cancelTransferRequest(0);
    }

    function testCannotHolderResetRequestWithWrongId() public {
        // Arrange
        _createTransferRequest();

        // Act 
        // Reset
        vm.prank(ADDRESS1);
        vm.expectRevert(RuleConditionalTransfer_InvalidId.selector);
        ruleConditionalTransfer.cancelTransferRequest(1);
    }

    function testCannotHolderResetRequestWithWrongStatus() public {
        // Arrange
        _createTransferRequest();

        // Denied
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0, false);

        // Act 
        // Reset
        vm.prank(ADDRESS1);
        vm.expectRevert(RuleConditionalTransfer_Wrong_Status.selector);
        ruleConditionalTransfer.cancelTransferRequest(0);
    }

    function testCanResetADeniedRequestCreatedByHolder() public {
        // Arrange
        _createTransferRequest();

        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0,false);

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferReset(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.resetRequestStatus(0);

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer.getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.from, ADDRESS1);
        assertEq(transferRequest.to, ADDRESS2);
        assertEq(transferRequest.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.NONE));

        // Assert
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);

        // Assert
        transferRequest = ruleConditionalTransfer.getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.from, ADDRESS1);
        assertEq(transferRequest.to, ADDRESS2);
        assertEq(transferRequest.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.WAIT));
    }


    function testCannotResetARequestIfWrongId() public {
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidId.selector);
        ruleConditionalTransfer.resetRequestStatus(10);
    }
    

    /****** Getter  *****/
    function testCanReturnTradeByStatus() public {
         // Arrange
         // First request 
        _createTransferRequest();

        // Change the status request to APPROVE
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0, false);

        // Second request
        uint256 value = 100;
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, value);

        // Act
        TransferRequest[] memory transferRequest = ruleConditionalTransfer.getRequestByStatus(STATUS.WAIT);
        // Assert
        assertEq(transferRequest.length, 1);
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        assertEq(transferRequest[0].key, key);
        assertEq(transferRequest[0].id, 1);
        assertEq(transferRequest[0].from, ADDRESS1);
        assertEq(transferRequest[0].to, ADDRESS2);
        assertEq(transferRequest[0].value, value);
        assertEq(uint256(transferRequest[0].status), uint256(STATUS.WAIT));

        // third request
        uint256 valueThird = 200;
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, valueThird);

        // Act
        transferRequest = ruleConditionalTransfer.getRequestByStatus(STATUS.WAIT);
        // Assert
        assertEq(transferRequest.length, 2);
        bytes32 keyThird = keccak256(abi.encode(ADDRESS1, ADDRESS2, valueThird));
        assertEq(transferRequest[1].key, keyThird);
        assertEq(transferRequest[1].id, 2);
        assertEq(transferRequest[1].from, ADDRESS1);
        assertEq(transferRequest[1].to, ADDRESS2);
        assertEq(transferRequest[1].value, valueThird);
        assertEq(uint256(transferRequest[1].status), uint256(STATUS.WAIT));
    }


    function testCannotApproveRequestIfTimeExceeded() public {
        // Arrange
        _createTransferRequest();
        
        // Timeout
        // 7 days *24*60*60 = 604800 seconds
        vm.warp(block.timestamp + 604801);
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_timeExceeded.selector);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0, true);
    }

    /*** Edge case ******/

    function testCannotApproveRequestIfWrongStatus() public {
        // Arrange
        // No create request
        
        // Timeout
        // 7 days *24*60*60 = 604800 seconds
        vm.warp(block.timestamp + 604801);
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_Wrong_Status.selector);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0, true);
    }

    function testCanSetTimeLimitWithTransferApprovalExceeded() public {
        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: 1 days,
            timeLimitToTransfer: 1 days
        });
        // Arrange
        _createTransferRequest();
        
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setTimeLimit(timeLimit_);

        // Assert
        // Timeout
        // >1 days
        vm.warp(block.timestamp + 1 days + 1 seconds);


        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_timeExceeded.selector);
        ruleConditionalTransfer.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, 0, true);
    }
}
