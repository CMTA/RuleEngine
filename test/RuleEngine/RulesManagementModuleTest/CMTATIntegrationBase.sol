// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CMTATStandalone} from "CMTAT/deployment/CMTATStandalone.sol";
// forge-lint: disable-next-line(unaliased-plain-import)
import "../../HelperContract.sol";



/**
 * @title Base integration test for RuleEngine with CMTAT
 */
abstract contract RuleEngineCMTATIntegrationBase is Test, HelperContract {
    uint256 defaultValue = 20;

    function _deployCmtat() internal virtual returns (CMTATStandalone);

    // Arrange
    function setUp() public virtual {
        // global arrange
        cmtatContract = _deployCmtat();

        // CMTAT
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        cmtatContract.mint(ADDRESS1, defaultValue * 2);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        cmtatContract.mint(ADDRESS2, defaultValue);

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(RULE_ENGINE_OPERATOR_ADDRESS, ZERO_ADDRESS, address(cmtatContract));
        ruleConditionalTransferLight =
            new RuleConditionalTransferLight(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS, ruleEngineMock);

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);

        // We set the Rule Engine
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        cmtatContract.setRuleEngine(ruleEngineMock);
    }

    function testCanDetectTransferRestrictionOK() public {
        // Arrange
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);

        vm.expectEmit(true, true, true, true);
        emit TransferApproved(ADDRESS1, ADDRESS2, defaultValue, 1);
        ruleConditionalTransferLight.approveTransfer(ADDRESS1, ADDRESS2, defaultValue);
        // Act
        // RuleEngine
        resUint8 = ruleEngineMock.detectTransferRestriction(ADDRESS1, ADDRESS2, defaultValue);

        // Assert
        assertEq(resUint8, 0);

        resUint8 = ruleEngineMock.detectTransferRestrictionFrom(address(0), ADDRESS1, ADDRESS2, defaultValue);

        // Assert
        assertEq(resUint8, 0);

        // CMTAT
        resUint8 = cmtatContract.detectTransferRestriction(ADDRESS1, ADDRESS2, defaultValue);

        // Assert
        assertEq(resUint8, 0);

        resUint8 = cmtatContract.detectTransferRestrictionFrom(address(0), ADDRESS1, ADDRESS2, defaultValue);

        // Assert
        assertEq(resUint8, 0);

        // RuleEngine
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, defaultValue);

        // Assert
        assertEq(resBool, true);

        resBool = ruleEngineMock.canTransferFrom(ADDRESS3, ADDRESS1, ADDRESS2, defaultValue);

        // Assert
        assertEq(resBool, true);

        // CMTAT
        resBool = cmtatContract.canTransfer(ADDRESS1, ADDRESS2, defaultValue);

        // Assert
        assertEq(resBool, true);

        resBool = cmtatContract.canTransferFrom(ADDRESS3, ADDRESS1, ADDRESS2, defaultValue);

        // Assert
        assertEq(resBool, true);
    }

    function testCanDetectTransferRestrictionNotOk() public {
        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);

        // CMTAT
        resUint8 = cmtatContract.detectTransferRestriction(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);

        // Act
        resUint8 = ruleEngineMock.detectTransferRestrictionFrom(ADDRESS3, ADDRESS1, ADDRESS2, 20);

        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);

        // CMTAT
        resUint8 = cmtatContract.detectTransferRestrictionFrom(ADDRESS3, ADDRESS1, ADDRESS2, 20);

        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);

        // Act
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertFalse(resBool);

        // CMTAT
        resBool = cmtatContract.canTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertFalse(resBool);

        // Act
        resBool = ruleEngineMock.canTransferFrom(ADDRESS3, ADDRESS1, ADDRESS2, 20);

        // Assert
        assertFalse(resBool);

        // CMTAT
        resBool = cmtatContract.canTransferFrom(ADDRESS3, ADDRESS1, ADDRESS2, 20);

        // Assert
        assertFalse(resBool);
    }

    function testCanPerfromATransfer() public {
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransferLight.approveTransfer(ADDRESS1, ADDRESS2, defaultValue);
        vm.prank(ADDRESS1);
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cmtatContract.transfer(ADDRESS2, defaultValue);

        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransferLight.approveTransfer(ADDRESS1, ADDRESS2, defaultValue);
        vm.prank(ADDRESS1);
        cmtatContract.approve(ADDRESS3, defaultValue);
        vm.prank(ADDRESS3);
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cmtatContract.transferFrom(ADDRESS1, ADDRESS2, defaultValue);
    }
}
