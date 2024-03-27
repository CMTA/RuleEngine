// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
* @title Tests on the Access Control
*/
contract RuleVinkulierungAccessControl is Test, HelperContract {
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
    bytes32 defaultKey = keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));


    // Arrange
    function setUp() public {
        TIME_LIMIT memory timeLimit_ =TIME_LIMIT({
            timeLimitToApprove: 7 days,
            timeLimitToTransfer: 30 days
        });
        
       AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: false,
            timeLimitBeforeAutomaticApproval: 0
        });

        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval:false,
            authorizedBurnWithoutApproval:false
        });
        AUTOMATIC_TRANSFER memory automaticTransfer_ = AUTOMATIC_TRANSFER({
            isActivate:false,
            cmtat: IERC20(address(0))
        });
        
        OPTION memory options = OPTION({
            issuance:issuanceOption_,
            timeLimit: timeLimit_,
            automaticApproval: automaticApproval_,
            automaticTransfer:automaticTransfer_
        });
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleVinkulierung = new RuleVinkulierung(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,                   
            options
        );
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleVinkulierung.grantRole(RULE_VINKULIERUNG_OPERATOR_ROLE, VINKULIERUNG_OPERATOR_ADDRESS);
    }

    function _createTransferRequest() internal{
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleVinkulierung.createTransferRequest(ADDRESS2, defaultValue);
    }


    function testCannotAttackerApproveARequestCreatedByTokenHolder() public {
        _createTransferRequest();
        
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULE_VINKULIERUNG_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        ruleVinkulierung.approveTransferRequest(ADDRESS1, ADDRESS2, defaultValue, true);
    }

    function testCannotAttackerApproveWithIdARequestCreatedByTokenHolder() public {
        _createTransferRequest();
        
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULE_VINKULIERUNG_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        ruleVinkulierung.approveTransferRequestWithId(0, true);
    }

    function testCannotAttackerResetARequest() public {
         _createTransferRequest();
        
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULE_VINKULIERUNG_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        ruleVinkulierung.resetRequestStatus(0);
    }

    function testCannotAttackerCreateTransferRequestWithApproval() public {
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULE_VINKULIERUNG_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        ruleVinkulierung.createTransferRequestWithApproval(ADDRESS1, ADDRESS2, defaultValue);
    }

    /******** OPTIONS CONFIGURATION *********/
    function testCannotAttackerSetTimeLimit() public {
        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: 7 days,
            timeLimitToTransfer: 200 days
        });
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULE_VINKULIERUNG_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        ruleVinkulierung.setTimeLimit(timeLimit_);
    }

    function testCannotAttackerSetAutomaticTransfer() public {
        AUTOMATIC_TRANSFER memory automaticTransfer_ = AUTOMATIC_TRANSFER({
            isActivate:false,
            cmtat: IERC20(address(0))
        });
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULE_VINKULIERUNG_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        ruleVinkulierung.setAutomaticTransfer(automaticTransfer_);
    }

    function testCannotAttackerSetIssuanceOptions() public {
        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval:false,
            authorizedBurnWithoutApproval:false
        });
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULE_VINKULIERUNG_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        ruleVinkulierung.setIssuanceOptions(issuanceOption_);
    }

    function testCannotAttackerSetAuomaticApproval() public {
       AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: false,
            timeLimitBeforeAutomaticApproval: 0
        });
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, RULE_VINKULIERUNG_OPERATOR_ROLE));  
        vm.prank(ATTACKER);
        ruleVinkulierung.setAutomaticApproval(automaticApproval_);
    }
}
