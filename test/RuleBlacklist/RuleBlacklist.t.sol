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
    // Arrange
    function setUp() public {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleBlacklist = new RuleBlacklist(DEFAULT_ADMIN_ADDRESS, ZERO_ADDRESS);
    }

    function testCanRuleBlacklistReturnMessageNotFoundWithUnknownCodeId()
        public
        view
    {
        // Act
        string memory message1 = ruleBlacklist.messageForTransferRestriction(
            255
        );

        // Assert
        assertEq(message1, TEXT_CODE_NOT_FOUND);
    }
}
