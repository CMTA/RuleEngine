// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";
import "src/rules/RuleSanctionList.sol";
import "../utils/SanctionListOracle.sol";
/**
@title General functions of the ruleSanctionList
*/
contract RuleSanctionlistTest is Test, HelperContract {
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;
    SanctionListOracle sanctionlistOracle;
    RuleSanctionList ruleSanctionList;
    // Arrange
    function setUp() public {
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        sanctionlistOracle = new SanctionListOracle();
        sanctionlistOracle.addToSanctionsList(ATTACKER);
        ruleSanctionList = new RuleSanctionList(
            SANCTIONLIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        ruleSanctionList.setSanctionListOracle(address(sanctionlistOracle));
    }

    function testCanReturnTransferRestrictionCode() public {
        // Act
        resBool = ruleSanctionList.canReturnTransferRestrictionCode(
           CODE_ADDRESS_FROM_IS_SANCTIONED
        );
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = ruleSanctionList.canReturnTransferRestrictionCode(
            CODE_ADDRESS_TO_IS_SANCTIONED
        );
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = ruleSanctionList.canReturnTransferRestrictionCode(
            CODE_NONEXISTENT
        );
        // Assert
        assertFalse(resBool);
    }

    function testReturnTheRightMessageForAGivenCode() public {
        // Assert
        resString = ruleSanctionList.messageForTransferRestriction(
             CODE_ADDRESS_FROM_IS_SANCTIONED
        );
        // Assert
        assertEq(resString, TEXT_ADDRESS_FROM_IS_SANCTIONED);
        // Act
        resString = ruleSanctionList.messageForTransferRestriction(
             CODE_ADDRESS_TO_IS_SANCTIONED
        );
        // Assert
        assertEq(resString, TEXT_ADDRESS_TO_IS_SANCTIONED);
        // Act
        resString = ruleSanctionList.messageForTransferRestriction(
            CODE_NONEXISTENT
        );
        // Assert
        assertEq(resString, TEXT_CODE_NOT_FOUND);
    }

    function testValidateTransfer() public {
        // Act
        // ADDRESS1 -> ADDRESS2
        resBool = ruleSanctionList.validateTransfer(ADDRESS1, ADDRESS2, 20);
        assertEq(resBool, true);
        // ADDRESS2 -> ADDRESS1
        resBool = ruleSanctionList.validateTransfer(ADDRESS2, ADDRESS1, 20);
        assertEq(resBool, true);
    }

    function testTransferFromDetectedAsInvalid() public {
        // Act
        resBool = ruleSanctionList.validateTransfer(ATTACKER, ADDRESS2, 20);
        // Assert
        assertFalse(resBool);
    }

    function testTransferToDetectedAsInvalid() public {
        // Act
        resBool = ruleSanctionList.validateTransfer(ADDRESS1, ATTACKER, 20);
        // Assert
        assertFalse(resBool);
    }

    function testDetectTransferRestrictionFrom() public {
        // Act
        resUint8 = ruleSanctionList.detectTransferRestriction(
            ATTACKER,
            ADDRESS2,
            20
        );
        // Assert
        assertEq(resUint8, CODE_ADDRESS_FROM_IS_SANCTIONED);
    }

    function testDetectTransferRestrictionTo() public {
        // Act
        resUint8 = ruleSanctionList.detectTransferRestriction(
            ADDRESS1,
            ATTACKER,
            20
        );
        // Assert
        assertEq(resUint8, CODE_ADDRESS_TO_IS_SANCTIONED);
    }

    function testDetectTransferRestrictionOk() public {
        // Act
        resUint8 = ruleSanctionList.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );
        // Assert
        assertEq(resUint8, NO_ERROR);
    }
}
