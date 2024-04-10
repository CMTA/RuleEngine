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
    uint256 defaultValue = 20;

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

    function testCanDetectTransferRestrictionOK() public {
        // Arrange
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(key, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequestWithApproval(ADDRESS1, ADDRESS2, defaultValue);
        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );

        // Assert
        assertEq(resUint8, 0);
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
    }

    function testMessageForTransferRestrictionNoRule() public {
        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRulesOperation();

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
