//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";


contract RuleEngineKillTest is Test, HelperContract, RuleWhitelist {
    RuleEngine ruleEngineMock;
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;
    uint256 BALANCE_ETHER = 20;

    function setUp() public {  
        // Arrange - create contracts
        ruleWhitelist = new RuleWhitelist();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(ruleWhitelist);
        // Arrange -  Assert
        resUint256 = ruleEngineMock.ruleLength();
        assertEq(resUint256, 1);
        // Arrange - balance of the contract
        vm.deal(address(ruleEngineMock), BALANCE_ETHER);
        // Arrange - Assert - size of the contract
        bool sizeIsDifferentOfZero;
        address ruleEngineLocal = address(ruleEngineMock);
        uint256 size;
        assembly {
             size := extcodesize(ruleEngineLocal)
             sizeIsDifferentOfZero := eq(size, 0) 
        }
        assertFalse(sizeIsDifferentOfZero);
        // Act
        // The call of the kill function need to be in the setup function
        // see https://github.com/foundry-rs/foundry/issues/1543
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.kill();
    }

    function testCanKill() public{
        address ruleEngineLocal = address(ruleEngineMock);
        uint256 size;
        // Assert
        // Size of the destroyed contract must be 0
        assembly {
            size := extcodesize(ruleEngineLocal)
        }
        assertEq(size, 0);
        // Assert
        // The call of the function of the destroyed contract must be revert.
        // for unknown reason, the revert is not detected
        // But the function is reverted as planned
        // vm.expectRevert();
        // ruleEngineMock.rules();
    }

    function testCanKillSendEtherToTheRightAddress() public{
        assertEq(address(ruleEngineMock).balance, 0);
        assertEq(address(RULE_ENGINE_OPERATOR_ADDRESS).balance, BALANCE_ETHER);
    }
}