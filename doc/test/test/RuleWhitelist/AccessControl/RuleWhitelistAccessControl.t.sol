// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
import "src/RuleEngine.sol";

/**
@title Tests on the Access Control
*/
contract RuleWhitelistAccessControl is Test, HelperContract {
    // Custom error openZeppelin
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    // Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";
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

    function testCannotAttackerAddAddressToTheWhitelist() public {
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, WHITELIST_ROLE));  
        vm.prank(ATTACKER);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);

        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, false);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 0);
    }

    function testCannotAttackerAddAddressesToTheWhitelist() public {
        // Arrange
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 0);
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;

        // Act
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, WHITELIST_ROLE));  
        vm.prank(ATTACKER);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheWhitelist(address[])",
                whitelist
            )
        );

        // Assert
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, false);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, false);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS3);
        assertFalse(resBool);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 0);
    }

    function testCannotAttackerRemoveAddressFromTheWhitelist() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);

        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);

        // Act
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, WHITELIST_ROLE));  
        vm.prank(ATTACKER);
        ruleWhitelist.removeAddressFromTheWhitelist(ADDRESS1);

        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerRemoveAddressesFromTheWhitelist() public {
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
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, WHITELIST_ROLE));  
        vm.prank(ATTACKER);
        (resCallBool, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "removeAddressesFromTheWhitelist(address[])",
                whitelist
            )
        );
        // Assert
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 2);
    }
}
