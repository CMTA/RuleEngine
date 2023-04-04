// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
@title tests concerning the restrictions and validation for the transfers
*/
contract RuleEngineRestrictionTest is Test, HelperContract, RuleWhitelist {
    RuleEngine ruleEngineMock;
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;
    RuleWhitelist ruleWhitelist1;

    // Arrange
    function setUp() public {
        ruleWhitelist = new RuleWhitelist();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist);
        // Arrange - Assert
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 1);

        // Arrange
        ruleWhitelist1 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](1);
        ruleWhitelistTab[0] = ruleWhitelist1;
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool success, ) = address(ruleEngineMock).call(
            abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab)
        );

        // Arrange - Assert
        assertEq(success, true);
    }

    function testCanDetectTransferRestrictionOK() public {
        // Arrange
        ruleWhitelist1.addAddressToTheWhitelist(ADDRESS1);
        ruleWhitelist1.addAddressToTheWhitelist(ADDRESS2);

        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, 0);
    }

    function testCanDetectTransferRestrictionWithFrom() public {
        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_ADDRESS_FROM_NOT_WHITELISTED);
    }

    function testCanDetectTransferRestrictionWithTo() public {
        // Arrange
        ruleWhitelist1.addAddressToTheWhitelist(ADDRESS1);

        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_ADDRESS_TO_NOT_WHITELISTED);
    }

    function testMessageForTransferRestrictionWithValidRC() public {
        // Act
        resString = ruleEngineMock.messageForTransferRestriction(
            CODE_ADDRESS_FROM_NOT_WHITELISTED
        );

        // Assert
        assertEq(resString, TEXT_ADDRESS_FROM_NOT_WHITELISTED);
    }

    function testMessageForTransferRestrictionNoRule() public {
        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRules();

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

    function testValidateTransferOK() public {
        // Arrange
        ruleWhitelist1.addAddressToTheWhitelist(ADDRESS1);
        ruleWhitelist1.addAddressToTheWhitelist(ADDRESS2);

        // Act
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertEq(resBool, true);
    }

    function testValidateTransferRestricted() public {
        // Act
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertFalse(resBool);
    }
}
