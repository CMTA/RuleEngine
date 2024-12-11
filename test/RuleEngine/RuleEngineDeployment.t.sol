// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "CMTAT/mocks/MinimalForwarderMock.sol";
import "src/RuleEngine.sol";
import "src/RuleEngine.sol";

/**
 * @title General functions of the RuleEngine
 */
contract RuleEngineTest is Test, HelperContract {
    // Arrange
    function setUp() public {}

    function testRightDeployment() public {
        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock();
        forwarder.initialize(ERC2771ForwarderDomain);

        // Act
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            address(forwarder),
            ZERO_ADDRESS
        );

        // assert
        resBool = ruleEngineMock.hasRole(
            RULE_ENGINE_OPERATOR_ROLE,
            RULE_ENGINE_OPERATOR_ADDRESS
        );
        assertEq(resBool, true);
        resBool = ruleEngineMock.isTrustedForwarder(address(forwarder));
        assertEq(resBool, true);
    }

    function testCannotDeployContractifAdminAddressIsZero() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock();
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.expectRevert(RuleEngine_AdminWithAddressZeroNotAllowed.selector);
        // Act
        ruleEngineMock = new RuleEngine(
            address(0x0),
            address(forwarder),
            ZERO_ADDRESS
        );
    }
}
