//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
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