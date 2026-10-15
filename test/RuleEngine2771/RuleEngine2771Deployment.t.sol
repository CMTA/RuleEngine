// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IAccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/IAccessControlEnumerable.sol";
import {MinimalForwarderMock} from "CMTAT/mocks/MinimalForwarderMock.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {RuleEngine2771} from "src/deployment/accessControl/RuleEngine2771.sol";
import {ComplianceInterfaceId} from "src/modules/library/ComplianceInterfaceId.sol";
import {ERC1404InterfaceId} from "src/modules/library/ERC1404InterfaceId.sol";
import {RuleEngineInvariantStorage} from "src/modules/library/RuleEngineInvariantStorage.sol";

/**
 * @title RuleEngine2771DeploymentTest
 * @notice Deployment and ERC-165 tests for the RBAC `RuleEngine2771`. The forwarder, `_msgData` and
 * zero-admin checks shared with the ownable `*2771` variants are in `ERC2771Variant.t.sol`.
 */
contract RuleEngine2771DeploymentTest is Test, RuleEngineInvariantStorage {
    address internal constant ADMIN = address(0xA11CE);
    address internal constant TOKEN = address(0x7070);

    MinimalForwarderMock internal forwarder;
    RuleEngine2771 internal engine;

    function setUp() public {
        forwarder = new MinimalForwarderMock();
        forwarder.initialize("ERC2771ForwarderDomain");
        engine = new RuleEngine2771(ADMIN, address(forwarder), TOKEN);
    }

    function testRightDeployment() public view {
        assertTrue(engine.isTrustedForwarder(address(forwarder)));
        assertFalse(engine.isTrustedForwarder(ADMIN));
        assertEq(engine.trustedForwarder(), address(forwarder));
        assertTrue(engine.hasRole(engine.DEFAULT_ADMIN_ROLE(), ADMIN));
        assertTrue(engine.hasRole(engine.RULES_MANAGEMENT_ROLE(), ADMIN));
        assertTrue(engine.hasRole(engine.COMPLIANCE_MANAGER_ROLE(), ADMIN));
        assertTrue(engine.isTokenBound(TOKEN));
        assertEq(engine.maxRules(), 10);
    }

    /// @notice Same interfaces as `RuleEngine`: ERC-2771 adds no ERC-165 id.
    function testSupportsInterfaces() public view {
        assertTrue(engine.supportsInterface(type(IERC165).interfaceId));
        assertTrue(engine.supportsInterface(type(IAccessControl).interfaceId));
        assertTrue(engine.supportsInterface(type(IAccessControlEnumerable).interfaceId));
        assertTrue(engine.supportsInterface(RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID));
        assertTrue(engine.supportsInterface(ERC1404InterfaceId.IERC1404_INTERFACE_ID));
        assertTrue(engine.supportsInterface(ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID));
        assertTrue(engine.supportsInterface(ComplianceInterfaceId.ERC3643_COMPLIANCE_INTERFACE_ID));
        assertTrue(engine.supportsInterface(ComplianceInterfaceId.ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID));
        assertTrue(engine.supportsInterface(ComplianceInterfaceId.IERC7551_COMPLIANCE_INTERFACE_ID));
        assertFalse(engine.supportsInterface(0xffffffff));
    }
}
