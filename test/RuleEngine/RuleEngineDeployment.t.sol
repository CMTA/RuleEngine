// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
// forge-lint: disable-next-line(unaliased-plain-import)
import "../HelperContract.sol";
import {MinimalForwarderMock} from "CMTAT/mocks/MinimalForwarderMock.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IAccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/IAccessControlEnumerable.sol";
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
import {ICompliance} from "src/mocks/ICompliance.sol";
import {IERC7551ComplianceSubset} from "src/mocks/IERC7551ComplianceSubset.sol";
import {IERC1404Subset} from "src/mocks/IERC1404Subset.sol";
import {ERC1404InterfaceId} from "src/modules/library/ERC1404InterfaceId.sol";

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
        ruleEngineMock = new RuleEngine(RULE_ENGINE_OPERATOR_ADDRESS, address(forwarder), ZERO_ADDRESS);

        // assert
        resBool = ruleEngineMock.hasRole(RULES_MANAGEMENT_ROLE, RULE_ENGINE_OPERATOR_ADDRESS);
        assertEq(resBool, true);
        resBool = ruleEngineMock.isTrustedForwarder(address(forwarder));
        assertEq(resBool, true);
    }

    function testReturnZeroAddressForRule() public {
        // Arrange
        ruleEngineMock = new RuleEngine(RULE_ENGINE_OPERATOR_ADDRESS, address(0x0), ZERO_ADDRESS);
        // Act
        resAddr = ruleEngineMock.rule(0);
        // Assert
        assertEq(resAddr, ZERO_ADDRESS);
    }

    function testHasRightVersion() public {
        // Act
        ruleEngineMock = new RuleEngine(RULE_ENGINE_OPERATOR_ADDRESS, address(0x0), ZERO_ADDRESS);

        // Assert
        assertEq(ruleEngineMock.version(), "3.0.0");
    }

    function testSupportsInterfaces() public {
        // Arrange
        ruleEngineMock = new RuleEngine(RULE_ENGINE_OPERATOR_ADDRESS, address(0x0), ZERO_ADDRESS);

        // Act & Assert
        assertTrue(ruleEngineMock.supportsInterface(type(IERC165).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(type(IAccessControl).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(type(IAccessControlEnumerable).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(ERC1404InterfaceId.IERC1404_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC1404Subset).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(ICompliance).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC7551ComplianceSubset).interfaceId));
    }

    function testCannotDeployContractifAdminAddressIsZero() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock();
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.expectRevert(RuleEngine_AdminWithAddressZeroNotAllowed.selector);
        // Act
        ruleEngineMock = new RuleEngine(address(0x0), address(forwarder), ZERO_ADDRESS);
    }
}
