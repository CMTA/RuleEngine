// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
import "OZ/token/ERC20/IERC20.sol";
import "src/mocks/rules/operation/RuleOperationRevert.sol";

/**
 * @title General functions of the RuleEngine
 */
contract RuleEngineOperationTestRevert is Test, HelperContract {
    // Arrange
    function setUp() public {
        // CMTAT
        cmtatDeployment = new CMTATDeployment();
        CMTAT_CONTRACT = cmtatDeployment.cmtat();

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            address(CMTAT_CONTRACT)
        );
        RuleOperationRevert ruleOperationRevert = new RuleOperationRevert();

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleOperationRevert);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);

        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.setRuleEngine(ruleEngineMock);
    }

    function testRuleEngineTransferredRevert() public {
        // Arrange
        vm.expectRevert(
            RuleOperationRevert
                .RuleConditionalTransferLight_InvalidTransfer
                .selector
        );
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }
}
