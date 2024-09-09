// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
 * @title General functions of the RuleWhitelist
 */
contract RuleConditionalTransferResetTest is Test, HelperContract {
    RuleEngine ruleEngineMock;
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;
    uint256 defaultValue = 10;
    bytes32 defaultKey =
        keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));

    TransferRequestKeyElement transferRequestInput =
        TransferRequestKeyElement({
            from: ADDRESS1,
            to: ADDRESS2,
            value: defaultValue
        });

    uint256 value2 = 1;
    uint256 value3 = 2;
    uint256 value4 = 1000;
    uint256 value5 = 2000;
    bytes32 key2 = keccak256(abi.encode(ADDRESS1, ADDRESS2, value2));
    bytes32 key3 = keccak256(abi.encode(ADDRESS2, ADDRESS1, value3));
    bytes32 key3Hodler = keccak256(abi.encode(ADDRESS1, ADDRESS2, value3));
    bytes32 key4 = keccak256(abi.encode(ADDRESS1, ADDRESS2, value4));
    bytes32 key5 = keccak256(abi.encode(ADDRESS1, ADDRESS2, value5));

    TransferRequestKeyElement transferRequestInput2 =
        TransferRequestKeyElement({
            from: ADDRESS1,
            to: ADDRESS2,
            value: value2
        });

    TransferRequestKeyElement transferRequestInput3 =
        TransferRequestKeyElement({
            from: ADDRESS2,
            to: ADDRESS1,
            value: value3
        });

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
            authorizedMintWithoutApproval: false,
            authorizedBurnWithoutApproval: false
        });
        AUTOMATIC_TRANSFER memory automaticTransfer_ = AUTOMATIC_TRANSFER({
            isActivate: false,
            cmtat: IERC20(address(0))
        });

        OPTION memory options = OPTION({
            issuance: issuanceOption_,
            timeLimit: timeLimit_,
            automaticApproval: automaticApproval_,
            automaticTransfer: automaticTransfer_
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
        ruleConditionalTransfer.grantRole(
            RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE,
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS
        );
    }

    function _createTransferRequestBatch() public {
        // Arrange
        _createTransferRequest();

        // Second and third request
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, value2);
        vm.prank(ADDRESS2);
        ruleConditionalTransfer.createTransferRequest(ADDRESS1, value3);
    }

    function _createTransferRequestBatchByHodler() public {
        // Arrange
        _createTransferRequest();

        // Second and third request
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, value2);
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, value3);
    }

    function _createTransferRequest() internal {
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer
            .getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.WAIT));

        TransferRequest[] memory transferRequests = ruleConditionalTransfer
            .getRequestByStatus(STATUS.WAIT);
        assertEq(transferRequests[0].key, defaultKey);
        assertEq(transferRequests.length, 1);
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
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );

        // Reset
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferReset(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.cancelTransferRequest(0);

        // Can create a new request
        // Id different from 0
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(key2, ADDRESS1, ADDRESS2, value2, 1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, value2);

        // Can be cancel again
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferReset(key2, ADDRESS1, ADDRESS2, value2, 1);
        ruleConditionalTransfer.cancelTransferRequest(1);
    }

    function testHolderCanBatchResetHisRequest() public {
        // Arrange
        _createTransferRequestBatchByHodler();
        uint256[] memory ids = new uint256[](3);
        ids[0] = 0;
        ids[1] = 1;
        ids[2] = 2;
        // Act
        // Reset
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferReset(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.expectEmit(true, true, true, true);
        emit transferReset(key2, ADDRESS1, ADDRESS2, value2, 1);
        vm.expectEmit(true, true, true, true);
        emit transferReset(key3Hodler, ADDRESS1, ADDRESS2, value3, 2);
        ruleConditionalTransfer.cancelTransferRequestBatch(ids);
    }

    function testHolderCannotBatchResetHisRequestWithWrongId() public {
        // Arrange
        _createTransferRequestBatchByHodler();
        uint256[] memory ids = new uint256[](3);
        ids[0] = 0;
        ids[1] = 4;
        ids[2] = 2;
        // Act
        // Reset
        vm.prank(ADDRESS1);
        vm.expectRevert(RuleConditionalTransfer_InvalidId.selector);
        ruleConditionalTransfer.cancelTransferRequestBatch(ids);
    }

    function testHolderCannotBatchResetHisRequestWithEmptyArray() public {
        // Arrange
        _createTransferRequestBatchByHodler();
        uint256[] memory ids = new uint256[](0);
        // Act
        // Reset
        vm.prank(ADDRESS1);
        vm.expectRevert(RuleConditionalTransfer_EmptyArray.selector);
        ruleConditionalTransfer.cancelTransferRequestBatch(ids);
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
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            false
        );

        // Act
        // Reset
        vm.prank(ADDRESS1);
        vm.expectRevert(RuleConditionalTransfer_Wrong_Status.selector);
        ruleConditionalTransfer.cancelTransferRequest(0);
    }

    /***** Reset */

    function testCanResetADeniedRequestCreatedByHolder() public {
        // Arrange
        _createTransferRequest();

        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            false
        );

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferReset(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.resetRequestStatus(0);

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer
            .getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.NONE));

        // Assert
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);

        // Assert
        transferRequest = ruleConditionalTransfer.getRequestTrade(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.WAIT));

        // Id different from 0
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(key2, ADDRESS1, ADDRESS2, value2, 1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, value2);
    }

    function testCanBatchResetADeniedRequestCreatedByHolder() public {
        // Arrange
        _createTransferRequestBatchByHodler();
        uint256[] memory ids = new uint256[](3);
        ids[0] = 0;
        ids[1] = 1;
        ids[2] = 2;

        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            false
        );

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferReset(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.expectEmit(true, true, true, true);
        emit transferReset(key2, ADDRESS1, ADDRESS2, value2, 1);
        vm.expectEmit(true, true, true, true);
        emit transferReset(key3Hodler, ADDRESS1, ADDRESS2, value3, 2);
        ruleConditionalTransfer.resetRequestStatusBatch(ids);

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer
            .getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.NONE));

        transferRequest = ruleConditionalTransfer.getRequestTrade(
            ADDRESS1,
            ADDRESS2,
            value2
        );
        assertEq(transferRequest.key, key2);
        assertEq(transferRequest.id, 1);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, value2);
        assertEq(uint256(transferRequest.status), uint256(STATUS.NONE));

        transferRequest = ruleConditionalTransfer.getRequestTrade(
            ADDRESS1,
            ADDRESS2,
            value3
        );
        assertEq(transferRequest.key, key3Hodler);
        assertEq(transferRequest.id, 2);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, value3);
        assertEq(uint256(transferRequest.status), uint256(STATUS.NONE));
    }

    function testCannotBatchResetADeniedRequestCreatedByHolderWithWrongId()
        public
    {
        // Arrange
        _createTransferRequestBatchByHodler();
        uint256[] memory ids = new uint256[](3);
        ids[0] = 3;
        ids[1] = 1;
        ids[2] = 2;

        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            false
        );

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidId.selector);
        ruleConditionalTransfer.resetRequestStatusBatch(ids);
    }

    function testCannotBatchResetADeniedRequestCreatedByHolderWithEmptyArray()
        public
    {
        // Arrange
        _createTransferRequestBatchByHodler();
        uint256[] memory ids = new uint256[](0);
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            false
        );

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_EmptyArray.selector);
        ruleConditionalTransfer.resetRequestStatusBatch(ids);
    }

    function testCannotResetARequestIfWrongId() public {
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidId.selector);
        ruleConditionalTransfer.resetRequestStatus(10);
    }
}
