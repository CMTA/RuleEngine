// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
import "src/RuleEngine.sol";
import "OZ/token/ERC20/IERC20.sol";
/**
 * @title Tests on the Access Control
 */
contract RuleCTDeployment is Test, HelperContract {
    // Arrange
    constructor() {
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
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleConditionalTransfer = new RuleConditionalTransfer(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleConditionalTransfer.grantRole(
            RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE,
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS
        );
    }
}
