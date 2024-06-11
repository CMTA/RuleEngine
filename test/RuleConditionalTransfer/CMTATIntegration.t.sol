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
    // Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";

    RuleEngine ruleEngineMock;
    uint256 resUint256;
    bool resBool;

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
        uint8 decimals = 0;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT = new CMTAT_STANDALONE(
            ZERO_ADDRESS,
            DEFAULT_ADMIN_ADDRESS,
            IAuthorizationEngine(address(0)),
            "CMTA Token",
            "CMTAT",
            decimals,
            "CMTAT_ISIN",
            "https://cmta.ch",
            IRuleEngine(address(0)),
            "CMTAT_info",
            FLAG
        );

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

    function testCanTransferIfAutomaticApprovalSetAndTimeExceeds() public {
        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: true,
            timeLimitBeforeAutomaticApproval: 90 days
        });
        vm.prank(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS);
        ruleConditionalTransfer.setAutomaticApproval(automaticApproval_);

        // Arrange
        _createTransferRequest();

        vm.warp(block.timestamp + 90 days);
        // Act
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

        vm.warp(block.timestamp + 92 days);
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
