// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";

/**
 * @title General functions of the RuleWhitelist
 */
contract RuleWhitelistTest is Test, HelperContract {
    // Arrange
    function setUp() public {
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
    }

    function _addAddressesToTheList() internal {
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheList(address[])",
                whitelist
            )
        );
        // Assert
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 2);
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        assertEq(resBool, true);
    }

    function testReturnFalseIfAddressNotWhitelisted() public {
        // Act
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        // Assert
        assertFalse(resBool);
        // Act
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        // Assert
        assertFalse(resBool);
        // Act
        resBool = ruleWhitelist.addressIsListed(ADDRESS3);
        // Assert
        assertFalse(resBool);
        // Act
        resBool = ruleWhitelist.addressIsListed(address(0x0));
        // Assert
        assertFalse(resBool);
    }

    function testAddressIsIndicatedAsWhitelisted() public {
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertFalse(resBool);

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);

        // Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
    }

    function testAddressesIsIndicatedAsWhitelisted() public {
        // Arrange
        _addAddressesToTheList();
        // Act
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = ruleWhitelist.addressIsListed(ADDRESS3);
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

    function testCanTransfer() public {
        // Arrange
        _addAddressesToTheList();
        // Act
        // ADDRESS1 -> ADDRESS2
        resBool = ruleWhitelist.canTransfer(ADDRESS1, ADDRESS2, 20);
        assertEq(resBool, true);
        // ADDRESS2 -> ADDRESS1
        resBool = ruleWhitelist.canTransfer(ADDRESS2, ADDRESS1, 20);
        assertEq(resBool, true);

        // Spender is not whitelisted
        resBool = ruleWhitelist.canTransferFrom(
            ADDRESS3,
            ADDRESS2,
            ADDRESS1,
            20
        );
        assertEq(resBool, false);

        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS3);

        resBool = ruleWhitelist.canTransferFrom(
            ADDRESS3,
            ADDRESS2,
            ADDRESS1,
            20
        );
        assertEq(resBool, true);
    }

    function testTransferDetectedAsInvalid() public {
        // Act
        resBool = ruleWhitelist.canTransfer(ADDRESS1, ADDRESS2, 20);
        // Assert
        assertFalse(resBool);
    }

    function testNumberListedAddress() public {
        // Act
        resUint256 = ruleWhitelist.numberListedAddress();
        // Assert
        assertEq(resUint256, 0);

        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheList(address[])",
                whitelist
            )
        );
        assertEq(resCallBool, true);
        // Act
        resUint256 = ruleWhitelist.numberListedAddress();
        // Assert
        assertEq(resUint256, 2);
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "removeAddressesFromTheList(address[])",
                whitelist
            )
        );
        // Arrange - Assert
        assertEq(resCallBool, true);
        // Act
        resUint256 = ruleWhitelist.numberListedAddress();
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

    function testDetectTransferRestrictionSpender() public {
        // Act
        resUint8 = ruleWhitelist.detectTransferRestrictionFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );
        // Assert
        assertEq(resUint8, CODE_ADDRESS_SPENDER_NOT_WHITELISTED);
    }

    function testDetectTransferRestrictionTo() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);
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
        ruleWhitelist.addAddressToTheList(ADDRESS1);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS2);
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
