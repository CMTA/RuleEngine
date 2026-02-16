// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
// forge-lint: disable-next-line(unaliased-plain-import)
import "../HelperContract.sol";
import {MinimalForwarderMock} from "CMTAT/mocks/MinimalForwarderMock.sol";

/**
 * @title General functions of the RuleWhitelist
 */
contract RuleWhitelistDeploymentTest is Test, HelperContract {
    // Arrange
    function setUp() public {}

    function testRightDeployment() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock();
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist = new RuleWhitelist(WHITELIST_OPERATOR_ADDRESS, address(forwarder));

        // assert
        resBool = ruleWhitelist.hasRole(ADDRESS_LIST_ADD_ROLE, WHITELIST_OPERATOR_ADDRESS);
        assertEq(resBool, true);
        resBool = ruleWhitelist.hasRole(ADDRESS_LIST_REMOVE_ROLE, WHITELIST_OPERATOR_ADDRESS);
        assertEq(resBool, true);
        resBool = ruleWhitelist.isTrustedForwarder(address(forwarder));
        assertEq(resBool, true);
    }

    function testCannotDeployContractIfAdminAddressIsZero() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock();
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.expectRevert(RuleAddressList_AdminWithAddressZeroNotAllowed.selector);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist = new RuleWhitelist(address(0), address(forwarder));
    }
}
