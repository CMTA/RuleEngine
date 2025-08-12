// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
import "../../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

/**
 * @title Tests on the provided functions by OpenZeppelin
 */
contract RuleWhitelistAccessControlOZ is Test, HelperContract, AccessControl {
    // Arrange
    function setUp() public {
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
    }

    function testCanGrantRoleAsAdmin() public {
        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, false, true);
        emit RoleGranted(
            ADDRESS_LIST_ADD_ROLE,
            ADDRESS1,
            WHITELIST_OPERATOR_ADDRESS
        );
        ruleWhitelist.grantRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        // Assert
        bool res1 = ruleWhitelist.hasRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        assertEq(res1, true);
    }

    function testRevokeRoleAsAdmin() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.grantRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        // Arrange - Assert
        bool res1 = ruleWhitelist.hasRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        assertEq(res1, true);

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, false, true);
        emit RoleRevoked(
            ADDRESS_LIST_ADD_ROLE,
            ADDRESS1,
            WHITELIST_OPERATOR_ADDRESS
        );
        ruleWhitelist.revokeRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        // Assert
        bool res2 = ruleWhitelist.hasRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        assertFalse(res2);
    }

    function testCannotGrantFromNonAdmin() public {
        // Arrange - Assert
        bool res1 = ruleWhitelist.hasRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        assertFalse(res1);

        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ADDRESS2,
                DEFAULT_ADMIN_ROLE
            )
        );
        vm.prank(ADDRESS2);
        ruleWhitelist.grantRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        // Assert
        bool res2 = ruleWhitelist.hasRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        assertFalse(res2);
    }

    function testCannotRevokeFromNonAdmin() public {
        // Arrange - Assert
        bool res1 = ruleWhitelist.hasRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        assertFalse(res1);

        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.grantRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        // Arrange - Assert
        bool res2 = ruleWhitelist.hasRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        assertEq(res2, true);

        // Act
        vm.prank(ADDRESS2);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ADDRESS2,
                DEFAULT_ADMIN_ROLE
            )
        );
        ruleWhitelist.revokeRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);

        // Assert
        bool res3 = ruleWhitelist.hasRole(ADDRESS_LIST_ADD_ROLE, ADDRESS1);
        assertEq(res3, true);
    }
}
