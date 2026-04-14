// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
// forge-lint: disable-next-line(unaliased-plain-import)
import "../HelperContractOwnable.sol";
import {MinimalForwarderMock} from "CMTAT/mocks/MinimalForwarderMock.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
import {ICompliance} from "src/mocks/ICompliance.sol";
import {IERC7551ComplianceSubset} from "src/mocks/IERC7551ComplianceSubset.sol";

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

    function testSupportsInterfaces() public {
        // Arrange
        ruleEngineMock = new RuleEngineOwnable(OWNER_ADDRESS, address(0x0), ZERO_ADDRESS);

        // Act & Assert
        assertTrue(ruleEngineMock.supportsInterface(type(IERC165).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(0x7f5828d0)); // ERC-173
        assertTrue(ruleEngineMock.supportsInterface(RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(ICompliance).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC7551ComplianceSubset).interfaceId));
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
