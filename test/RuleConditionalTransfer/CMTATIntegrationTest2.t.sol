// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/deployment/CMTATStandalone.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";
import "./utils/CMTATIntegrationShare.sol";

/**
 * @title Integration test with the CMTAT
 * @dev set blocktimestamp to a value different from 0
 */
contract CMTATIntegrationConditionalTransferWithTimeStampSet is Test, HelperContract, CMTATIntegrationShare {
    uint256 TIME_LIMIT_AUTO_APPROVAL = 259200; //3 days;
    uint256 TIME_LIMIT_TO_APPROVE = 432000; //5 days;
    uint256 TIME_LIMIT_TO_TRANSFER = 259200; //3 days
    // Arrange
    function setUp() public {
        // global arrange
        cmtatDeployment = new CMTATDeployment();
        CMTAT_CONTRACT = cmtatDeployment.cmtat();

        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: TIME_LIMIT_TO_APPROVE, // 5days
            timeLimitToTransfer: TIME_LIMIT_TO_TRANSFER
        });
        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval: true,
            authorizedBurnWithoutApproval: true
        });

        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: true,
            timeLimitBeforeAutomaticApproval: TIME_LIMIT_AUTO_APPROVAL
        });

        AUTOMATIC_TRANSFER memory automaticTransfer_ = AUTOMATIC_TRANSFER({
            isActivate: true,
            cmtat: IERC20(address(CMTAT_CONTRACT))
        });
        OPTION memory options = OPTION({
            issuance: issuanceOption_,
            timeLimit: timeLimit_,
            automaticApproval: automaticApproval_,
            automaticTransfer: automaticTransfer_
        });



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

        vm.warp(1734531338);
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
        // Arrange - Assert
        // ConditionalTransfer
        resUint8 = ruleConditionalTransfer.detectTransferRestriction(
            address(0xD65Fb7036518F4B34482E0a1905Dc6e3Fc379FF0),
            address(0xD65Fb7036518F4B34482E0a1905Dc6e3Fc379FF0),
            defaultValue
        );
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);
        resUint8 = ruleConditionalTransfer.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            5
        );
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);
        // Assert
        // Arrange
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
        CMTATIntegrationShare.testShareCannotMakeATransferIfDelayExceeded(TIME_LIMIT_TO_TRANSFER + 1 seconds);
    }

    function testCanMakeATransferIfDelayJustInTime() public {
       CMTATIntegrationShare.testShareCannotMakeATransferIfDelayJustInTime(TIME_LIMIT_TO_TRANSFER);
    }

    function testCanSetTimeLimitWithTransferExceeded() public {
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
