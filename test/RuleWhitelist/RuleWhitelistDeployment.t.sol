// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";
import "CMTAT/mocks/MinimalForwarderMock.sol";
/**
@title General functions of the RuleWhitelist
*/
contract RuleWhitelistTest is Test, HelperContract {
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
    }

    function testRightDeployment() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock(
        );
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            address(forwarder)
        );

        // assert
        resBool = ruleWhitelist.hasRole(WHITELIST_ROLE, WHITELIST_OPERATOR_ADDRESS);
        assertEq(resBool, true);
        resBool = ruleWhitelist.isTrustedForwarder(address(forwarder));
        assertEq(resBool, true);
    }

    function testCannotDeployContractIfAdminAddressIsZero() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock(
        );
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.expectRevert(RuleWhitelist_AdminWithAddressZeroNotAllowed.selector);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist = new RuleWhitelist(
            address(0),
            address(forwarder)
        );
    }
}
