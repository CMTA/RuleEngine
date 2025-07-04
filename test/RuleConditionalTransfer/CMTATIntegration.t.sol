// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/deployment/CMTATStandalone.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";
import "./utils/CMTATIntegrationShare.sol";

/**
 * @title Integration test with the CMTAT
 */
contract CMTATIntegrationConditionalTransfer is Test, HelperContract, CMTATIntegrationShare {
    // Arrange
    function setUp() public {
        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: 7 days,
            timeLimitToTransfer: 30 days
        });
        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval: true,
            authorizedBurnWithoutApproval: true
        });

        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: false,
            timeLimitBeforeAutomaticApproval: 0
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

        // global arrange
        cmtatDeployment = new CMTATDeployment();
        CMTAT_CONTRACT = cmtatDeployment.cmtat();

        // RuleEngine
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleEngineMock = new RuleEngine(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS,
            address(CMTAT_CONTRACT)
        );

        // RuleConditionalTransfer
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleConditionalTransfer = new RuleConditionalTransfer(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            options
        );
        // specific arrange
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleConditionalTransfer.grantRole(
            RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE,
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS
        );

        // RuleEngine
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleConditionalTransfer);

        // Mint
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS1, ADDRESS1_BALANCE_INIT);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS2, ADDRESS2_BALANCE_INIT);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS3, ADDRESS3_BALANCE_INIT);
        vm.prank(DEFAULT_ADMIN_ADDRESS);

        // We set the Rule Engine
        CMTAT_CONTRACT.setRuleEngine(ruleEngineMock);
    }

    function _createTransferRequest() internal {
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);
    }

    /******* Transfer *******/
    function testCannotTransferWithoutApproval() public {
        CMTATIntegrationShare.testShareCannotTransferWithoutApproval();
    }

    function testCanMakeATransferIfApproved() public {
        CMTATIntegrationShare.testShareCanMakeATransferIfApproved();
    }

    function testCanMakeAPartialTransferIfPartiallyApproved() public {
        CMTATIntegrationShare.testShareCanMakeAPartialTransferIfPartiallyApproved();
    }

    function testCannotMakeAWholeTransferIfPartiallyApproved() public {
        CMTATIntegrationShare.testShareCannotMakeAWholeTransferIfPartiallyApproved();
    }
    function testCannotMakeATransferIfDelayExceeded() public {
        // // +30 days and one second
        CMTATIntegrationShare.testShareCannotMakeATransferIfDelayExceeded(2592001);
    }

    function testCannotMakeATransferIfDelayJustInTime() public {
        // 30 days
       CMTATIntegrationShare.testShareCannotMakeATransferIfDelayJustInTime(2592000);
    }

    function testCanSetTimeLimitWithTransferExceeded() public {
               // Assert
        // Timeout
        // >1 days
       CMTATIntegrationShare.testShareCanSetTimeLimitWithTransferExceeded(1 days + 1 seconds);
    }

    function testCanMintWithoutApproval() public {
        CMTATIntegrationShare.testShareCanMintWithoutApproval();
    }

    function testCanBurnWithoutApproval() public {
       CMTATIntegrationShare.testShareCanBurnWithoutApproval();
    }

    function testCannotMintWithoutApproval() public {
        CMTATIntegrationShare.testShareCannotMintWithoutApproval();
    }

    function testCannotBurnWithoutApproval() public {
       CMTATIntegrationShare.testShareCannotBurnWithoutApproval();
    }

    function testAutomaticTransferIfOptionsSet() public {
        CMTATIntegrationShare.testShareAutomaticTransferIfOptionsSet();
    }

    function testCanTransferIfAutomaticApprovalSetAndTimeExceedsJustInTime()
        public
    {
        CMTATIntegrationShare.testShareCanTransferIfAutomaticApprovalSetAndTimeExceedsJustInTime();
    }

    function testCanTransferIfAutomaticApprovalSetAndTimeExceeds() public {
       CMTATIntegrationShare.testShareCanTransferIfAutomaticApprovalSetAndTimeExceeds();
    }

    function testCannotTransferIfAutomaticApprovalSetAndTimeNotExceeds()
        public
    {
        CMTATIntegrationShare.testShareCannotTransferIfAutomaticApprovalSetAndTimeNotExceeds();
    }
}
