// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
 * @title Tests on the Access Control
 */
contract RuleConditionalTransferAccessControl is Test, HelperContract {
    RuleEngine ruleEngineMock;
    // Custom error openZeppelin
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    // Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;
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

    function _createTransferRequest() internal {
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleConditionalTransfer.createTransferRequest(ADDRESS2, defaultValue);
    }

    function testCannotAttackerApproveARequestCreatedByTokenHolder() public {
        _createTransferRequest();

        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.approveTransferRequest(
            transferRequestInput,
            0,
            true
        );
    }

    function testCannotAttackerApproveWithIdARequestCreatedByTokenHolder()
        public
    {
        _createTransferRequest();

        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.approveTransferRequestWithId(0, true);
    }

    function testCannotAttackerResetARequest() public {
        _createTransferRequest();

        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.resetRequestStatus(0);
    }

    function testCannotAttackerCreateTransferRequestWithApproval() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.createTransferRequestWithApproval(
            transferRequestInput
        );
    }

    /*** Batch */

    function testCannotAttackerApproveBatchWithIdARequestCreatedByTokenHolder()
        public
    {
        _createTransferRequest();
        uint256[] memory ids = new uint256[](1);
        ids[0] = 0;
        bool[] memory isApproveds = new bool[](1);
        isApproveds[0] = true;
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.approveTransferRequestBatchWithId(
            ids,
            isApproveds
        );
    }

    function testCannotAttackerApproveBatchRequestCreatedByTokenHolder()
        public
    {
        TransferRequestKeyElement[]
            memory keyElements = new TransferRequestKeyElement[](0);
        uint256[] memory partialValues = new uint256[](0);
        bool[] memory boolIsApproved = new bool[](0);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.approveTransferRequestBatch(
            keyElements,
            partialValues,
            boolIsApproved
        );
    }

    function testCannotAttackerResetBatch() public {
        uint256[] memory ids = new uint256[](0);
        bool[] memory boolIsApproved = new bool[](0);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.approveTransferRequestBatchWithId(
            ids,
            boolIsApproved
        );
    }

    function testCannotAttackerCreateTransferRequestWithApprovalBatch() public {
        TransferRequestKeyElement[]
            memory keyElements = new TransferRequestKeyElement[](0);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.createTransferRequestWithApprovalBatch(
            keyElements
        );
    }

    /******** OPTIONS CONFIGURATION *********/
    function testCannotAttackerSetTimeLimit() public {
        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: 7 days,
            timeLimitToTransfer: 200 days
        });
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.setTimeLimit(timeLimit_);
    }

    function testCannotAttackerSetAutomaticTransfer() public {
        AUTOMATIC_TRANSFER memory automaticTransfer_ = AUTOMATIC_TRANSFER({
            isActivate: false,
            cmtat: IERC20(address(0))
        });
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.setAutomaticTransfer(automaticTransfer_);
    }

    function testCannotAttackerSetIssuanceOptions() public {
        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval: false,
            authorizedBurnWithoutApproval: false
        });
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.setIssuanceOptions(issuanceOption_);
    }

    function testCannotAttackerSetAuomaticApproval() public {
        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: false,
            timeLimitBeforeAutomaticApproval: 0
        });
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                RULE_CONDITIONAL_TRANSFER_OPERATOR_ROLE
            )
        );
        vm.prank(ATTACKER);
        ruleConditionalTransfer.setAutomaticApproval(automaticApproval_);
    }
}
