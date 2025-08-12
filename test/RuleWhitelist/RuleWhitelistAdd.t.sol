// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";

/**
 * @title Tests the functions to add addresses to the whitelist
 */
contract RuleWhitelistAddTest is Test, HelperContract {
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
        address[] memory addressesListInput = new address[](2);
        addressesListInput[0] = ADDRESS1;
        addressesListInput[1] = ADDRESS2;
        bool[] memory resBools = ruleWhitelist.addressIsListedBatch(
            addressesListInput
        );
        assertEq(resBools[0], true);
        assertEq(resBools[1], true);
        assertEq(resBools.length, 2);
    }

    function testAddAddressToTheList() public {
        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        emit AddAddressToTheList(ADDRESS1);
        ruleWhitelist.addAddressToTheList(ADDRESS1);

        // Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        address[] memory addressesListInput = new address[](1);
        addressesListInput[0] = ADDRESS1;
        bool[] memory resBools = ruleWhitelist.addressIsListedBatch(
            addressesListInput
        );
        assertEq(resBools[0], true);
        assertEq(resBools.length, 1);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 1);
    }

    function testAddAddressesToTheList() public {
        // Arrange
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 0);
        // Act
        _addAddressesToTheList();
        // Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS3);
        assertFalse(resBool);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 2);
    }

    function testCanAddAddressZeroToTheWhitelist() public {
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsListed(address(0x0));
        assertEq(resBool, false);

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        emit AddAddressToTheList(address(0x0));
        ruleWhitelist.addAddressToTheList(address(0x0));

        // Assert
        resBool = ruleWhitelist.addressIsListed(address(0x0));
        assertEq(resBool, true);
    }

    function testCanAddAddressesZeroToTheWhitelist() public {
        // Arrange
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 0);
        address[] memory whitelist = new address[](3);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        // our target address
        whitelist[2] = address(0x0);

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        emit AddAddressesToTheList(whitelist);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheList(address[])",
                whitelist
            )
        );

        // Assert - Main
        // Seem that call returns true even if the function is reverted
        // TODO : check the return value of call
        resBool = ruleWhitelist.addressIsListed(address(0x0));
        assertEq(resBool, true);

        // Assert - Secondary
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 3);
    }

    function testAddAddressTwiceToTheWhitelist() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        /// Arrange
        vm.expectRevert(Rulelist_AddressAlreadylisted.selector);
        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);
        // no change
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 1);
    }

    function testAddAddressesTwiceToTheWhitelist() public {
        // Arrange
        // Arrange - first addition
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 0);
        _addAddressesToTheList();
        // Arrange - second addition
        address[] memory whitelistDuplicate = new address[](3);
        // Duplicate address
        whitelistDuplicate[0] = ADDRESS1;
        whitelistDuplicate[1] = ADDRESS2;
        // new address in the whitelist
        whitelistDuplicate[2] = ADDRESS3;
        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheList(address[])",
                whitelistDuplicate
            )
        );
        // Assert
        // no change
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        assertEq(resBool, true);
        // ADDRESS3 is whitelisted
        resBool = ruleWhitelist.addressIsListed(ADDRESS3);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberListedAddress();
        assertEq(resUint256, 3);
    }
}
