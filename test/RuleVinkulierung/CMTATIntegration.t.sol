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

    uint256 defaultValue = 10;
    bytes32 defaultKey = keccak256(abi.encode(ADDRESS1, ADDRESS2, defaultValue));


    // Arrange
    function setUp() public {
        TIME_LIMIT memory timeLimit_ = TIME_LIMIT({
            timeLimitToApprove: 7 days,
            timeLimitToTransfer: 30 days
        });
        ISSUANCE memory issuanceOption_ = ISSUANCE({
            authorizedMintWithoutApproval:true,
            authorizedBurnWithoutApproval:true
        });

        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: false,
            timeLimitBeforeAutomaticApproval: 0
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
            options
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

    function _createTransferRequest() internal{
        vm.prank(ADDRESS1);
        // Act
        vm.expectEmit(true, true, true, true);
        emit transferWaiting(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        ruleVinkulierung.createTransferRequest(ADDRESS2, defaultValue);
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
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2,defaultValue));
        ruleVinkulierung.createTransferRequest(ADDRESS2,defaultValue);
        
        // Act
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2,defaultValue, 0);
        ruleVinkulierung.approveTransferRequest(ADDRESS1, ADDRESS2,defaultValue, true);

        // Act
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2, defaultValue, 0);
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2,defaultValue);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT -defaultValue);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
        assertEq(resUint256, ADDRESS2_BALANCE_INIT +defaultValue);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
        assertEq(resUint256, 33);
    }

    function testCannotMakeATransferIfDelayExceeded() public {
        // Arrange
        vm.prank(ADDRESS1);
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2,defaultValue));
        ruleVinkulierung.createTransferRequest(ADDRESS2,defaultValue);
        
        // Act
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2,defaultValue, 0);
        ruleVinkulierung.approveTransferRequest(ADDRESS1, ADDRESS2,defaultValue, true);

        // +30 days and one second
        vm.warp(block.timestamp + 2592001);
        // Act
         vm.expectRevert(
        abi.encodeWithSelector(Errors.CMTAT_InvalidTransfer.selector, ADDRESS1, ADDRESS2,defaultValue));   
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2,defaultValue);
    }

    function testCannotMakeATransferIfDelayJustInTime() public {
        // Arrange
        vm.prank(ADDRESS1);
        // Act
        bytes32 key = keccak256(abi.encode(ADDRESS1, ADDRESS2,defaultValue));
        ruleVinkulierung.createTransferRequest(ADDRESS2,defaultValue);
        
        // Act
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(key, ADDRESS1, ADDRESS2,defaultValue, 0);
        ruleVinkulierung.approveTransferRequest(ADDRESS1, ADDRESS2,defaultValue, true);
        // 30 days
        vm.warp(block.timestamp + 2592000);
        // Act
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2,defaultValue);
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
        CMTAT_CONTRACT.burn(ADDRESS1,defaultValue, "test");

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT - defaultValue);
    }

    function testAutomaticTransferIfOptionsSet() public {
       AUTOMATIC_TRANSFER memory automaticTransferTest = AUTOMATIC_TRANSFER({
            isActivate:true,
            cmtat: CMTAT_CONTRACT
        });
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        ruleVinkulierung.setAutomaticTransfer(automaticTransferTest);
        
        // Aproval
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.approve(address(ruleVinkulierung), defaultValue);

        // Arrange
        _createTransferRequest();
        
        // Act
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        vm.expectEmit(true, true, true, true);
        emit transferApproved(defaultKey, ADDRESS1, ADDRESS2,defaultValue, 0);
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2,defaultValue, 0);
        ruleVinkulierung.approveTransferRequest(ADDRESS1, ADDRESS2,defaultValue, true);
    }

    function testCanTransferIfAutomaticApprovalSetAndTimeExceeds() public {
        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: true,
            timeLimitBeforeAutomaticApproval: 90 days
        });
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        ruleVinkulierung.setAutomaticApproval(automaticApproval_);
        
        // Arrange
        _createTransferRequest();
        

        vm.warp(block.timestamp + 90 days);
        // Act
        vm.prank(ADDRESS1);
        vm.expectEmit(true, true, true, true);
        emit transferProcessed(defaultKey, ADDRESS1, ADDRESS2,defaultValue, 0);
        CMTAT_CONTRACT.transfer(ADDRESS2,defaultValue);
    }

    function testCannotTransferIfAutomaticApprovalSetAndTimeNotExceeds() public {
        AUTOMATIC_APPROVAL memory automaticApproval_ = AUTOMATIC_APPROVAL({
            isActivate: true,
            timeLimitBeforeAutomaticApproval: 90 days
        });
        vm.prank(VINKULIERUNG_OPERATOR_ADDRESS);
        ruleVinkulierung.setAutomaticApproval(automaticApproval_);
        
        // Arrange
        _createTransferRequest();
        

        vm.warp(block.timestamp + 92 days);
        // Act
        vm.prank(ADDRESS1);
        vm.expectRevert(
        abi.encodeWithSelector(Errors.CMTAT_InvalidTransfer.selector, ADDRESS1, ADDRESS2, defaultValue));   
        CMTAT_CONTRACT.transfer(ADDRESS2,defaultValue);
    }
}
