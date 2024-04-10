// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/CMTAT_STANDALONE.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
* @title Integration test with the CMTAT
*/
contract RuleBlacklistTest is Test, HelperContract {
    // Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";

    uint256 resUint256;
    bool resBool;

    // Arrange
    function setUp() public {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleBlacklist = new RuleBlacklist(DEFAULT_ADMIN_ADDRESS, ZERO_ADDRESS);
    }

    function testCanRuleBlacklistReturnMessageNotFoundWithUnknownCodeId() public {
        // Act
        string memory message1 = ruleBlacklist.messageForTransferRestriction(
            255
        );

        // Assert
        assertEq(message1, TEXT_CODE_NOT_FOUND);
    }
}
