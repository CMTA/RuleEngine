// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
// forge-lint: disable-next-line(unaliased-plain-import)
import "../HelperContractOwnable.sol";
import {MinimalForwarderMock} from "CMTAT/mocks/MinimalForwarderMock.sol";

/**
 * @title Deployment tests for RuleEngineOwnable
 */
contract RuleEngineOwnableDeploymentTest is Test, HelperContractOwnable {
    // Arrange
    function setUp() public {}

    function testRightDeployment() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock();
        forwarder.initialize(ERC2771ForwarderDomain);

        // Act
        ruleEngineMock = new RuleEngineOwnable(OWNER_ADDRESS, address(forwarder), ZERO_ADDRESS);

        // Assert
        assertEq(ruleEngineMock.owner(), OWNER_ADDRESS);
        resBool = ruleEngineMock.isTrustedForwarder(address(forwarder));
        assertEq(resBool, true);
    }

    function testReturnZeroAddressForRule() public {
        // Arrange
        ruleEngineMock = new RuleEngineOwnable(OWNER_ADDRESS, address(0x0), ZERO_ADDRESS);
        // Act
        resAddr = ruleEngineMock.rule(0);
        // Assert
        assertEq(resAddr, ZERO_ADDRESS);
    }

    function testHasRightVersion() public {
        // Act
        ruleEngineMock = new RuleEngineOwnable(OWNER_ADDRESS, address(0x0), ZERO_ADDRESS);

        // Assert
        assertEq(ruleEngineMock.version(), "3.0.0");
    }

    function testCannotDeployContractIfOwnerAddressIsZero() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock();
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.expectRevert(abi.encodeWithSignature("OwnableInvalidOwner(address)", ZERO_ADDRESS));
        // Act
        ruleEngineMock = new RuleEngineOwnable(address(0x0), address(forwarder), ZERO_ADDRESS);
    }

    function testSupportsERC173Interface() public {
        // Arrange
        ruleEngineMock = new RuleEngineOwnable(OWNER_ADDRESS, address(0x0), ZERO_ADDRESS);

        // Act & Assert - ERC-173 interface ID
        assertTrue(ruleEngineMock.supportsInterface(0x7f5828d0));
    }

    function testDeploymentWithTokenBound() public {
        // Arrange
        address tokenAddress = address(0x123);

        // Act
        ruleEngineMock = new RuleEngineOwnable(OWNER_ADDRESS, address(0x0), tokenAddress);

        // Assert
        assertTrue(ruleEngineMock.isTokenBound(tokenAddress));
        assertEq(ruleEngineMock.getTokenBound(), tokenAddress);
    }
}
