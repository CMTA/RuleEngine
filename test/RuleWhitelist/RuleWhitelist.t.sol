// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
@title General functions of the RuleWhitelist
*/
contract RuleWhitelistTest is Test, HelperContract {
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
    }

    function testReturnFalseIfAddressNotWhitelisted() public {
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        // Assert
        assertFalse(resBool);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        // Assert
        assertFalse(resBool);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS3);
        // Assert
        assertFalse(resBool);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(address(0x0));
        // Assert
        assertFalse(resBool);
    }

    function testAddressIsIndicatedAsWhitelisted() public {
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertFalse(resBool);

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);

        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
    }

    function testAddressesIsIndicatedAsWhitelisted() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheWhitelist(address[])",
                whitelist
            )
        );
        assertEq(resCallBool, true);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS3);
        // Assert
        assertFalse(resBool);
    }

    function testCanReturnTransferRestrictionCode() public {
        // Act
        resBool = ruleWhitelist.canReturnTransferRestrictionCode(
            CODE_ADDRESS_FROM_NOT_WHITELISTED
        );
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = ruleWhitelist.canReturnTransferRestrictionCode(
            CODE_ADDRESS_TO_NOT_WHITELISTED
        );
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = ruleWhitelist.canReturnTransferRestrictionCode(
            CODE_NONEXISTENT
        );
        // Assert
        assertFalse(resBool);
    }

    function testReturnTheRightMessageForAGivenCode() public {
        // Assert
        resString = ruleWhitelist.messageForTransferRestriction(
            CODE_ADDRESS_FROM_NOT_WHITELISTED
        );
        // Assert
        assertEq(resString, TEXT_ADDRESS_FROM_NOT_WHITELISTED);
        // Act
        resString = ruleWhitelist.messageForTransferRestriction(
            CODE_ADDRESS_TO_NOT_WHITELISTED
        );
        // Assert
        assertEq(resString, TEXT_ADDRESS_TO_NOT_WHITELISTED);
        // Act
        resString = ruleWhitelist.messageForTransferRestriction(
            CODE_NONEXISTENT
        );
        // Assert
        assertEq(resString, TEXT_CODE_NOT_FOUND);
    }

    function testValidateTransfer() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheWhitelist(address[])",
                whitelist
            )
        );
        assertEq(resCallBool, true);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);

        // Act
        // ADDRESS1 -> ADDRESS2
        resBool = ruleWhitelist.validateTransfer(ADDRESS1, ADDRESS2, 20);
        assertEq(resBool, true);
        // ADDRESS2 -> ADDRESS1
        resBool = ruleWhitelist.validateTransfer(ADDRESS2, ADDRESS1, 20);
        assertEq(resBool, true);
    }

    function testTransferDetectedAsInvalid() public {
        // Act
        resBool = ruleWhitelist.validateTransfer(ADDRESS1, ADDRESS2, 20);
        // Assert
        assertFalse(resBool);
    }

    function testNumberWhitelistedAddress() public {
        // Act
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        // Assert
        assertEq(resUint256, 0);

        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheWhitelist(address[])",
                whitelist
            )
        );
        assertEq(resCallBool, true);
        // Act
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        // Assert
        assertEq(resUint256, 2);
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "removeAddressesFromTheWhitelist(address[])",
                whitelist
            )
        );
        // Arrange - Assert
        assertEq(resCallBool, true);
        // Act
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        // Assert
        assertEq(resUint256, 0);
    }

    function testDetectTransferRestrictionFrom() public {
        // Act
        resUint8 = ruleWhitelist.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );
        // Assert
        assertEq(resUint8, CODE_ADDRESS_FROM_NOT_WHITELISTED);
    }

    function testDetectTransferRestrictionTo() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);
        // Act
        resUint8 = ruleWhitelist.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );
        // Assert
        assertEq(resUint8, CODE_ADDRESS_TO_NOT_WHITELISTED);
    }

    function testDetectTransferRestrictionOk() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS2);
        // Act
        resUint8 = ruleWhitelist.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );
        // Assert
        assertEq(resUint8, NO_ERROR);
    }
}
