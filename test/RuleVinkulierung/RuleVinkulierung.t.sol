// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
* @title General functions of the RuleWhitelist
*/
contract RuleVinkulierungTest is Test, HelperContract {
    RuleEngine ruleEngineMock;
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleVinkulierung = new RuleVinkulierung(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true
        );
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleVinkulierung.grantRole(RULE_VINKULIERUNG_OPERATOR_ROLE, VINKULIERUNG_OPERATOR_ADDRESS);
    }

    function testCanCreateTransferRequest() public {
        vm.prank(ADDRESS1);
        uint256 value = 10;
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(key, ADDRESS1, ADDRESS2, value, 0);
        ruleVinkulierung.createTransferRequest(ADDRESS2, value);
    }

    function testCanCreateTransferRequestWithApproval() public {
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        uint256 value = 10;
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(key, ADDRESS1, ADDRESS2, value, 0);
        ruleVinkulierung.createTransferRequestWithApproval(ADDRESS1, ADDRESS2, value);
    }

    function testCanApproveRequestCreatedByHolder() public {
        // Arrange
        vm.prank(ADDRESS1);
        uint256 value = 10;
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        ruleVinkulierung.createTransferRequest(ADDRESS2, value);
        
        // Act
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, value, 0);
        ruleVinkulierung.approveTransferRequest(ADDRESS1, ADDRESS2, value, true);
    }

    function testCanCreateAndApproveRequestCreatedByHolderAgain() public {
        // Arrange
        // First request
        vm.prank(ADDRESS1);
        uint256 value = 10;
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        ruleVinkulierung.createTransferRequest(ADDRESS2, value);
        
        // First approval
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, value, 0);
        ruleVinkulierung.approveTransferRequest(ADDRESS1, ADDRESS2, value, true);

        // Second request
        vm.prank(ADDRESS1);
        ruleVinkulierung.createTransferRequest(ADDRESS2, value);

        // Second approval
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, value, 0);
        ruleVinkulierung.approveTransferRequest(ADDRESS1, ADDRESS2, value, true);
    }

    function testCanApproveRequestCreatedByHolderWithId() public {
        // Arrange
        vm.prank(ADDRESS1);
        uint256 value = 10;
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        ruleVinkulierung.createTransferRequest(ADDRESS2, value);
        
        // Act
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2, value, 0);
        ruleVinkulierung.approveTransferRequestWithId( 0, true);
    }


    function testCanDeniedRequestCreatedByHolderWithId() public {
        // Arrange
        vm.prank(ADDRESS1);
        uint256 value = 10;
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        ruleVinkulierung.createTransferRequest(ADDRESS2, value);
        
        // Act
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(key, ADDRESS1, ADDRESS2, value, 0);
        ruleVinkulierung.approveTransferRequestWithId( 0, false);
    }


    function testCanDeniedRequestCreatedByHolder() public {
        // Arrange
        vm.prank(ADDRESS1);
        uint256 value = 10;
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2, value));
        ruleVinkulierung.createTransferRequest(ADDRESS2, value);
        
        // Act
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferDenied(key, ADDRESS1, ADDRESS2, value, 0);
        ruleVinkulierung.approveTransferRequest(ADDRESS1, ADDRESS2, value, false);
    }

    function testCannotApproveRequestIfTimeExceeded() public {
        // Arrange
        vm.prank(ADDRESS1);
        uint256 value = 10;
        // Act
        ruleVinkulierung.createTransferRequest(ADDRESS2, value);
        
        // Timeout
        // 7 days *24*60*60 = 604800 seconds
        vm.warp(block.timestamp + 604801);
        // Act
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        //vm.expectEmit(true, true, true, true);
        //emit transferDenied(key, ADDRESS1, ADDRESS2, value, 0);
        vm.expectRevert(RuleVinkulierung_timeExceeded.selector);
        ruleVinkulierung.approveTransferRequest(ADDRESS1, ADDRESS2, value, true);
    }
}
