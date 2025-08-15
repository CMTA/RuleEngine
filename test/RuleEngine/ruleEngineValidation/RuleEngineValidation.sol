// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";

/**
 * @title General functions of the RuleEngine
 */
contract RuleEngineTest is Test, HelperContract {
    IRule[] ruleWhitelistTab = new IRule[](2);

    // Arrange
    function setUp() public {
        ruleWhitelist = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanSetRules() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.AddRule(ruleWhitelist1);
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.AddRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleWhitelistTab);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 2);
    }

    function testCannotSetRuleWithSameRulePresentTwice() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        ruleWhitelistTab[0] = ruleWhitelist1;
        ruleWhitelistTab[1] = ruleWhitelist1;

        // Act
        vm.expectRevert(
            RuleEngine_RulesManagementModule_RuleAlreadyExists.selector
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleWhitelistTab);
        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanSetWithTheSameRuleAlreadyPresent() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        ruleWhitelistTab = new IRule[](1);
        ruleWhitelistTab[0] = ruleWhitelist1;

        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleWhitelistTab);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRules, ruleWhitelistTab)
        );

        // Assert
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotSetEmptyRulesT1() public {
        // Arrange
        ruleWhitelistTab = new IRule[](0);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert(
            RulesManagementModuleInvariantStorage
                .RuleEngine_RulesManagementModule_ArrayIsEmpty
                .selector
        );
        ruleEngineMock.setRules(ruleWhitelistTab);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);

        // Assert2
        // false because the ruleWhitelist is still present
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);

        resBool = ruleEngineMock.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );
        // Assert
        assertFalse(resBool);
    }

    function testCannotSetEmptyRulesT2() public {
        // Arrange
        ruleWhitelistTab = new IRule[](0);
        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert(
            RulesManagementModuleInvariantStorage
                .RuleEngine_RulesManagementModule_ArrayIsEmpty
                .selector
        );

        ruleEngineMock.setRules(ruleWhitelistTab);

        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert1
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);

        // Assert2
        // false because the ruleWhitelist is still present
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);

        resBool = ruleEngineMock.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );
        // Assert
        assertFalse(resBool);
    }

    function testCanClearRules() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleWhitelistTab);
        ruleEngineMock.rules();
        // Assert - Arrange
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 2);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.ClearRules();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRules();

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 0);
    }

    function testCanClearRulesAndAddAgain() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleWhitelistTab);

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
        ruleEngineMock.setRules(ruleWhitelistTab);
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
        emit RulesManagementModuleInvariantStorage.AddRule(ruleWhitelist1);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist1);
    }

    function testCanAddRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.AddRule(ruleWhitelist1);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist1);

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
        ruleEngineMock.addRule(ruleWhitelist);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanAddARuleAfterThisRuleWasRemoved() public {
        // Arrange - Assert
        address[] memory _rules = ruleEngineMock.rules();
        assertEq(address(_rules[0]), address(ruleWhitelist));

        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.AddRule(ruleWhitelist);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist);

        // Assert
        _rules = ruleEngineMock.rules();
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanRemoveNonExistantRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );

        // Act
        vm.expectRevert(
            RuleEngine_RulesManagementModule_RuleDoNotMatch.selector
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist1);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanRemoveLatestRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.RemoveRule(ruleWhitelist1);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist1);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanRemoveFirstRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.RemoveRule(ruleWhitelist);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanRemoveRule() public {
        // Arrange
        // First rule
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist1);
        // Second rule
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist2);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RulesManagementModuleInvariantStorage.RemoveRule(ruleWhitelist1);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist1);

        // Assert
        address[] memory _rules = ruleEngineMock.rules();
        // ruleWhitelist1 has been removed
        assertEq(address(_rules[0]), address(ruleWhitelist));
        assertEq(address(_rules[1]), address(ruleWhitelist2));

        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 2);
    }

    function testRuleLength() public {
        // Act
        resUint256 = ruleEngineMock.rulesCount();

        // Assert
        assertEq(resUint256, 1);

        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleWhitelistTab);

        // Act
        resUint256 = ruleEngineMock.rulesCount();

        // Assert
        assertEq(resUint256, 2);
    }

    function testGetRule() public {
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleWhitelistTab);

        // Act
        address rule = ruleEngineMock.rule(0);

        // Assert
        assertEq(address(rule), address(ruleWhitelist1));
    }

    function testGetRules() public {
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleWhitelistTab);

        // Act
        address[] memory rules = ruleEngineMock.rules();

        // Assert
        assertEq(ruleWhitelistTab.length, rules.length);
        for (uint256 i = 0; i < rules.length; ++i) {
            assertEq(address(ruleWhitelistTab[i]), address(rules[i]));
        }
    }

    function testCanGetRuleIndex() public {
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.setRules(ruleWhitelistTab);

        // Act
        /* uint256 index1 = ruleEngineMock.getRuleIndex(ruleWhitelist1);
        uint256 index2 = ruleEngineMock.getRuleIndex(ruleWhitelist2);
        // Length of the list because ruleWhitelist is not in the list
        uint256 index3 = ruleEngineMock.getRuleIndex(ruleWhitelist);

        // Assert
        assertEq(index1, 0);
        assertEq(index2, 1);
        assertEq(index3, ruleWhitelistTab.length);*/
    }

    function testMessageForTransferRestrictionWithUnknownRestrictionCodeAndNoRuless()
        public
    {
        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRules();
        // Act
        resString = ruleEngineMock.messageForTransferRestriction(50);

        // Assert
        assertEq(resString, "Unknown restriction code");
    }
}
