// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";

/**
 * @title Tests the functions to remove addresses from the whitelist
 */
contract RuleWhitelistRemoveTest is Test, HelperContract {
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
        emit AddAddressesToTheList(whitelist);
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

    function testremoveAddressFromTheList() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);

        // Arrange - Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        emit RemoveAddressFromTheList(ADDRESS1);
        ruleWhitelist.removeAddressFromTheList(ADDRESS1);

        // Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertFalse(resBool);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 0);
    }

    function testremoveAddressesFromTheList() public {
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
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        assertEq(resBool, true);

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        emit RemoveAddressesFromTheList(whitelist);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "removeAddressesFromTheList(address[])",
                whitelist
            )
        );
        // Assert
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertFalse(resBool);
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        assertFalse(resBool);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 0);
    }

    function testRemoveAddressNotPresentFromTheWhitelist() public {
        // Arrange
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertFalse(resBool);
        vm.expectRevert(Rulelist_AddressNotPresent.selector);

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        emit RemoveAddressFromTheList(ADDRESS1);
        ruleWhitelist.removeAddressFromTheList(ADDRESS1);

        // Assert
        // no change
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertFalse(resBool);
    }

    function testRemoveAddressesNotPresentFromTheWhitelist() public {
        // Arrange
        _addAddressesToTheList();
        // Arrange
        address[] memory whitelistRemove = new address[](3);
        whitelistRemove[0] = ADDRESS1;
        whitelistRemove[1] = ADDRESS2;
        // Target Address - Not Present in the whitelist
        whitelistRemove[2] = ADDRESS3;

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        emit RemoveAddressesFromTheList(whitelistRemove);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "removeAddressesFromTheList(address[])",
                whitelistRemove
            )
        );
        // Assert
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertFalse(resBool);
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        assertFalse(resBool);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 0);
    }
}
