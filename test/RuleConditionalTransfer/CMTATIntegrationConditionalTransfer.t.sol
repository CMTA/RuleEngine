// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/CMTAT_STANDALONE.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
 * @title Integration test with the CMTAT
 */
contract CMTATIntegrationConditionalTransfer is Test, HelperContract {
    uint256 ADDRESS1_BALANCE_INIT = 31;
    uint256 ADDRESS2_BALANCE_INIT = 32;
    uint256 ADDRESS3_BALANCE_INIT = 33;

    uint256 FLAG = 5;

    uint256 defaultValue = 10;
    bytes32 defaultKey =
        keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));

    TransferRequestKeyElement transferRequestInput =
        TransferRequestKeyElement({
            from: ADDRESS1,
            to: ADDRESS2,
            value: defaultValue
        });

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
        // Arrange
        vm.prank(ADDRESS1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                21
            )
        );
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    function testCanMakeATransferIfApproved() public {
        // Arrange
        vm.prank(ADDRESS1);
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );

        // Act
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT - defaultValue);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
        assertEq(resUint256, ADDRESS2_BALANCE_INIT + defaultValue);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
        assertEq(resUint256, 33);
    }

    function testCanMakeAPartialTransferIfPartiallyApproved() public {
        // Arrange
        _createTransferRequest();

        uint256 partialValue = 5;
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, partialValue));
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, partialValue, 1);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            partialValue,
            true
        );

        // Act
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(key, ADDRESS1, ADDRESS2, partialValue, 1);
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, partialValue);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT - partialValue);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
        assertEq(resUint256, ADDRESS2_BALANCE_INIT + partialValue);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
        assertEq(resUint256, 33);
    }

    function testCannotMakeAWholeTransferIfPartiallyApproved() public {
        // Arrange
        _createTransferRequest();
        uint256 partialValue = 5;
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, partialValue));
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, partialValue, 1);
        emit transferDenied(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            partialValue,
            true
        );

        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                defaultValue
            )
        );
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testCannotMakeATransferIfDelayExceeded() public {
        // Arrange
        vm.prank(ADDRESS1);
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );

        // +30 days and one second
        vm.warp(block.timestamp + 2592001);
        // Act
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                defaultValue
            )
        );
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testCannotMakeATransferIfDelayJustInTime() public {
        // Arrange
        _createTransferRequest();

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );
        // 30 days
        vm.warp(block.timestamp + 2592000);
        // Act
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testCanSetTimeLimitWithTransferExceeded() public {
        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: 1 days,
            timeLimitToTransfer: 1 days
        });
        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setTimeLimit(timeLimit_);
        // Arrange
        _createTransferRequest();
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );

        // Assert
        // Timeout
        // >1 days
        vm.warp(block.timestamp + 1 days + 1 seconds);

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                defaultValue
            )
        );
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testCanMintWithoutApproval() public {
        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS1, 11);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT + 11);
    }

    function testCanBurnWithoutApproval() public {
        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.burn(ADDRESS1, defaultValue, "test");

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT - defaultValue);
    }

    function testCannotMintWithoutApproval() public {
        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval: false,
            authorizedBurnWithoutApproval: true
        });
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setIssuanceOptions(issuanceOption_);
        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ZERO_ADDRESS,
                ADDRESS1,
                11
            )
        );
        CMTAT_CONTRACT.mint(ADDRESS1, 11);
    }

    function testCannotBurnWithoutApproval() public {
        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval: true,
            authorizedBurnWithoutApproval: false
        });
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setIssuanceOptions(issuanceOption_);
        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ZERO_ADDRESS,
                defaultValue
            )
        );
        CMTAT_CONTRACT.burn(ADDRESS1, defaultValue, "test");
    }

    function testAutomaticTransferIfOptionsSet() public {
        AUTOMATIC_TRANSFER memory automaticTransferTest = AUTOMATIC_TRANSFER({
            isActivate: true,
            cmtat: CMTAT_CONTRACT
        });
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setAutomaticTransfer(automaticTransferTest);

        // Aproval
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.approve(address(ruleConditionalTransfer), defaultValue);

        // Arrange
        _createTransferRequest();

        // Act
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );
    }

    function testCanTransferIfAutomaticApprovalSetAndTimeExceedsJustInTime()
        public
    {
        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: true,
            timeLimitBeforeAutomaticApproval: 90 days
        });

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setAutomaticApproval(automaticApproval_);

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        // Arrange
        _createTransferRequest();

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);

        vm.warp(block.timestamp + 90 days);
        // Act
        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertEq(resBool, true);
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testCanTransferIfAutomaticApprovalSetAndTimeExceeds() public {
        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: true,
            timeLimitBeforeAutomaticApproval: 90 days
        });

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setAutomaticApproval(automaticApproval_);

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);
        // Arrange
        _createTransferRequest();

        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertFalse(resBool);

        vm.warp(block.timestamp + 91 days);
        // Act
        resBool = ruleConditionalTransfer.validateTransfer(
            ADDRESS1,
            ADDRESS2,
            defaultValue
        );
        assertEq(resBool, true);
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }

    function testCannotTransferIfAutomaticApprovalSetAndTimeNotExceeds()
        public
    {
        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: true,
            timeLimitBeforeAutomaticApproval: 90 days
        });
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setAutomaticApproval(automaticApproval_);

        // Arrange
        _createTransferRequest();

        // Time not exceeds
        vm.warp(block.timestamp + 85 days);
        // Act
        vm.prank(ADDRESS1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.CMTAT_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                defaultValue
            )
        );
        CMTAT_CONTRACT.transfer(ADDRESS2, defaultValue);
    }
}
