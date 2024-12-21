// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
 * @title General functions of the RuleWhitelist
 */
contract RuleConditionalTransferTest is Test, HelperContract {
    uint256 defaultValue = 10;
    bytes32 defaultKey =
        keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));

    // Batch test
    uint256 value2 = 1;
    uint256 value3 = 2;
    uint256 value4 = 1000;
    uint256 value5 = 2000;
    bytes32 key2 = keccak256(abi.encode(ADDRESS1, ADDRESS2, value2));
    bytes32 key3 = keccak256(abi.encode(ADDRESS2, ADDRESS1, value3));
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

    TransferRequestKeyElement transferRequestInput4 =
        TransferRequestKeyElement({
            from: ADDRESS1,
            to: ADDRESS2,
            value: value4
        });
    TransferRequestKeyElement transferRequestInput5 =
        TransferRequestKeyElement({
            from: ADDRESS1,
            to: ADDRESS2,
            value: value5
        });
    TransferRequestKeyElement transferRequestInput =
        TransferRequestKeyElement({
            from: ADDRESS1,
            to: ADDRESS2,
            value: defaultValue
        });

    // Arrange
    function setUp() public {
        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: 3 days,
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

    function _createTransferRequestBatch() public {
        // Arrange
        _createTransferRequest();

        // Second and third request
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, value2);
        vm.prank(ADDRESS2);
        ruleConditionalTransfer.createTransferRequest(ADDRESS1, value3);
        //Fourth request => will be not validated
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, value4);
        //fifth request => will not be treated
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, value5);
    }

    function _checkRequestPartial() internal view {
        TransferRequest memory transferRequest = ruleConditionalTransfer
            .getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.APPROVED));

        // 2
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
        assertEq(uint256(transferRequest.status), uint256(STATUS.APPROVED));

        // 3
        transferRequest = ruleConditionalTransfer.getRequestTrade(
            ADDRESS2,
            ADDRESS1,
            value3
        );
        assertEq(transferRequest.key, key3);
        assertEq(transferRequest.id, 2);
        assertEq(transferRequest.keyElement.from, ADDRESS2);
        assertEq(transferRequest.keyElement.to, ADDRESS1);
        assertEq(transferRequest.keyElement.value, value3);
        assertEq(uint256(transferRequest.status), uint256(STATUS.APPROVED));

        // 4
        transferRequest = ruleConditionalTransfer.getRequestTrade(
            ADDRESS1,
            ADDRESS2,
            value4
        );
        assertEq(transferRequest.key, key4);
        assertEq(transferRequest.id, 3);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, value4);
        assertEq(uint256(transferRequest.status), uint256(STATUS.DENIED));
    }

    function _checkRequestBatch() internal view {
        _checkRequestPartial();

        // 5
        TransferRequest memory transferRequest = ruleConditionalTransfer
            .getRequestTrade(ADDRESS1, ADDRESS2, value5);
        assertEq(transferRequest.key, key5);
        assertEq(transferRequest.id, 4);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, value5);
        assertEq(uint256(transferRequest.status), uint256(STATUS.WAIT));
    }

    function testCanCreateTransferRequest() public {
        _createTransferRequest();
    }

    /**
     * @dev test first
     */
    function testCanCreateTransferRequestWithApproval() public {
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequestWithApproval(
            transferRequestInput
        );
    }

    function testCanCreateTransferRequestWithApprovalBatch() public {
        // Arrange
        TransferRequestKeyElement[]
            memory transferRequestKeyElements = new TransferRequestKeyElement[](
                4
            );
        transferRequestKeyElements[0] = transferRequestInput;
        transferRequestKeyElements[1] = transferRequestInput2;
        transferRequestKeyElements[2] = transferRequestInput3;
        transferRequestKeyElements[3] = transferRequestInput4;

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key2, ADDRESS1, ADDRESS2, value2, 1);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key3, ADDRESS2, ADDRESS1, value3, 2);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key4, ADDRESS1, ADDRESS2, value4, 3);
        ruleConditionalTransfer.createTransferRequestWithApprovalBatch(
            transferRequestKeyElements
        );
    }

    function testCanCreateTransferRequestWithApprovalBatchWithEmptyArray()
        public
    {
        // Arrange
        TransferRequestKeyElement[]
            memory transferRequestKeyElements = new TransferRequestKeyElement[](
                0
            );

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_EmptyArray.selector);
        ruleConditionalTransfer.createTransferRequestWithApprovalBatch(
            transferRequestKeyElements
        );
    }

    /**
     * @dev test overwrite branch, previous approval
     */
    function testCanCreateTransferRequestWithApprovalAgain() public {
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        // Arrange
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequestWithApproval(
            transferRequestInput
        );

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequestWithApproval(
            transferRequestInput
        );
    }

    /**** Request approval ****** */
    function testCanHolderCreateRequestBatch() public {
        // Arrange
        uint256[] memory values = new uint256[](3);
        values[0] = defaultValue;
        values[1] = value2;
        values[2] = value4;
        address[] memory addresses = new address[](3);
        addresses[0] = ADDRESS2;
        addresses[1] = ADDRESS2;
        addresses[2] = ADDRESS2;

        // Act
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(key2, ADDRESS1, ADDRESS2, value2, 1);
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(key4, ADDRESS1, ADDRESS2, value4, 2);
        ruleConditionalTransfer.createTransferRequestBatch(addresses, values);
    }

    function testCannotHolderCreateRequestBatchEmptyArray() public {
        // Arrange
        uint256[] memory values = new uint256[](0);
        address[] memory addresses = new address[](0);

        // Act
        vm.prank(ADDRESS1);
        vm.expectRevert(RuleConditionalTransfer_EmptyArray.selector);
        ruleConditionalTransfer.createTransferRequestBatch(addresses, values);
    }

    function testCannotHolderCreateRequestBatchIfLEngthMismatch() public {
        // Arrange
        uint256[] memory values = new uint256[](3);
        address[] memory addresses = new address[](1);

        // Act
        vm.prank(ADDRESS1);
        vm.expectRevert(RuleConditionalTransfer_InvalidLengthArray.selector);
        ruleConditionalTransfer.createTransferRequestBatch(addresses, values);
    }

    function testCanApproveRequestCreatedByHolder() public {
        // Arrange
        _createTransferRequest();

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );
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
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            partialValue,
            true
        );
    }

    function testCannotPartiallyDeniedRequestCreatedByHolder() public {
        // Arrange
        _createTransferRequest();
        uint256 partialValue = 5;
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_CannotDeniedPartially.selector);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            partialValue,
            false
        );
    }

    function testCannotPartiallyApprovedRequestCreatedByHolderIfPartialValueIsBiggerThanValue()
        public
    {
        // Arrange
        _createTransferRequest();
        uint256 partialValue = 5000;
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidValueApproved.selector);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            partialValue,
            false
        );
    }

    function testCanCreateAndApproveRequestCreatedByHolderAgain() public {
        // Arrange
        // First request
        _createTransferRequest();

        // First approval
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );

        // Second request
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);

        // Second approval
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer
            .getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.APPROVED));
    }

    /*** Batch */
    function testCanCreateAndApproveRequestCreatedByHolderInBatch() public {
        // Arrange
        _createTransferRequestBatch();
        uint256[] memory partialValues = new uint256[](4);
        partialValues[0] = 0;
        partialValues[1] = 0;
        partialValues[2] = 0;
        partialValues[3] = 0;
        bool[] memory isApproveds = new bool[](4);
        isApproveds[0] = true;
        isApproveds[1] = true;
        isApproveds[2] = true;
        isApproveds[3] = false;

        TransferRequestKeyElement[]
            memory transferRequestKeyElements = new TransferRequestKeyElement[](
                4
            );
        transferRequestKeyElements[0] = transferRequestInput;
        transferRequestKeyElements[1] = transferRequestInput2;
        transferRequestKeyElements[2] = transferRequestInput3;
        transferRequestKeyElements[3] = transferRequestInput4;

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key2, ADDRESS1, ADDRESS2, value2, 1);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key3, ADDRESS2, ADDRESS1, value3, 2);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(key4, ADDRESS1, ADDRESS2, value4, 3);
        ruleConditionalTransfer.approveTransferRequestBatch(
            transferRequestKeyElements,
            partialValues,
            isApproveds
        );

        // Assert
        _checkRequestBatch();
    }

    function testCannotCreateAndApproveRequestCreatedByHolderInBatchWithLenghtMismatch()
        public
    {
        // Arrange
        uint256[] memory partialValues = new uint256[](4);
        // Lenght mismatch
        bool[] memory isApproveds = new bool[](3);

        TransferRequestKeyElement[]
            memory transferRequestKeyElements = new TransferRequestKeyElement[](
                4
            );
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidLengthArray.selector);
        ruleConditionalTransfer.approveTransferRequestBatch(
            transferRequestKeyElements,
            partialValues,
            isApproveds
        );

        // Act
        uint256[] memory partialValuesV2 = new uint256[](1);
        partialValuesV2[0] = 0;
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidLengthArray.selector);
        ruleConditionalTransfer.approveTransferRequestBatch(
            transferRequestKeyElements,
            partialValuesV2,
            isApproveds
        );

        // Act
        uint256[] memory partialValuesV3 = new uint256[](4);
        // Lenght mismatch
        bool[] memory isApprovedsV3 = new bool[](4);
        TransferRequestKeyElement[]
            memory transferRequestKeyElementsV3 = new TransferRequestKeyElement[](
                2
            );
        transferRequestKeyElementsV3[0] = transferRequestInput;
        transferRequestKeyElementsV3[1] = transferRequestInput2;
        vm.expectRevert(RuleConditionalTransfer_InvalidLengthArray.selector);
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.approveTransferRequestBatch(
            transferRequestKeyElementsV3,
            partialValuesV3,
            isApprovedsV3
        );
    }

    function testCannotCreateAndApproveRequestCreatedByHolderInBatchWithEmptyArry()
        public
    {
        // Arrange
        uint256[] memory partialValues = new uint256[](0);
        // Lenght mismatch
        bool[] memory isApproveds = new bool[](0);

        TransferRequestKeyElement[]
            memory transferRequestKeyElements = new TransferRequestKeyElement[](
                0
            );
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_EmptyArray.selector);
        ruleConditionalTransfer.approveTransferRequestBatch(
            transferRequestKeyElements,
            partialValues,
            isApproveds
        );
    }

    function testCanCreateAndApproveRequestCreatedByHolderInBatchWithPartialValues()
        public
    {
        // Arrange
        _createTransferRequestBatch();
        uint256[] memory partialValues = new uint256[](5);
        partialValues[0] = 0;
        partialValues[1] = 0;
        partialValues[2] = 0;
        partialValues[3] = 0;
        // partial value
        partialValues[4] = 500;
        bytes32 key5PartialValue = keccak256(
            abi.encode(ADDRESS1, ADDRESS2, partialValues[4])
        );
        bool[] memory isApproveds = new bool[](5);
        isApproveds[0] = true;
        isApproveds[1] = true;
        isApproveds[2] = true;
        isApproveds[3] = false;
        isApproveds[4] = true;

        TransferRequestKeyElement[]
            memory transferRequestKeyElements = new TransferRequestKeyElement[](
                5
            );
        transferRequestKeyElements[0] = transferRequestInput;
        transferRequestKeyElements[1] = transferRequestInput2;
        transferRequestKeyElements[2] = transferRequestInput3;
        transferRequestKeyElements[3] = transferRequestInput4;
        transferRequestKeyElements[4] = transferRequestInput5;
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key2, ADDRESS1, ADDRESS2, value2, 1);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key3, ADDRESS2, ADDRESS1, value3, 2);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(key4, ADDRESS1, ADDRESS2, value4, 3);
        //partial value
        vm.expectEmit(true, true, true, true);
        emit transferDenied(key5, ADDRESS1, ADDRESS2, value5, 4);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(
            key5PartialValue,
            ADDRESS1,
            ADDRESS2,
            partialValues[4],
            5
        );
        ruleConditionalTransfer.approveTransferRequestBatch(
            transferRequestKeyElements,
            partialValues,
            isApproveds
        );

        // Assert

        _checkRequestPartial();
        // 5
        TransferRequest memory transferRequest = ruleConditionalTransfer
            .getRequestTrade(ADDRESS1, ADDRESS2, value5);
        assertEq(transferRequest.key, key5);
        assertEq(transferRequest.id, 4);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, value5);
        assertEq(uint256(transferRequest.status), uint256(STATUS.DENIED));
        // new request
        transferRequest = ruleConditionalTransfer.getRequestTrade(
            ADDRESS1,
            ADDRESS2,
            partialValues[4]
        );
        assertEq(transferRequest.key, key5PartialValue);
        assertEq(transferRequest.id, 5);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, partialValues[4]);
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
        ruleConditionalTransfer.approveTransferRequestWithId(0, true);

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer
            .getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.APPROVED));
    }

    /***** Batch */

    function testCanApproveRequestInBatchCreatedByHolderWithId() public {
        _createTransferRequestBatch();
        uint256[] memory ids = new uint256[](4);
        ids[0] = 0;
        ids[1] = 1;
        ids[2] = 2;
        ids[3] = 3;
        bool[] memory isApproveds = new bool[](4);
        isApproveds[0] = true;
        isApproveds[1] = true;
        isApproveds[2] = true;
        isApproveds[3] = false;
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key2, ADDRESS1, ADDRESS2, value2, 1);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key3, ADDRESS2, ADDRESS1, value3, 2);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(key4, ADDRESS1, ADDRESS2, value4, 3);
        ruleConditionalTransfer.approveTransferRequestBatchWithId(
            ids,
            isApproveds
        );

        // Assert
        _checkRequestBatch();
    }

    function testCannotApproveRequestInBatchCreatedByHolderWithIdWithinvalidLength()
        public
    {
        _createTransferRequestBatch();
        uint256[] memory ids = new uint256[](4);
        // Wrong length here
        bool[] memory isApproveds = new bool[](3);
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidLengthArray.selector);
        ruleConditionalTransfer.approveTransferRequestBatchWithId(
            ids,
            isApproveds
        );
    }

    function testCannotApproveRequestInBatchCreatedByHolderWithIdWithEmptyArray()
        public
    {
        _createTransferRequestBatch();
        uint256[] memory ids = new uint256[](0);
        // Wrong length here
        bool[] memory isApproveds = new bool[](0);
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_EmptyArray.selector);
        ruleConditionalTransfer.approveTransferRequestBatchWithId(
            ids,
            isApproveds
        );
    }

    function testCannotApproveRequestInBatchCreatedByHolderWithWrongId()
        public
    {
        _createTransferRequestBatch();
        uint256[] memory ids = new uint256[](4);
        ids[0] = 0;
        ids[1] = 1;
        ////// Wrong id here !!!
        ids[2] = 6;
        ids[3] = 3;
        bool[] memory isApproveds = new bool[](4);
        isApproveds[0] = true;
        isApproveds[1] = true;
        isApproveds[2] = true;
        isApproveds[3] = false;
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidId.selector);
        ruleConditionalTransfer.approveTransferRequestBatchWithId(
            ids,
            isApproveds
        );
    }

    function testCannotApproveRequestInBatchCreatedByHolderIfTimeExceed()
        public
    {
        _createTransferRequestBatch();
        // Jump
        vm.warp(block.timestamp + 604801);
        uint256[] memory ids = new uint256[](4);
        ids[0] = 0;
        ids[1] = 1;
        ids[2] = 2;
        ids[3] = 3;
        bool[] memory isApproveds = new bool[](4);
        isApproveds[0] = true;
        isApproveds[1] = true;
        isApproveds[2] = true;
        isApproveds[3] = false;
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_timeExceeded.selector);
        ruleConditionalTransfer.approveTransferRequestBatchWithId(
            ids,
            isApproveds
        );
    }

    function testCannotApproveOrDeniedRequestCreatedByHolderWithWrongId()
        public
    {
        // Arrange
        _createTransferRequest();

        // Act
        // Approve
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidId.selector);
        ruleConditionalTransfer.approveTransferRequestWithId(1, true);
        // Denied
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectRevert(RuleConditionalTransfer_InvalidId.selector);
        ruleConditionalTransfer.approveTransferRequestWithId(1, false);
    }

    function testCanDeniedRequestCreatedByHolderWithId() public {
        // Arrange
        _createTransferRequest();
        // can still approve
        vm.warp(block.timestamp + 1);

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequestWithId(0, false);

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer
            .getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.DENIED));
    }

    /***** with key ******/
    function testCanDeniedRequestCreatedByHolder() public {
        // Arrange
        _createTransferRequest();

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            false
        );

        // Assert
        TransferRequest memory transferRequest = ruleConditionalTransfer
            .getRequestTrade(ADDRESS1, ADDRESS2, defaultValue);
        assertEq(transferRequest.key, defaultKey);
        assertEq(transferRequest.id, 0);
        assertEq(transferRequest.keyElement.from, ADDRESS1);
        assertEq(transferRequest.keyElement.to, ADDRESS2);
        assertEq(transferRequest.keyElement.value, defaultValue);
        assertEq(uint256(transferRequest.status), uint256(STATUS.DENIED));

        TransferRequest[] memory transferRequests = ruleConditionalTransfer
            .getRequestByStatus(STATUS.DENIED);
        assertEq(transferRequests[0].key, defaultKey);
        assertEq(transferRequests.length, 1);
    }

    function testCannotHolderCreateRequestIfDenied() public {
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
        vm.prank(ADDRESS1);
        vm.expectRevert(RuleConditionalTransfer_TransferDenied.selector);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);
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
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            false
        );

        // Second request
        uint256 value = 100;
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, value);

        // Act
        TransferRequest[] memory transferRequest = ruleConditionalTransfer
            .getRequestByStatus(STATUS.WAIT);
        // Assert
        assertEq(transferRequest.length, 1);
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        assertEq(transferRequest[0].key, key);
        assertEq(transferRequest[0].id, 1);
        assertEq(transferRequest[0].keyElement.from, ADDRESS1);
        assertEq(transferRequest[0].keyElement.to, ADDRESS2);
        assertEq(transferRequest[0].keyElement.value, value);
        assertEq(uint256(transferRequest[0].status), uint256(STATUS.WAIT));

        // third request
        uint256 valueThird = 200;
        vm.prank(ADDRESS1);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, valueThird);

        // Act
        transferRequest = ruleConditionalTransfer.getRequestByStatus(
            STATUS.WAIT
        );
        // Assert
        assertEq(transferRequest.length, 2);
        bytes32 keyThird = keccak256(
            abi.encode(ADDRESS1, ADDRESS2, valueThird)
        );
        assertEq(transferRequest[1].key, keyThird);
        assertEq(transferRequest[1].id, 2);
        assertEq(transferRequest[1].keyElement.from, ADDRESS1);
        assertEq(transferRequest[1].keyElement.to, ADDRESS2);
        assertEq(transferRequest[1].keyElement.value, valueThird);
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
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );
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
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );
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
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );
    }
}
