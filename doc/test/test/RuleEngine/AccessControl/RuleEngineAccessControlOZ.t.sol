// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "../../HelperContract.sol";
import "src/RuleEngine.sol";

/**
@title Tests on the provided functions by OpenZeppelin
*/
contract RuleEngineAccessControlTest is Test, HelperContract, AccessControl {
    RuleEngine ruleEngineMock;
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
        ruleWhitelist = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
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
            RULE_ENGINE_ROLE,
            ADDRESS1,
            RULE_ENGINE_OPERATOR_ADDRESS
        );
        ruleEngineMock.grantRole(RULE_ENGINE_ROLE, ADDRESS1);
        // Assert
        bool res1 = ruleEngineMock.hasRole(RULE_ENGINE_ROLE, ADDRESS1);
        assertEq(res1, true);
    }

    function testRevokeRoleAsAdmin() public {
        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.grantRole(RULE_ENGINE_ROLE, ADDRESS1);
        // Arrange - Assert
        bool res1 = ruleEngineMock.hasRole(RULE_ENGINE_ROLE, ADDRESS1);
        assertEq(res1, true);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, false, true);
        emit RoleRevoked(
            RULE_ENGINE_ROLE,
            ADDRESS1,
            RULE_ENGINE_OPERATOR_ADDRESS
        );
        ruleEngineMock.revokeRole(RULE_ENGINE_ROLE, ADDRESS1);
        // Assert
        bool res2 = ruleEngineMock.hasRole(RULE_ENGINE_ROLE, ADDRESS1);
        assertFalse(res2);
    }

    function testCannotGrantFromNonAdmin() public {
        // Arrange - Assert
        bool res1 = ruleEngineMock.hasRole(RULE_ENGINE_ROLE, ADDRESS1);
        assertFalse(res1);

        // Act
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ADDRESS2, DEFAULT_ADMIN_ROLE));  
        vm.prank(ADDRESS2);
        ruleEngineMock.grantRole(RULE_ENGINE_ROLE, ADDRESS2);
        // Assert
        bool res2 = ruleEngineMock.hasRole(RULE_ENGINE_ROLE, ADDRESS1);
        assertFalse(res2);
    }

    function testCannotRevokeFromNonAdmin() public {
        // Arrange - Assert
        bool res1 = ruleEngineMock.hasRole(RULE_ENGINE_ROLE, ADDRESS1);
        assertFalse(res1);

        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.grantRole(RULE_ENGINE_ROLE, ADDRESS1);
        // Arrange - Assert
        bool res2 = ruleEngineMock.hasRole(RULE_ENGINE_ROLE, ADDRESS1);
        assertEq(res2, true);

        // Act
        vm.prank(ADDRESS2);
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ADDRESS2, DEFAULT_ADMIN_ROLE));  
        ruleEngineMock.revokeRole(RULE_ENGINE_ROLE, ADDRESS1);

        // Assert
        bool res3 = ruleEngineMock.hasRole(RULE_ENGINE_ROLE, ADDRESS1);
        assertEq(res3, true);
    }
}
