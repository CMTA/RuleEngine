// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/deployment/CMTATStandalone.sol";
import "../../HelperContract.sol";
import "OZ/token/ERC20/IERC20.sol";

/**
 * @title General functions of the RuleEngine
 */
contract RuleEngineCMTATIntegrationTest is Test, HelperContract {
    uint256 defaultValue = 20;

    // Arrange
    function setUp() public {
        // global arrange
        cmtatDeployment = new CMTATDeployment();
        CMTAT_CONTRACT = cmtatDeployment.cmtat();

        // CMTAT
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS1, defaultValue * 2);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS2, defaultValue);

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            address(CMTAT_CONTRACT)
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

        // We set the Rule Engine
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.setRuleEngine(ruleEngineMock);
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
        // RuleEngine
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

        // CMTAT
        resUint8 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );

        // Assert
        assertEq(resUint8, 0);

        resUint8 = CMTAT_CONTRACT.detectTransferRestrictionFrom(
            address(0),
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );

        // Assert
        assertEq(resUint8, 0);

        // RuleEngine
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

        // CMTAT
        resBool = CMTAT_CONTRACT.canTransfer(ADDRESS1, ADDRESS2, defaultValue);

        // Assert
        assertEq(resBool, true);

        resBool = CMTAT_CONTRACT.canTransferFrom(
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

        // CMTAT
        resUint8 = CMTAT_CONTRACT.detectTransferRestriction(
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

        // CMTAT
        resUint8 = CMTAT_CONTRACT.detectTransferRestrictionFrom(
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

        // CMTAT
        resBool = CMTAT_CONTRACT.canTransfer(ADDRESS1, ADDRESS2, 20);

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

        // CMTAT
        resBool = CMTAT_CONTRACT.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertFalse(resBool);
    }

    function testCanPerfromATransfer() public {
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransferLight.approveTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);

        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransferLight.approveTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.approve(ADDRESS3, defaultValue);
        vm.prank(ADDRESS3);
        CMTAT_CONTRACT.transferFrom(ADDRESS1, ADDRESS2, defaultValue);
    }
}
