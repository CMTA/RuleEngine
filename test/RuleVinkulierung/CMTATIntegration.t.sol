// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/CMTAT_STANDALONE.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
* @title Integration test with the CMTAT
*/
contract CMTATIntegrationVinkulierung is Test, HelperContract {
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

    // Arrange
    function setUp() public {
 
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
        ruleEngineMock = new RuleEngine(DEFAULT_ADMIN_ADDRESS, ZERO_ADDRESS);

        // RuleVinkulierung
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleVinkulierung = new RuleVinkulierung(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS,
            ruleEngineMock,
            true,
            true,                       
            DEFAULT_TIME_LIMIT_TO_APPROVE,
            DEFAULT_TIME_LIMIT_TO_TRANSFER
        );
         // specific arrange
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleVinkulierung.grantRole(RULE_VINKULIERUNG_OPERATOR_ROLE, VINKULIERUNG_OPERATOR_ADDRESS);

        // RuleEngine
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleEngineMock.addRuleOperation(ruleVinkulierung);

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

    /******* Transfer *******/
    function testCannotTransferWithoutApproval() public {
        // Arrange
        vm.prank(ADDRESS1);
        vm.expectRevert(
        abi.encodeWithSelector(Errors.CMTAT_InvalidTransfer.selector, ADDRESS1, ADDRESS2, 21));   
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    function testCanMakeATransferIfApproved() public {
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

        // Act
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, value);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT - value);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
        assertEq(resUint256, ADDRESS2_BALANCE_INIT + value);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
        assertEq(resUint256, 33);
    }

    function testCannotMakeATransferIfDelayExceeded() public {
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

        // +30 days and one second
        vm.warp(block.timestamp + 2592001);
        // Act
         vm.expectRevert(
        abi.encodeWithSelector(Errors.CMTAT_InvalidTransfer.selector, ADDRESS1, ADDRESS2, value));   
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, value);
    }

    function testCannotMakeATransferIfDelayJustInTime() public {
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
        // 30 days
        vm.warp(block.timestamp + 2592000);
        // Act
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, value);
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
        uint256 value = 3;
        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.burn(ADDRESS1, value, "test");

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT - value);
    }
}
