//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";


contract RuleWhitelistAccessControl is Test, HelperContract, RuleWhitelist {
    //Defined in CMTAT.sol
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
      ruleWhitelist = new RuleWhitelist();
    }

    function testCannotAttackerAddAddressToTheWhitelist() public {
        // Act
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ATTACKER),
                " is missing role ",
                WHITELIST_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
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
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ATTACKER),
                " is missing role ",
                WHITELIST_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
        vm.prank(ATTACKER);
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addAddressesToTheWhitelist(address[])", whitelist)
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

    function testRemoveAddressFromTheWhitelist() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);
        
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        
        // Act
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ATTACKER),
                " is missing role ",
               WHITELIST_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
        vm.prank(ATTACKER);
        ruleWhitelist.removeAddressFromTheWhitelist(ADDRESS1);
        
        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 1);
    }

    function testRemoveAddressesFromTheWhitelist() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addAddressesToTheWhitelist(address[])", whitelist)
        );
        assertEq(resCallBool, true);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);

        // Act
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ATTACKER),
                " is missing role ",
                WHITELIST_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
        vm.prank(ATTACKER);
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("removeAddressesFromTheWhitelist(address[])", whitelist)
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

    function testCanGrantRoleAsAdmin() public {
        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, false, true);
        emit RoleGranted(WHITELIST_ROLE, ADDRESS1, WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.grantRole(WHITELIST_ROLE, ADDRESS1);
        // Assert
        bool res1 = ruleWhitelist.hasRole(WHITELIST_ROLE, ADDRESS1);
        assertEq(res1, true);
    }

    function testRevokeRoleAsAdmin() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.grantRole(WHITELIST_ROLE, ADDRESS1);
        // Arrange - Assert
        bool res1 = ruleWhitelist.hasRole(WHITELIST_ROLE, ADDRESS1);
        assertEq(res1, true);

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, false, true);
        emit RoleRevoked(WHITELIST_ROLE, ADDRESS1, WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.revokeRole(WHITELIST_ROLE, ADDRESS1);
        // Assert
        bool res2 = ruleWhitelist.hasRole(WHITELIST_ROLE, ADDRESS1);
        assertFalse(res2);
    }

    function testCannotGrantFromNonAdmin() public {
        // Arrange - Assert
        bool res1 = ruleWhitelist.hasRole(WHITELIST_ROLE, ADDRESS1);
        assertFalse(res1);

        // Act
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ADDRESS2),
                " is missing role ",
                DEFAULT_ADMIN_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
        vm.prank(ADDRESS2);
        ruleWhitelist.grantRole(WHITELIST_ROLE, ADDRESS1);
        // Assert
        bool res2 = ruleWhitelist.hasRole(WHITELIST_ROLE, ADDRESS1);
        assertFalse(res2);
    }

    function testCannotRevokeFromNonAdmin() public {
        // Arrange - Assert
        bool res1 = ruleWhitelist.hasRole(WHITELIST_ROLE, ADDRESS1);
        assertFalse(res1);

        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.grantRole(WHITELIST_ROLE, ADDRESS1);
        // Arrange - Assert
        bool res2 = ruleWhitelist.hasRole(WHITELIST_ROLE, ADDRESS1);
        assertEq(res2, true);

        // Act
        vm.prank(ADDRESS2);
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ADDRESS2),
                " is missing role ",
                DEFAULT_ADMIN_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
        ruleWhitelist.revokeRole(WHITELIST_ROLE, ADDRESS1);

        // Assert
        bool res3 = ruleWhitelist.hasRole(WHITELIST_ROLE, ADDRESS1);
        assertEq(res3, true);
    }
}