// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
import "OZ/token/ERC20/IERC20.sol";

/**
 * @title General functions of the RuleEngine
 */
contract RulesManagementModuleInvariantStorageTest is Test, HelperContract {
    IRule[] ruleConditionalTransferLightTab = new IRule[](2);

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
        assertEq(
            ruleEngineMock.containsRule(ruleConditionalTransferLight),
            true
        );
    }

    function testCanSetRules() public {
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
        ruleConditionalTransferLightTab[0] = IRule(
            ruleConditionalTransferLight1
        );
        ruleConditionalTransferLightTab[1] = IRule(
            ruleConditionalTransferLight2
        );
        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.AddRule(
            ruleConditionalTransferLight1
        );
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.AddRule(
            ruleConditionalTransferLight2
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleConditionalTransferLightTab);
        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 2);

        assertEq(
            ruleEngineMock.containsRule(ruleConditionalTransferLight1),
            true
        );
        assertEq(
            ruleEngineMock.containsRule(ruleConditionalTransferLight2),
            true
        );
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
        vm.expectRevert(
            RuleEngine_RulesManagementModule_RuleAlreadyExists.selector
        );
        ruleEngineMock.setRules(ruleConditionalTransferLightTab);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotSetEmptyRulesT1WithEmptyTab() public {
        // Arrange
        ruleConditionalTransferLightTab = new IRule[](0);
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);

        // Act
        vm.expectRevert(
            RulesManagementModuleInvariantStorage
                .RuleEngine_RulesManagementModule_ArrayIsEmpty
                .selector
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleConditionalTransferLightTab);
        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);

        // Assert
        // previous rule still present => invalid Transfer
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);
    }

    function testCannotSetEmptyRulesT2WithZeroAddress() public {
        // Arrange
        ruleConditionalTransferLightTab = new IRule[](0);
        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert(
            RulesManagementModuleInvariantStorage
                .RuleEngine_RulesManagementModule_ArrayIsEmpty
                .selector
        );
        ruleEngineMock.setRules(ruleConditionalTransferLightTab);

        // Assert1
        resUint256 = ruleEngineMock.rulesCount();
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
        ruleConditionalTransferLightTab[0] = IRule(
            ruleConditionalTransferLight1
        );
        ruleConditionalTransferLightTab[1] = IRule(
            ruleConditionalTransferLight2
        );

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleConditionalTransferLightTab);
        address[] memory rulesResult = ruleEngineMock.rules();
        if (
            (rulesResult[0] != address(ruleConditionalTransferLight1)) ||
            (rulesResult[0] != address(ruleConditionalTransferLight1))
        ) {
            revert("Invalid array storage 1");
        }
        if (
            (rulesResult[1] != address(ruleConditionalTransferLight2)) ||
            (rulesResult[1] != address(ruleConditionalTransferLight2))
        ) {
            revert("Invalid array storage 2");
        }
        // Assert - Arrange
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 2);
        assertEq(
            ruleEngineMock.containsRule(ruleConditionalTransferLight1),
            true
        );
        assertEq(
            ruleEngineMock.containsRule(ruleConditionalTransferLight2),
            true
        );

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.ClearRules();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRules();

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 0);
        assertFalse(ruleEngineMock.containsRule(ruleConditionalTransferLight1));
        assertFalse(ruleEngineMock.containsRule(ruleConditionalTransferLight2));
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
        ruleConditionalTransferLightTab[0] = IRule(
            ruleConditionalTransferLight1
        );
        ruleConditionalTransferLightTab[1] = IRule(
            ruleConditionalTransferLight2
        );

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRules,
                ruleConditionalTransferLightTab
            )
        );

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.ClearRules();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRules();

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 0);

        // Can set again the previous rules
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRules,
                ruleConditionalTransferLightTab
            )
        );
        assertEq(resCallBool, true);
        // Arrange before assert

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.ClearRules();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRules();
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 0);

        // Can add previous rule again
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.AddRule(
            ruleConditionalTransferLight1
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight1);
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
        emit RulesManagementModuleInvariantStorage.AddRule(
            ruleConditionalTransferLight1
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight1);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 2);
    }

    function testCannotAddRuleZeroAddress() public {
        // Act
        vm.expectRevert(
            RuleEngine_RulesManagementModule_RuleAddressZeroNotAllowed.selector
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(IRule(address(0x0)));

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotAddARuleAlreadyPresent() public {
        // Act
        vm.expectRevert(
            RuleEngine_RulesManagementModule_RuleAlreadyExists.selector
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanAddARuleAfterThisRuleWasRemoved() public {
        // Arrange - Assert
        address[] memory _rules = ruleEngineMock.rules();
        assertEq(address(_rules[0]), address(ruleConditionalTransferLight));

        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleConditionalTransferLight);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.AddRule(
            ruleConditionalTransferLight
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);

        // Assert
        _rules = ruleEngineMock.rules();
        resUint256 = ruleEngineMock.rulesCount();
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
        vm.expectRevert(
            RuleEngine_RulesManagementModule_RuleDoNotMatch.selector
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleConditionalTransferLight1);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
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
        ruleEngineMock.addRule(ruleConditionalTransferLight1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.RemoveRule(
            ruleConditionalTransferLight1
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleConditionalTransferLight1);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
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
        ruleEngineMock.addRule(ruleConditionalTransferLight1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.RemoveRule(
            ruleConditionalTransferLight
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleConditionalTransferLight);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanRemoveRule() public {
        // Arrange
        // First rule
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight1 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight1);
        // Second rule
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransferLight ruleConditionalTransferLight2 = new RuleConditionalTransferLight(
                CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
                ruleEngineMock
            );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight2);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.RemoveRule(
            ruleConditionalTransferLight1
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleConditionalTransferLight1);

        // Assert
        address[] memory _rules = ruleEngineMock.rules();
        // RuleConditionalTransferLight1 has been removed
        assertEq(address(_rules[0]), address(ruleConditionalTransferLight));
        assertEq(address(_rules[1]), address(ruleConditionalTransferLight2));

        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 2);
    }

    function testRuleLength() public {
        // Act
        resUint256 = ruleEngineMock.rulesCount();

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
        ruleConditionalTransferLightTab[0] = IRule(
            ruleConditionalTransferLight1
        );
        ruleConditionalTransferLightTab[1] = IRule(
            ruleConditionalTransferLight2
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleConditionalTransferLightTab);

        // Act
        resUint256 = ruleEngineMock.rulesCount();

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
        ruleConditionalTransferLightTab[0] = IRule(
            ruleConditionalTransferLight1
        );
        ruleConditionalTransferLightTab[1] = IRule(
            ruleConditionalTransferLight2
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleConditionalTransferLightTab);

        // Act
        address rule = ruleEngineMock.rule(0);

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
        ruleConditionalTransferLightTab[0] = IRule(
            ruleConditionalTransferLight1
        );
        ruleConditionalTransferLightTab[1] = IRule(
            ruleConditionalTransferLight2
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleConditionalTransferLightTab);

        // Act
        address[] memory rules = ruleEngineMock.rules();

        // Assert
        assertEq(ruleConditionalTransferLightTab.length, rules.length);
        for (uint256 i = 0; i < rules.length; ++i) {
            assertEq(
                address(ruleConditionalTransferLightTab[i]),
                address(rules[i])
            );
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
        ruleConditionalTransferLightTab[0] = IRule(
            ruleConditionalTransferLight1
        );
        ruleConditionalTransferLightTab[1] = IRule(
            ruleConditionalTransferLight2
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(
                ruleEngineMock.setRules,
                ruleConditionalTransferLightTab
            )
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        /* uint256 index1 = ruleEngineMock.getRuleIndex(
            ruleConditionalTransferLight1
        );
        uint256 index2 = ruleEngineMock.getRuleIndex(
            ruleConditionalTransferLight2
        );
        // Length of the list because RuleConditionalTransferLight is not in the list
        uint256 index3 = ruleEngineMock.getRuleIndex(
            ruleConditionalTransferLight
        );

        // Assert
        assertEq(index1, 0);
        assertEq(index2, 1);
        assertEq(index3, ruleConditionalTransferLightTab.length);*/
    }
}
