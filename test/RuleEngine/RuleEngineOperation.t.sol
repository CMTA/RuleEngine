// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";
//ADmin, forwarder irrect /RuleEngine
/**
* @title General functions of the RuleEngine
*/
contract RuleEngineOperationTest is Test, HelperContract {
    RuleEngine ruleEngineMock;
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;



    // Arrange
    function setUp() public {
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        ruleVinkulierung = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,            
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );


        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleVinkulierung);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCansetRulesOperation() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,            
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung2 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        address[] memory RuleVinkulierungTab = new address[](2);
        RuleVinkulierungTab[0] = address(IRuleOperation(RuleVinkulierung1));
        RuleVinkulierungTab[1] = address(IRuleOperation(RuleVinkulierung2));
        // Act
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(RuleVinkulierung1));
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(RuleVinkulierung2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
        );

        // Assert
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 2);
    }

    function testCannotSetRuleIfARuleIsAlreadyPresent() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        address[] memory RuleVinkulierungTab = new address[](2);
        RuleVinkulierungTab[0] = address(RuleVinkulierung1);
        RuleVinkulierungTab[1] = address(RuleVinkulierung1);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert(RuleEngine_RuleAlreadyExists.selector);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
        );

        // Assert
        // I do not know why but the function call return true
        // if the call is reverted with the message indicated in expectRevert
        // assertFalse(resCallBool);
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCannotSetEmptyRulesT1() public {
        // Arrange
        address[] memory RuleVinkulierungTab = new address[](0);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
        );

        // Assert
        assertFalse(resCallBool);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);

        // Assert2
        // No rule => transfer valid
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
        assertTrue(resBool);
    }

    function testCannotSetEmptyRulesT2() public {
        // Arrange
        address[] memory RuleVinkulierungTab = new address[](2);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert("The array is empty2");

        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
        );

        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert1
        assertFalse(resCallBool);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);

        // Assert2
        // No rule => transfer valid
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
        assertTrue(resBool);
    }

    function testCanClearRules() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung2 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        address[] memory RuleVinkulierungTab = new address[](2);
        RuleVinkulierungTab[0] = address(IRuleOperation(RuleVinkulierung1));
        RuleVinkulierungTab[1] = address(IRuleOperation(RuleVinkulierung2));

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
        );
        ruleEngineMock.rulesOperation();
        // Assert - Arrange
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 2);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRulesOperation();

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 0);
    }

    function testCanClearRulesAndAddAgain() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung2 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        address[] memory RuleVinkulierungTab = new address[](2);
        RuleVinkulierungTab[0] = address(IRuleOperation(RuleVinkulierung1));
        RuleVinkulierungTab[1] = address(IRuleOperation(RuleVinkulierung2));

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
        );

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRulesOperation();

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 0);

        // Can set again the previous rules
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
        );
        assertEq(resCallBool, true);
        // Arrange before assert

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRulesOperation();
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 0);

        // Can add previous rule again
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(RuleVinkulierung1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleVinkulierung1);
    }

    function testCanAddRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );

        // Act
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(RuleVinkulierung1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleVinkulierung1);

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
        ruleEngineMock.addRuleOperation(ruleVinkulierung);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanAddARuleAfterThisRuleWasRemoved() public {
        // Arrange - Assert
        address[] memory _rules = ruleEngineMock.rulesOperation();
        assertEq(address(_rules[0]), address(ruleVinkulierung));

        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(ruleVinkulierung, 0);

        // Act
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(ruleVinkulierung));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleVinkulierung);

        // Assert
        _rules = ruleEngineMock.rulesOperation();
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveNonExistantRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );

        // Act
        vm.expectRevert(RuleEngine_RuleDoNotMatch.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(RuleVinkulierung1, 0);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveLatestRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleVinkulierung1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RemoveRule(address(RuleVinkulierung1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(RuleVinkulierung1, 1);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveFirstRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleVinkulierung1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RemoveRule(address(ruleVinkulierung));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(ruleVinkulierung, 0);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveRuleOperation() public {
        // Arrange
        // First rule
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleVinkulierung1);
        // Second rule
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleVinkulierung RuleVinkulierung2 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleVinkulierung2);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RemoveRule(address(RuleVinkulierung1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(RuleVinkulierung1, 1);

        // Assert
        address[] memory _rules = ruleEngineMock.rulesOperation();
        // RuleVinkulierung1 has been removed
        assertEq(address(_rules[0]), address(ruleVinkulierung));
        assertEq(address(_rules[1]), address(RuleVinkulierung2));

        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 2);
    }

    function testRuleLength() public {
        // Act
        resUint256 = ruleEngineMock.rulesCountOperation();

        // Assert
        assertEq(resUint256, 1);

        // Arrange
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        RuleVinkulierung RuleVinkulierung2 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        address[] memory RuleVinkulierungTab = new address[](2);
        RuleVinkulierungTab[0] = address(IRuleOperation(RuleVinkulierung1));
        RuleVinkulierungTab[1] = address(IRuleOperation(RuleVinkulierung2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
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
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        RuleVinkulierung RuleVinkulierung2 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        address[] memory RuleVinkulierungTab = new address[](2);
        RuleVinkulierungTab[0] = address(IRuleOperation(RuleVinkulierung1));
        RuleVinkulierungTab[1] = address(IRuleOperation(RuleVinkulierung2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        address rule = ruleEngineMock.ruleOperation(0);

        // Assert
        assertEq(address(rule), address(RuleVinkulierung1));
    }

    function testGetRules() public {
        // Arrange
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        RuleVinkulierung RuleVinkulierung2 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        address[] memory RuleVinkulierungTab = new address[](2);
        RuleVinkulierungTab[0] = address(IRuleOperation(RuleVinkulierung1));
        RuleVinkulierungTab[1] = address(IRuleOperation(RuleVinkulierung2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        address[] memory rules = ruleEngineMock.rulesOperation();

        // Assert
        assertEq(RuleVinkulierungTab.length, rules.length);
        for (uint256 i = 0; i < rules.length; ++i) {
            assertEq(address(RuleVinkulierungTab[i]), address(rules[i]));
        }
    }

    function testCanGetRuleIndex() public {
        // Arrange
        RuleVinkulierung RuleVinkulierung1 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        RuleVinkulierung RuleVinkulierung2 = new RuleVinkulierung(
            VINKULIERUNG_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
        address[] memory RuleVinkulierungTab = new address[](2);
        RuleVinkulierungTab[0] = address(IRuleOperation(RuleVinkulierung1));
        RuleVinkulierungTab[1] = address(IRuleOperation(RuleVinkulierung2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleVinkulierungTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        uint256 index1 = ruleEngineMock.getRuleIndexOperation(RuleVinkulierung1);
        uint256 index2 = ruleEngineMock.getRuleIndexOperation(RuleVinkulierung2);
        // Length of the list because RuleVinkulierung is not in the list
        uint256 index3 = ruleEngineMock.getRuleIndexOperation(ruleVinkulierung);

        // Assert
        assertEq(index1, 0);
        assertEq(index2, 1);
        assertEq(index3, RuleVinkulierungTab.length);
    }
}
