// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
@title General functions of the RuleEngine
*/
contract RuleEngineTest is Test, HelperContract {
    RuleEngine ruleEngineMock;
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
        ruleWhitelist = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleValidation(ruleWhitelist);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);
    }

    function testCansetRulesValidation() public {
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
        address[] memory ruleWhitelistTab = new address[](2);
        ruleWhitelistTab[0] = address(IRuleValidation(ruleWhitelist1));
        ruleWhitelistTab[1] = address(IRuleValidation(ruleWhitelist2));
        // Act
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(ruleWhitelist1));
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(ruleWhitelist2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );

        // Assert
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 2);
    }

    function testCannotSetRuleIfARuleIsAlreadyPresent() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        address[] memory ruleWhitelistTab = new address[](2);
        ruleWhitelistTab[0] = address(ruleWhitelist1);
        ruleWhitelistTab[1] = address(ruleWhitelist1);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert(RuleEngine_RuleAlreadyExists.selector);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );

        // Assert
        // I do not know why but the function call return true
        // if the call is reverted with the message indicated in expectRevert
        // assertFalse(resCallBool);
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);
    }

    function testCannotSetEmptyRulesT1() public {
        // Arrange
        address[] memory ruleWhitelistTab = new address[](0);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );

        // Assert
        assertFalse(resCallBool);
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);

        // Assert2
        // The call has not to throw an error.
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);
    }

    function testCannotSetEmptyRulesT2() public {
        // Arrange
        address[] memory ruleWhitelistTab = new address[](2);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert("The array is empty2");

        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );

        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert1
        assertFalse(resCallBool);
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);

        // Assert2
        // The call has not to throw an error.
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
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
        address[] memory ruleWhitelistTab = new address[](2);
        ruleWhitelistTab[0] = address(IRuleValidation(ruleWhitelist1));
        ruleWhitelistTab[1] = address(IRuleValidation(ruleWhitelist2));

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );
        ruleEngineMock.rulesValidation();
        // Assert - Arrange
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 2);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRulesValidation();

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
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
        address[] memory ruleWhitelistTab = new address[](2);
        ruleWhitelistTab[0] = address(IRuleValidation(ruleWhitelist1));
        ruleWhitelistTab[1] = address(IRuleValidation(ruleWhitelist2));

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRulesValidation();

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 0);

        // Can set again the previous rules
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );
        assertEq(resCallBool, true);
        // Arrange before assert

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRulesValidation();
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 0);

        // Can add previous rule again
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(ruleWhitelist1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleValidation(ruleWhitelist1);
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
        emit AddRule(address(ruleWhitelist1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleValidation(ruleWhitelist1);

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 2);
    }

    function testCannotAddRuleZeroAddress() public {
        // Act
        vm.expectRevert(RuleEngine_RuleAddressZeroNotAllowed.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleValidation(IRuleValidation(address(0x0)));

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);
    }

    function testCannotAddARuleAlreadyPresent() public {
        // Act
        vm.expectRevert(RuleEngine_RuleAlreadyExists.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleValidation(ruleWhitelist);

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);
    }

    function testCanAddARuleAfterThisRuleWasRemoved() public {
        // Arrange - Assert
        address[] memory _rules = ruleEngineMock.rulesValidation();
        assertEq(address(_rules[0]), address(ruleWhitelist));

        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleValidation(ruleWhitelist, 0);

        // Act
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(ruleWhitelist));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleValidation(ruleWhitelist);

        // Assert
        _rules = ruleEngineMock.rulesValidation();
        resUint256 = ruleEngineMock.rulesCountValidation();
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
        vm.expectRevert(RuleEngine_RuleDoNotMatch.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleValidation(ruleWhitelist1, 0);

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
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
        ruleEngineMock.addRuleValidation(ruleWhitelist1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RemoveRule(address(ruleWhitelist1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleValidation(ruleWhitelist1, 1);

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
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
        ruleEngineMock.addRuleValidation(ruleWhitelist1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RemoveRule(address(ruleWhitelist));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleValidation(ruleWhitelist, 0);

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveRuleValidation() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleValidation(ruleWhitelist1);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleValidation(ruleWhitelist2);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RemoveRule(address(ruleWhitelist1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleValidation(ruleWhitelist1, 1);

        // Assert
        address[] memory _rules = ruleEngineMock.rulesValidation();
        assertEq(address(_rules[0]), address(ruleWhitelist));
        assertEq(address(_rules[1]), address(ruleWhitelist2));

        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 2);
    }

    function testRuleLength() public {
        // Act
        resUint256 = ruleEngineMock.rulesCountValidation();

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
        address[] memory ruleWhitelistTab = new address[](2);
        ruleWhitelistTab[0] = address(IRuleValidation(ruleWhitelist1));
        ruleWhitelistTab[1] = address(IRuleValidation(ruleWhitelist2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );

        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        resUint256 = ruleEngineMock.rulesCountValidation();

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
        address[] memory ruleWhitelistTab = new address[](2);
        ruleWhitelistTab[0] = address(IRuleValidation(ruleWhitelist1));
        ruleWhitelistTab[1] = address(IRuleValidation(ruleWhitelist2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        address rule = ruleEngineMock.ruleValidation(0);

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
        address[] memory ruleWhitelistTab = new address[](2);
        ruleWhitelistTab[0] = address(IRuleValidation(ruleWhitelist1));
        ruleWhitelistTab[1] = address(IRuleValidation(ruleWhitelist2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        address[] memory rules = ruleEngineMock.rulesValidation();

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
        address[] memory ruleWhitelistTab = new address[](2);
        ruleWhitelistTab[0] = address(IRuleValidation(ruleWhitelist1));
        ruleWhitelistTab[1] = address(IRuleValidation(ruleWhitelist2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        uint256 index1 = ruleEngineMock.getRuleIndexValidation(ruleWhitelist1);
        uint256 index2 = ruleEngineMock.getRuleIndexValidation(ruleWhitelist2);
        // Length of the list because ruleWhitelist is not in the list
        uint256 index3 = ruleEngineMock.getRuleIndexValidation(ruleWhitelist);

        // Assert
        assertEq(index1, 0);
        assertEq(index2, 1);
        assertEq(index3, ruleWhitelistTab.length);
    }
}
