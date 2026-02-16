// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
// forge-lint: disable-next-line(unaliased-plain-import)
import "../../HelperContract.sol";

import {RuleOperationRevert} from "src/mocks/rules/operation/RuleOperationRevert.sol";


/**
 * @title Base test for RuleEngine operation revert with CMTAT
 */
abstract contract RuleEngineOperationRevertBase is Test, HelperContract {
    function _deployCmtat() internal virtual returns (CMTATStandalone);

    // Arrange
    function setUp() public virtual {
        // CMTAT
        cmtatContract = _deployCmtat();

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(RULE_ENGINE_OPERATOR_ADDRESS, ZERO_ADDRESS, address(cmtatContract));
        RuleOperationRevert ruleOperationRevert = new RuleOperationRevert();

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleOperationRevert);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);

        vm.prank(DEFAULT_ADMIN_ADDRESS);
        cmtatContract.setRuleEngine(ruleEngineMock);
    }

    function testRuleEngineTransferredRevert() public {
        // Arrange
        vm.expectRevert(RuleOperationRevert.RuleConditionalTransferLight_InvalidTransfer.selector);
        // Act
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cmtatContract.transfer(ADDRESS2, 21);
    }
}
