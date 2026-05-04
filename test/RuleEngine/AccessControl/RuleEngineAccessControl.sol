// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
// forge-lint: disable-next-line(unaliased-plain-import)
import "../../HelperContract.sol";


/**
 * @title Tests on the Access Control
 */
contract RuleEngineTest is Test, HelperContract {
    // Custom error openZeppelin
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

    // Arrange
    function setUp() public {
        ruleWhitelist = new RuleWhitelist(WHITELIST_OPERATOR_ADDRESS, ZERO_ADDRESS);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(RULE_ENGINE_OPERATOR_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS);
        resUint256 = ruleEngineMock.rulesCount();

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerSetRules() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(WHITELIST_OPERATOR_ADDRESS, ZERO_ADDRESS);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(WHITELIST_OPERATOR_ADDRESS, ZERO_ADDRESS);
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = ruleWhitelist1;
        ruleWhitelistTab[1] = ruleWhitelist2;

        // Act
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULES_MANAGEMENT_ROLE)
        );
        (bool success,) = address(ruleEngineMock).call(abi.encodeCall(ruleEngineMock.setRules, ruleWhitelistTab));

        // Assert
        assertEq(success, true);
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannnotAttackerClearRules() public {
        // Act
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULES_MANAGEMENT_ROLE)
        );
        ruleEngineMock.clearRules();

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerAddRule() public {
        // Act
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULES_MANAGEMENT_ROLE)
        );
        ruleEngineMock.addRule(ruleWhitelist);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerRemoveRule() public {
        // Act
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULES_MANAGEMENT_ROLE)
        );
        ruleEngineMock.removeRule(ruleWhitelist);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerOperateOnTransfer() public {
        // Act
        vm.prank(ATTACKER);
        vm.expectRevert(ERC3643ComplianceModule.RuleEngine_ERC3643Compliance_UnauthorizedCaller.selector);
        ruleEngineMock.transferred(address(0), ADDRESS1, ADDRESS2, 10);
    }

    function testCannotAttackerSetMaxRules() public {
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, bytes32(0))
        );
        ruleEngineMock.setMaxRules(12);
    }

    function testRulesManagerCannotSetMaxRulesWithoutAdminRole() public {
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.grantRole(RULES_MANAGEMENT_ROLE, WHITELIST_OPERATOR_ADDRESS);

        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        vm.expectRevert(
            abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, WHITELIST_OPERATOR_ADDRESS, bytes32(0))
        );
        ruleEngineMock.setMaxRules(12);
    }

    function testCannotGrantRulesManagementRoleToRuleAccount() public {
        vm.expectRevert(RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.grantRole(RULES_MANAGEMENT_ROLE, address(ruleWhitelist));
    }

    function testCannotGrantDefaultAdminRoleToRuleAccount() public {
        vm.expectRevert(RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.grantRole(bytes32(0), address(ruleWhitelist));
    }

    function testCannotGrantArbitraryRoleToRuleAccount() public {
        assertTrue(ruleEngineMock.containsRule(ruleWhitelist));
        vm.expectRevert(RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges.selector);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.grantRole(keccak256("ARBITRARY_ROLE"), address(ruleWhitelist));
    }
}
