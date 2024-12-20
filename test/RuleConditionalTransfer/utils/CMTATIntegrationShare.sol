// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/CMTAT_STANDALONE.sol";
import "../../HelperContract.sol";
import "src/RuleEngine.sol";

/**
 * @title Integration testShare with the CMTAT
 */
contract CMTATIntegrationShare is Test, HelperContract {
    uint256 ADDRESS1_BALANCE_INIT = 31;
    uint256 ADDRESS2_BALANCE_INIT = 32;
    uint256 ADDRESS3_BALANCE_INIT = 33;

    uint256 FLAG = 5;

    uint256 defaultValue = 10;
    bytes32 defaultKey =
        keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));

    TransferRequestKeyElement transferRequestInput =
        TransferRequestKeyElement({
            from: ADDRESS1,
            to: ADDRESS2,
            value: defaultValue
        });

    function _createTransferRequestShare() internal {
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);
    }

    /******* Transfer *******/
    function testShareCannotTransferWithoutApproval() internal {
        // Arrange
        vm.prank(ADDRESS1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                21
            )
        );
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    function testShareCanMakeATransferIfApproved() internal {
         // Arrange - Assert
        // ConditionalTransfer
        resUint8 = ruleConditionalTransfer.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);
        // CMTAT
        // Arrange - Assert
        resUint8 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);
        // Arrange
        vm.prank(ADDRESS1);
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );

        // Act
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT - defaultValue);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
        assertEq(resUint256, ADDRESS2_BALANCE_INIT + defaultValue);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
        assertEq(resUint256, 33);
    }

    function testShareCanMakeAPartialTransferIfPartiallyApproved() internal {
        // Arrange
        _createTransferRequestShare();

        uint256 partialValue = 5;
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, partialValue));
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, partialValue, 1);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            partialValue,
            true
        );

        // Act
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(key, ADDRESS1, ADDRESS2, partialValue, 1);
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, partialValue);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT - partialValue);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
        assertEq(resUint256, ADDRESS2_BALANCE_INIT + partialValue);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
        assertEq(resUint256, 33);
    }

    function testShareCannotMakeAWholeTransferIfPartiallyApproved() internal {
        // Arrange
        _createTransferRequestShare();
        uint256 partialValue = 5;
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, partialValue));
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, partialValue, 1);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            partialValue,
            true
        );

        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                defaultValue
            )
        );
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testShareCannotMakeATransferIfDelayExceeded(uint256 timeDelay) internal {
        // Arrange
        vm.prank(ADDRESS1);
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );

        
        vm.warp(block.timestamp + timeDelay);
        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                defaultValue
            )
        );
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testShareCannotMakeATransferIfDelayJustInTime(uint256 timeDelay) internal {
        // Arrange
        _createTransferRequestShare();

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );
        // 30 days
        vm.warp(block.timestamp + timeDelay);
        // Act
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testShareCanSetTimeLimitWithTransferExceeded(uint256 timeDelay) internal {
        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: 1 days,
            timeLimitToTransfer: 1 days
        });
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setTimeLimit(timeLimit_);
        // Arrange
        _createTransferRequestShare();
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );

        // Assert
        // Timeout
        // >1 days
        vm.warp(block.timestamp + timeDelay);

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                defaultValue
            )
        );
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testShareCanMintWithoutApproval() internal {
        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS1, 11);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT + 11);
    }

    function testShareCanBurnWithoutApproval() internal {
        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.burn(ADDRESS1, defaultValue, "testShare");

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT - defaultValue);
    }

    function testShareCannotMintWithoutApproval() internal {
        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval: false,
            authorizedBurnWithoutApproval: true
        });
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setIssuanceOptions(issuanceOption_);
        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ZERO_ADDRESS,
                ADDRESS1,
                11
            )
        );
        CMTAT_CONTRACT.mint(ADDRESS1, 11);
    }

    function testShareCannotBurnWithoutApproval() internal {
        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval: true,
            authorizedBurnWithoutApproval: false
        });
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setIssuanceOptions(issuanceOption_);
        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ZERO_ADDRESS,
                defaultValue
            )
        );
        CMTAT_CONTRACT.burn(ADDRESS1, defaultValue, "testShare");
    }

    function testShareAutomaticTransferIfOptionsSet() internal {
        AUTOMATIC_TRANSFER memory automaticTransfertestShare = AUTOMATIC_TRANSFER({
            isActivate: true,
            cmtat: CMTAT_CONTRACT
        });
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setAutomaticTransfer(automaticTransfertestShare);

        // Aproval
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.approve(address(ruleConditionalTransfer), defaultValue);

        // Arrange
        _createTransferRequestShare();

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );
    }

    function testShareCanTransferIfAutomaticApprovalSetAndTimeExceedsJustInTime()
        internal
    {
        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: true,
            timeLimitBeforeAutomaticApproval: 90 days
        });

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setAutomaticApproval(automaticApproval_);

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        // Arrange
        _createTransferRequestShare();

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);

        vm.warp(block.timestamp + 90 days);
        // Act
        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertEq(resBool, true);
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testShareCanTransferIfAutomaticApprovalSetAndTimeExceeds() internal {
        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: true,
            timeLimitBeforeAutomaticApproval: 90 days
        });

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setAutomaticApproval(automaticApproval_);

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        // Arrange
        _createTransferRequestShare();

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);

        vm.warp(block.timestamp + 91 days);
        // Act
        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertEq(resBool, true);
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testShareCannotTransferIfAutomaticApprovalSetAndTimeNotExceeds()
        internal
    {
        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: true,
            timeLimitBeforeAutomaticApproval: 90 days
        });
        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setAutomaticApproval(automaticApproval_);

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        // Arrange
        _createTransferRequestShare();

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);

        resBool = CMTAT_CONTRACT.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        // Time not exceeds
        vm.warp(block.timestamp + 85 days);
        // Act
        vm.prank(ADDRESS1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                defaultValue
            )
        );
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }
}
