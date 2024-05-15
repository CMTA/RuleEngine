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

    TransferRequestKeyElement transferRequestInput = TransferRequestKeyElement({
            from: ADDRESS1,
            to: ADDRESS2,
            value:defaultValue
          });

    // Arrange
    function setUp() public {
        ruleConditionalTransfer = new RuleConditionalTransfer(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,          
            options
        );
    }

    function testCanDetectTransferRestrictionOK() public {
        // Arrange
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequestWithApproval(transferRequestInput);
        // Act
        resUint8 = ruleConditionalTransfer.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );

        // Assert
        assertEq(resUint8, 0);
    }

    function testCanDetectTransferRestrictionNotOk() public {
        // Act
        resUint8 = ruleConditionalTransfer.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);
    }


    function testMessageForTransferRestrictionWithUnknownRestrictionCode()
        public
    {
        // Act
        resString = ruleConditionalTransfer.messageForTransferRestriction(50);

        // Assert
        assertEq(resString, "Unknown restriction code");
    }

    function testMessageForTransferRestrictionWithValidRC() public {
        // Act
        resString = ruleConditionalTransfer.messageForTransferRestriction(
            CODE_TRANSFER_REQUEST_NOT_APPROVED
        );

        // Assert
        assertEq(resString, TEXT_TRANSFER_REQUEST_NOT_APPROVED);
    }
}
