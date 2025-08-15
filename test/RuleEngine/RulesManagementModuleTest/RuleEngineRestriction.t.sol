// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
import "OZ/token/ERC20/IERC20.sol";

//ADmin, forwarder irrect /RuleEngine
/**
 * @title General functions of the RuleEngine
 */
contract RuleEngineTest is Test, HelperContract {
    uint256 defaultValue = 20;

    // Arrange
    function setUp() public {
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
        ruleConditionalTransferLight = new RuleConditionalTransferLight(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ruleEngineMock
        );

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanDetectTransferRestrictionOK() public {
        // Arrange
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);

        vm.expectEmit(true, true, true, true);
        emit TransferApproved(ADDRESS1, ADDRESS2, defaultValue, 1);
        ruleConditionalTransferLight.approveTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );

        // Assert
        assertEq(resUint8, 0);

        resUint8 = ruleEngineMock.detectTransferRestrictionFrom(
            address(0),
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );

        // Assert
        assertEq(resUint8, 0);

        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, defaultValue);

        // Assert
        assertEq(resBool, true);

        resBool = ruleEngineMock.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );

        // Assert
        assertEq(resBool, true);
    }

    function testCanDetectTransferRestrictionNotOk() public {
        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);

        // Act
        resUint8 = ruleEngineMock.detectTransferRestrictionFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);

        // Act
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertFalse(resBool);

        // Act
        resBool = ruleEngineMock.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertFalse(resBool);
    }

    function testMessageForTransferRestrictionNoRule() public {
        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRules();

        // Act
        resString = ruleEngineMock.messageForTransferRestriction(50);

        // Assert
        assertEq(resString, "Unknown restriction code");
    }

    function testMessageForTransferRestrictionWithUnknownRestrictionCode()
        public
    {
        // Act
        resString = ruleEngineMock.messageForTransferRestriction(50);

        // Assert
        assertEq(resString, "Unknown restriction code");
    }

    function testMessageForTransferRestrictionWithValidRC() public {
        // Act
        resString = ruleEngineMock.messageForTransferRestriction(
            CODE_TRANSFER_REQUEST_NOT_APPROVED
        );

        // Assert
        assertEq(resString, TEXT_TRANSFER_REQUEST_NOT_APPROVED);
    }
}
