// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "../HelperContract.sol";
import "src/RuleWhiteList.sol";

contract RuleWhitelistKillTest is Test, HelperContract, RuleWhitelist {
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;
    uint256 BALANCE_ETHER = 20;

    function setUp() public {
        // Arrange - create contracts
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist = new RuleWhitelist();

        // Arrange - balance of the contract
        vm.deal(address(ruleWhitelist), BALANCE_ETHER);
        // Arrange - Assert - size of the contract
        bool sizeIsDifferentOfZero;
        address ruleWhitelistLocal = address(ruleWhitelist);
        uint256 size;
        assembly {
            size := extcodesize(ruleWhitelistLocal)
            sizeIsDifferentOfZero := eq(size, 0)
        }
        assertFalse(sizeIsDifferentOfZero);
        // Act
        // The call of the kill function need to be in the setup function
        // see https://github.com/foundry-rs/foundry/issues/1543
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.kill();
    }

    function testCanKill() public {
        address ruleWhitelistLocal = address(ruleWhitelist);
        uint256 size;
        // Assert
        // Size of the destroyed contract must be 0
        assembly {
            size := extcodesize(ruleWhitelistLocal)
        }
        assertEq(size, 0);
    }

    function testCanKillSendEtherToTheRightAddress() public {
        assertEq(address(ruleWhitelist).balance, 0);
        assertEq(address(DEFAULT_ADMIN_ADDRESS).balance, BALANCE_ETHER);
    }
}
