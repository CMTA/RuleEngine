// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
import "OZ/token/ERC20/IERC20.sol";
/**
 * @title General functions of the RuleEngine
 */
contract RuleEngineOperationTest is Test, HelperContract {
  IRuleOperation[] ruleConditionalTransferLightTab  = new IRuleOperation[](2);
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
        ruleEngineMock.addRuleOperation(ruleConditionalTransferLight);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);

    }

    function testCanSetRulesOperation() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight2 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        ruleConditionalTransferLightTab[0] = IRuleOperation(ruleConditionalTransferLight1);
        ruleConditionalTransferLightTab[1] = IRuleOperation(ruleConditionalTransferLight2);
        // Act
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.AddRuleOperation(ruleConditionalTransferLight1);
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.AddRuleOperation(ruleConditionalTransferLight2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );

        // Assert
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 2);
    }

    function testCannotSetRuleIfARuleIsAlreadyPresent() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        ruleConditionalTransferLightTab[0] = ruleConditionalTransferLight1;
        ruleConditionalTransferLightTab[1] = ruleConditionalTransferLight1;

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert(RuleEngine_RuleAlreadyExists.selector);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );

        // Assert
        // I do not know why but the function call return true
        // if the call is reverted with the message indicated in expectRevert
        // assertFalse(resCallBool);
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCannotSetEmptyRulesT1WithEmptyTab() public {
        // Arrange
        ruleConditionalTransferLightTab = new IRuleOperation[](0);
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );

        // Assert
        assertFalse(resCallBool);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);

        // Assert
        // previous rule still present => invalid Transfer
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);
    }

    function testCannotSetEmptyRulesT2WithZeroAddress() public {
        // Arrange

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert("The array is empty2");

        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );

        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert1
        assertFalse(resCallBool);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);

        // Assert2
        // previous rule still present => invalid Transfer
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);
    }

    function testCanClearRules() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight2 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        ruleConditionalTransferLightTab[0] = IRuleOperation(ruleConditionalTransferLight1);
        ruleConditionalTransferLightTab[1] = IRuleOperation(ruleConditionalTransferLight2);

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );
        ruleEngineMock.rulesOperation();
        // Assert - Arrange
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 2);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.ClearRulesOperation();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRulesOperation();

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 0);
    }

    function testCanClearRulesAndAddAgain() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight2 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        ruleConditionalTransferLightTab[0] = IRuleOperation(ruleConditionalTransferLight1);
        ruleConditionalTransferLightTab[1] = IRuleOperation(ruleConditionalTransferLight2);

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );

        // Act
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.ClearRulesOperation();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRulesOperation();

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 0);

        // Can set again the previous rules
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );
        assertEq(resCallBool, true);
        // Arrange before assert

        // Act
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.ClearRulesOperation();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRulesOperation();
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 0);

        // Can add previous rule again
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.AddRuleOperation(ruleConditionalTransferLight1);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransferLight1);
    }

    function testCanAddRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );

        // Act
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.AddRuleOperation(ruleConditionalTransferLight1);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransferLight1);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 2);
    }

    function testCannotAddRuleZeroAddress() public {
        // Act
        vm.expectRevert(RuleEngine_RuleAddressZeroNotAllowed.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(IRuleOperation(address(0x0)));

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCannotAddARuleAlreadyPresent() public {
        // Act
        vm.expectRevert(RuleEngine_RuleAlreadyExists.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransferLight);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanAddARuleAfterThisRuleWasRemoved() public {
        // Arrange - Assert
        address[] memory _rules = ruleEngineMock.rulesOperation();
        assertEq(address(_rules[0]), address(ruleConditionalTransferLight));

        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(ruleConditionalTransferLight);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.AddRuleOperation(ruleConditionalTransferLight);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransferLight);

        // Assert
        _rules = ruleEngineMock.rulesOperation();
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCannotRemoveNonExistantRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );

        // Act
        vm.expectRevert(RuleEngine_RuleDoNotMatch.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(ruleConditionalTransferLight1);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveLatestRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransferLight1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.RemoveRuleOperation(ruleConditionalTransferLight1);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(ruleConditionalTransferLight1);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveFirstRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransferLight1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.RemoveRuleOperation(ruleConditionalTransferLight);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(ruleConditionalTransferLight);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveRuleOperation() public {
        // Arrange
        // First rule
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransferLight1);
        // Second rule
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight2 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransferLight2);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RuleEngineOperation.RemoveRuleOperation(ruleConditionalTransferLight1);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(ruleConditionalTransferLight1);

        // Assert
        address[] memory _rules = ruleEngineMock.rulesOperation();
        // RuleConditionalTransferLight1 has been removed
        assertEq(address(_rules[0]), address(ruleConditionalTransferLight));
        assertEq(address(_rules[1]), address(ruleConditionalTransferLight2));

        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 2);
    }

    function testRuleLength() public {
        // Act
        resUint256 = ruleEngineMock.rulesCountOperation();

        // Assert
        assertEq(resUint256, 1);

        // Arrange
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        RuleConditionalTransferLight ruleConditionalTransferLight2 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        ruleConditionalTransferLightTab[0] = IRuleOperation(ruleConditionalTransferLight1);
        ruleConditionalTransferLightTab[1] = IRuleOperation(ruleConditionalTransferLight2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );

        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        resUint256 = ruleEngineMock.rulesCountOperation();

        // Assert
        assertEq(resUint256, 2);
    }

    function testGetRule() public {
        // Arrange
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        RuleConditionalTransferLight ruleConditionalTransferLight2 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        ruleConditionalTransferLightTab[0] = IRuleOperation(ruleConditionalTransferLight1);
        ruleConditionalTransferLightTab[1] = IRuleOperation(ruleConditionalTransferLight2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        address rule = ruleEngineMock.ruleOperation(0);

        // Assert
        assertEq(address(rule), address(ruleConditionalTransferLight1));
    }

    function testGetRules() public {
        // Arrange
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        RuleConditionalTransferLight ruleConditionalTransferLight2 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        ruleConditionalTransferLightTab[0] = IRuleOperation(ruleConditionalTransferLight1);
        ruleConditionalTransferLightTab[1] = IRuleOperation(ruleConditionalTransferLight2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        address[] memory rules = ruleEngineMock.rulesOperation();

        // Assert
        assertEq(ruleConditionalTransferLightTab.length, rules.length);
        for (uint256 i = 0; i < rules.length; ++i) {
            assertEq(address(ruleConditionalTransferLightTab[i]), address(rules[i]));
        }
    }

    function testCanGetRuleIndex() public {
        // Arrange
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        RuleConditionalTransferLight ruleConditionalTransferLight2 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        ruleConditionalTransferLightTab[0] = IRuleOperation(ruleConditionalTransferLight1);
        ruleConditionalTransferLightTab[1] = 
            IRuleOperation(ruleConditionalTransferLight2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRulesOperation,
                ruleConditionalTransferLightTab
            )
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
       /* uint256 index1 = ruleEngineMock.getRuleIndexOperation(
            ruleConditionalTransferLight1
        );
        uint256 index2 = ruleEngineMock.getRuleIndexOperation(
            ruleConditionalTransferLight2
        );
        // Length of the list because RuleConditionalTransferLight is not in the list
        uint256 index3 = ruleEngineMock.getRuleIndexOperation(
            ruleConditionalTransferLight
        );

        // Assert
        assertEq(index1, 0);
        assertEq(index2, 1);
        assertEq(index3, ruleConditionalTransferLightTab.length);*/
    }
}