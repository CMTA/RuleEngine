// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";
import "./RuleCTDeployment.sol";

/**
 * @title General functions of the RuleWhitelist
 */
contract RuleConditionalTransferDeploymentTest is Test, HelperContract {
    RuleCTDeployment ruleCTDeployment;

    // Arrange
    function setUp() public {}

    function testSetMaxLimitIfZeroForAutomaticApprovalAndAutomaticTransfer()
        public
    {
        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: 7 days,
            timeLimitToTransfer: 30 days
        });

        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: false,
            timeLimitBeforeAutomaticApproval: 0
        });

        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval: false,
            authorizedBurnWithoutApproval: false
        });
        AUTOMATIC_TRANSFER memory automaticTransfer_ = AUTOMATIC_TRANSFER({
            isActivate: false,
            cmtat: IERC20(address(0))
        });

        OPTION memory options = OPTION({
            issuance: issuanceOption_,
            timeLimit: timeLimit_,
            automaticApproval: automaticApproval_,
            automaticTransfer: automaticTransfer_
        });
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
        // Test 1
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        vm.expectRevert(
            abi.encodeWithSelector(
                RuleConditionalTransfer_AdminWithAddressZeroNotAllowed.selector
            )
        );
        ruleConditionalTransfer = new RuleConditionalTransfer(
            ZERO_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );

        // Test 2
        ruleCTDeployment = new RuleCTDeployment();
        ruleConditionalTransfer = ruleCTDeployment.ruleConditionalTransfer();
        ISSUANCE memory issuance;
        TIME_LIMIT memory timeLimit;
        AUTOMATIC_APPROVAL memory automaticApproval;
        AUTOMATIC_TRANSFER memory automaticTransfer;
        (
            issuance,
            timeLimit,
            automaticApproval,
            automaticTransfer
        ) = ruleConditionalTransfer.options();
        assertEq(timeLimit.timeLimitToApprove, 7 days);
        assertEq(timeLimit.timeLimitToTransfer, 30 days);
    }
}
