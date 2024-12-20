// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/CMTAT_STANDALONE.sol";
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

        // Whitelist
        ruleWhitelist = new RuleWhitelist(DEFAULT_ADMIN_ADDRESS, ZERO_ADDRESS);

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
        // Add whitelist
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleConditionalTransfer.setConditionalWhitelist(ruleWhitelist);
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
    function testCanMakeATransferWithoutApprovalIfFromAndToAreInTheWhitelist()
        public
    {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS2);
        // Arrange
        // Act
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    function testCannotMakeATransferWithoutApprovalIfOnlyFromIsInTheWhitelist()
        public
    {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);
        // Arrange
        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                21
            )
        );
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    function testCannotMakeATransferWithoutApprovalIfOnlyToIsInTheWhitelist()
        public
    {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS2);
        // Arrange
        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                21
            )
        );
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    function testCanSetANewWhitelist() public {
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        vm.expectEmit(true, false, false, false);
        emit WhitelistConditionalTransfer(ruleWhitelist2);
        ruleConditionalTransfer.setConditionalWhitelist(ruleWhitelist2);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist2.addAddressToTheList(ADDRESS1);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist2.addAddressToTheList(ADDRESS2);

        // Arrange
        // Act
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    function testCanUnSetWhitelist() public {
        // Arrange
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        vm.expectEmit(true, false, false, false);
        emit WhitelistConditionalTransfer(ruleWhitelist2);
        ruleConditionalTransfer.setConditionalWhitelist(ruleWhitelist2);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist2.addAddressToTheList(ADDRESS1);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist2.addAddressToTheList(ADDRESS2);

        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleConditionalTransfer.setConditionalWhitelist(
            RuleWhitelist(ZERO_ADDRESS)
        );

        // Assert
        vm.prank(ADDRESS1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                21
            )
        );
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    function testCanDetectTransferRestrictionOKWithWhitelist() public {
        // Arrange
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS2);

        // Act
        uint8 resUint8 = ruleConditionalTransfer.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );

        // Assert
        assertEq(resUint8, 0);
    }

    function testCanDetectTransferRestrictionWithOnlyFromInTheWhitelist()
        public
    {
        // Arrange
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);

        // Act
        uint8 resUint8 = ruleConditionalTransfer.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );

        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);
    }

    function testCanDetectTransferRestrictionWithOnlyToInTheWhitelist() public {
        // Arrange
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS2);

        // Act
        uint8 resUint8 = ruleConditionalTransfer.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );

        // Assert
        assertEq(resUint8, CODE_TRANSFER_REQUEST_NOT_APPROVED);
    }

    /***** Test from CMTAT integration */

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
        CMTATIntegrationShare.testShareCannotMakeATransferIfDelayExceeded(2592001);
    }

    function testCannotMakeATransferIfDelayJustInTime() public {
        // 30 days
       CMTATIntegrationShare.testShareCannotMakeATransferIfDelayJustInTime(2592000);
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
