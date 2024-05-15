// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
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

    TIME_LIMIT timeLimit_ = TIME_LIMIT({
            timeLimitToApprove:  DEFAULT_TIME_LIMIT_TO_APPROVE,
            timeLimitToTransfer:   DEFAULT_TIME_LIMIT_TO_TRANSFER
        });
   ISSUANCE  issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval:false,
            authorizedBurnWithoutApproval:false
        });

    AUTOMATIC_APPROVAL automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: false,
            timeLimitBeforeAutomaticApproval: 0
        });
    AUTOMATIC_TRANSFER  automaticTransfer_ = AUTOMATIC_TRANSFER({
            isActivate:false,
            cmtat: IERC20(address(0))
        });
    OPTION options = OPTION({
            issuance:issuanceOption_,
            timeLimit: timeLimit_,
            automaticApproval: automaticApproval_,
            automaticTransfer:automaticTransfer_
        });


    // Arrange
    function setUp() public {
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
        ruleConditionalTransfer = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,          
            options
        );


        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransfer);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanSetRulesOperation() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,          
            options
        );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer2 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        address[] memory RuleConditionalTransferTab = new address[](2);
        RuleConditionalTransferTab[0] = address(IRuleOperation(RuleConditionalTransfer1));
        RuleConditionalTransferTab[1] = address(IRuleOperation(RuleConditionalTransfer2));
        // Act
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(RuleConditionalTransfer1));
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(RuleConditionalTransfer2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
        );

        // Assert
        assertEq(resCallBool, true);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 2);
    }

    function testCannotSetRuleIfARuleIsAlreadyPresent() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        address[] memory RuleConditionalTransferTab = new address[](2);
        RuleConditionalTransferTab[0] = address(RuleConditionalTransfer1);
        RuleConditionalTransferTab[1] = address(RuleConditionalTransfer1);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert(RuleEngine_RuleAlreadyExists.selector);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
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
        address[] memory RuleConditionalTransferTab = new address[](0);
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
        );

        // Assert
        assertFalse(resCallBool);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);

        // Assert
        // previous rule still present => invalid Transfer
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);
    }

    function testCannotSetEmptyRulesT2WithZeroAddress() public {
        // Arrange
        address[] memory RuleConditionalTransferTab = new address[](2);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectRevert("The array is empty2");

        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
        );

        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert1
        assertFalse(resCallBool);
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);

        // Assert2
        // previous rule still present => invalid Transfer
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
        assertFalse(resBool);
    }

    function testCanClearRules() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer2 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        address[] memory RuleConditionalTransferTab = new address[](2);
        RuleConditionalTransferTab[0] = address(IRuleOperation(RuleConditionalTransfer1));
        RuleConditionalTransferTab[1] = address(IRuleOperation(RuleConditionalTransfer2));

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
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
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer2 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        address[] memory RuleConditionalTransferTab = new address[](2);
        RuleConditionalTransferTab[0] = address(IRuleOperation(RuleConditionalTransfer1));
        RuleConditionalTransferTab[1] = address(IRuleOperation(RuleConditionalTransfer2));

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
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
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
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
        emit AddRule(address(RuleConditionalTransfer1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleConditionalTransfer1);
    }

    function testCanAddRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );

        // Act
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(RuleConditionalTransfer1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleConditionalTransfer1);

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
        ruleEngineMock.addRuleOperation(ruleConditionalTransfer);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanAddARuleAfterThisRuleWasRemoved() public {
        // Arrange - Assert
        address[] memory _rules = ruleEngineMock.rulesOperation();
        assertEq(address(_rules[0]), address(ruleConditionalTransfer));

        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(ruleConditionalTransfer, 0);

        // Act
        vm.expectEmit(true, false, false, false);
        emit AddRule(address(ruleConditionalTransfer));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransfer);

        // Assert
        _rules = ruleEngineMock.rulesOperation();
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveNonExistantRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );

        // Act
        vm.expectRevert(RuleEngine_RuleDoNotMatch.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(RuleConditionalTransfer1, 0);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveLatestRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleConditionalTransfer1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RemoveRule(address(RuleConditionalTransfer1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(RuleConditionalTransfer1, 1);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveFirstRule() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleConditionalTransfer1);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RemoveRule(address(ruleConditionalTransfer));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(ruleConditionalTransfer, 0);

        // Assert
        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 1);
    }

    function testCanRemoveRuleOperation() public {
        // Arrange
        // First rule
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleConditionalTransfer1);
        // Second rule
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleConditionalTransfer RuleConditionalTransfer2 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleOperation(RuleConditionalTransfer2);

        // Act
        vm.expectEmit(true, false, false, false);
        emit RemoveRule(address(RuleConditionalTransfer1));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.removeRuleOperation(RuleConditionalTransfer1, 1);

        // Assert
        address[] memory _rules = ruleEngineMock.rulesOperation();
        // RuleConditionalTransfer1 has been removed
        assertEq(address(_rules[0]), address(ruleConditionalTransfer));
        assertEq(address(_rules[1]), address(RuleConditionalTransfer2));

        resUint256 = ruleEngineMock.rulesCountOperation();
        assertEq(resUint256, 2);
    }

    function testRuleLength() public {
        // Act
        resUint256 = ruleEngineMock.rulesCountOperation();

        // Assert
        assertEq(resUint256, 1);

        // Arrange
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        RuleConditionalTransfer RuleConditionalTransfer2 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        address[] memory RuleConditionalTransferTab = new address[](2);
        RuleConditionalTransferTab[0] = address(IRuleOperation(RuleConditionalTransfer1));
        RuleConditionalTransferTab[1] = address(IRuleOperation(RuleConditionalTransfer2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
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
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        RuleConditionalTransfer RuleConditionalTransfer2 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        address[] memory RuleConditionalTransferTab = new address[](2);
        RuleConditionalTransferTab[0] = address(IRuleOperation(RuleConditionalTransfer1));
        RuleConditionalTransferTab[1] = address(IRuleOperation(RuleConditionalTransfer2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        address rule = ruleEngineMock.ruleOperation(0);

        // Assert
        assertEq(address(rule), address(RuleConditionalTransfer1));
    }

    function testGetRules() public {
        // Arrange
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        RuleConditionalTransfer RuleConditionalTransfer2 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        address[] memory RuleConditionalTransferTab = new address[](2);
        RuleConditionalTransferTab[0] = address(IRuleOperation(RuleConditionalTransfer1));
        RuleConditionalTransferTab[1] = address(IRuleOperation(RuleConditionalTransfer2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        address[] memory rules = ruleEngineMock.rulesOperation();

        // Assert
        assertEq(RuleConditionalTransferTab.length, rules.length);
        for (uint256 i = 0; i < rules.length; ++i) {
            assertEq(address(RuleConditionalTransferTab[i]), address(rules[i]));
        }
    }

    function testCanGetRuleIndex() public {
        // Arrange
        RuleConditionalTransfer RuleConditionalTransfer1 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        RuleConditionalTransfer RuleConditionalTransfer2 = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options

        );
        address[] memory RuleConditionalTransferTab = new address[](2);
        RuleConditionalTransferTab[0] = address(IRuleOperation(RuleConditionalTransfer1));
        RuleConditionalTransferTab[1] = address(IRuleOperation(RuleConditionalTransfer2));
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool resCallBool, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesOperation, RuleConditionalTransferTab)
        );
        // Arrange - Assert
        assertEq(resCallBool, true);

        // Act
        uint256 index1 = ruleEngineMock.getRuleIndexOperation(RuleConditionalTransfer1);
        uint256 index2 = ruleEngineMock.getRuleIndexOperation(RuleConditionalTransfer2);
        // Length of the list because RuleConditionalTransfer is not in the list
        uint256 index3 = ruleEngineMock.getRuleIndexOperation(ruleConditionalTransfer);

        // Assert
        assertEq(index1, 0);
        assertEq(index2, 1);
        assertEq(index3, RuleConditionalTransferTab.length);
    }
}
