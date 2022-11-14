// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

contract RuleEngineTest is Test, HelperContract, RuleWhitelist {
    RuleEngine ruleEngineMock;
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
        ruleWhitelist = new RuleWhitelist();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(ruleWhitelist);
        resUint256 = ruleEngineMock.ruleLength();

        // Assert
        assertEq(resUint256, 1);
    }

    function testCanSetRules() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab)
        );

        // Assert
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 2);
    }

    function testCannotSetEmptyRulesT1() public {
        // Arrange
        IRule[] memory ruleWhitelistTab = new IRule[](0);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab)
        );

        // Assert
        assertFalse(resCallBool);
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 1);

        // Assert2
        // The call has not to throw an error.
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);
    }

    function testCannotSetEmptyRulesT2() public {
        // Arrange
        IRule[] memory ruleWhitelistTab = new IRule[](2);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert("The array is empty2");

        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab)
        );

        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert1
        assertFalse(resCallBool);
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 1);

        // Assert2
        // The call has not to throw an error.
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);
    }

    function testCanClearRules() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab)
        );

        // Assert - Arrange
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 2);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRules();

        // Assert
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 0);
    }

    function testCanAddRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist1);

        // Assert
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 2);
    }

    function testCannotAddRuleZeroAddress() public {
        // Act
        vm.expectRevert("The rule can't be a zero address");
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(IRule(address(0x0)));

        // Assert
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 1);
    }

    function testCanRemoveWithEmptyRules() public {
        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist);
        // Arrange - Assert
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 0);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist);

        // Assert
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 0);
    }

    function testCanRemoveNonExistantRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist1);

        // Assert
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 1);
    }

    function testCanRemoveLatestRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist1);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist1);

        // Assert
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 1);
    }

    function testCanRemoveFirstRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist1);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist);

        // Assert
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 1);
    }

    function testCanRemoveRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist1);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist2);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRule(ruleWhitelist1);

        // Assert
        IRule[] memory _rules = ruleEngineMock.rules();
        assertEq(address(_rules[0]), address(ruleWhitelist));
        assertEq(address(_rules[1]), address(ruleWhitelist2));

        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 2);
    }

    function testRuleLength() public {
        // Act
        resUint256 = ruleEngineMock.ruleLength();

        // Assert
        assertEq(resUint256, 1);

        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab)
        );

        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        resUint256 = ruleEngineMock.ruleLength();

        // Assert
        assertEq(resUint256, 2);
    }

    function testGetRule() public {
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        IRule rule = ruleEngineMock.rule(0);

        // Assert
        assertEq(address(rule), address(ruleWhitelist1));
    }

    function testGetRules() public {
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        IRule[] memory rules = ruleEngineMock.rules();

        // Assert
        assertEq(ruleWhitelistTab.length, rules.length);
        for (uint256 i = 0; i < rules.length; ++i) {
            assertEq(address(ruleWhitelistTab[i]), address(rules[i]));
        }
    }
}
