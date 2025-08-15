// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";

/**
 * @title Tests on the Access Control
 */
contract RuleWhitelistAccessControl is Test, HelperContract {
    // Custom error openZeppelin
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    // Arrange
    function setUp() public {
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
    }

    function testCannotAttackerAddAddressToTheList() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                ADDRESS_LIST_ADD_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleWhitelist.addAddressToTheList(ADDRESS1);

        // Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, false);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 0);
    }

    function testCannotAttackerAddAddressesToTheList() public {
        // Arrange
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 0);
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;

        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                ADDRESS_LIST_ADD_ROLE
            )
        );
        vm.prank(ATTACKER);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheList(address[])",
                whitelist
            )
        );

        // Assert
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, false);
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        assertEq(resBool, false);
        resBool = ruleWhitelist.addressIsListed(ADDRESS3);
        assertFalse(resBool);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 0);
    }

    function testCannotAttackerRemoveAddressFromTheList() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);

        // Arrange - Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);

        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                ADDRESS_LIST_REMOVE_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleWhitelist.removeAddressFromTheList(ADDRESS1);

        // Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerRemoveAddressesFromTheList() public {
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
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                ADDRESS_LIST_REMOVE_ROLE
            )
        );
        vm.prank(ATTACKER);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "removeAddressesFromTheList(address[])",
                whitelist
            )
        );
        // Assert
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 2);
    }
}
