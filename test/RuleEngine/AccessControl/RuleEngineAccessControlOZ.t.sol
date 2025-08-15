// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "../../HelperContract.sol";

/**
 * @title Tests on the provided functions by OpenZeppelin
 */
contract RuleEngineAccessControlTest is Test, HelperContract, AccessControl {
    // Arrange
    function setUp() public {
        ruleWhitelist = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
        resUint256 = ruleEngineMock.rulesCount();

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCanGrantRoleAsAdmin() public {
        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, false, true);
        emit RoleGranted(
            RULES_MANAGEMENT_ROLE,
            ADDRESS1,
            RULE_ENGINE_OPERATOR_ADDRESS
        );
        ruleEngineMock.grantRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
        // Assert
        bool res1 = ruleEngineMock.hasRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
        assertEq(res1, true);
    }

    function testRevokeRoleAsAdmin() public {
        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.grantRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
        // Arrange - Assert
        bool res1 = ruleEngineMock.hasRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
        assertEq(res1, true);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, false, true);
        emit RoleRevoked(
            RULES_MANAGEMENT_ROLE,
            ADDRESS1,
            RULE_ENGINE_OPERATOR_ADDRESS
        );
        ruleEngineMock.revokeRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
        // Assert
        bool res2 = ruleEngineMock.hasRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
        assertFalse(res2);
    }

    function testCannotGrantFromNonAdmin() public {
        // Arrange - Assert
        bool res1 = ruleEngineMock.hasRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
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
        ruleEngineMock.grantRole(RULES_MANAGEMENT_ROLE, ADDRESS2);
        // Assert
        bool res2 = ruleEngineMock.hasRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
        assertFalse(res2);
    }

    function testCannotRevokeFromNonAdmin() public {
        // Arrange - Assert
        bool res1 = ruleEngineMock.hasRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
        assertFalse(res1);

        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.grantRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
        // Arrange - Assert
        bool res2 = ruleEngineMock.hasRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
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
        ruleEngineMock.revokeRole(RULES_MANAGEMENT_ROLE, ADDRESS1);

        // Assert
        bool res3 = ruleEngineMock.hasRole(RULES_MANAGEMENT_ROLE, ADDRESS1);
        assertEq(res3, true);
    }
}
