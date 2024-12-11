// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
import "src/RuleEngine.sol";

/**
 * @title Tests on the Access Control
 */
contract RuleEngineAccessControlTest is Test, HelperContract {
    // Custom error openZeppelin
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);

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
        resUint256 = ruleEngineMock.rulesCountValidation();

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRuleValidation(ruleWhitelist);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerSetRulesValidation() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        address[] memory ruleWhitelistTab = new address[](2);
        ruleWhitelistTab[0] = address(ruleWhitelist1);
        ruleWhitelistTab[1] = address(ruleWhitelist2);

        // Act
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_ENGINE_OPERATOR_ROLE
            )
        );
        (bool success, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRulesValidation, ruleWhitelistTab)
        );

        // Assert
        assertEq(success, true);
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);
    }

    function testCannnotAttackerClearRules() public {
        // Act
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_ENGINE_OPERATOR_ROLE
            )
        );
        ruleEngineMock.clearRulesValidation();

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerAddRule() public {
        // Act
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_ENGINE_OPERATOR_ROLE
            )
        );
        ruleEngineMock.addRuleValidation(ruleWhitelist);

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerRemoveRule() public {
        // Act
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_ENGINE_OPERATOR_ROLE
            )
        );
        ruleEngineMock.removeRuleValidation(ruleWhitelist, 0);

        // Assert
        resUint256 = ruleEngineMock.rulesCountValidation();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerOperateOnTransfer() public {
        // Act
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                TOKEN_CONTRACT_ROLE
            )
        );
        ruleEngineMock.operateOnTransfer(ADDRESS1, ADDRESS2, 10);
    }
}
