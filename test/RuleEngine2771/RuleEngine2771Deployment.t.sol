// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IAccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/IAccessControlEnumerable.sol";
import {MinimalForwarderMock} from "CMTAT/mocks/MinimalForwarderMock.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {RuleEngine2771} from "src/deployment/RuleEngine2771.sol";
import {RuleEngine2771Exposed} from "src/mocks/RuleEngineExposed.sol";
import {ComplianceInterfaceId} from "src/modules/library/ComplianceInterfaceId.sol";
import {ERC1404InterfaceId} from "src/modules/library/ERC1404InterfaceId.sol";
import {RuleEngineInvariantStorage} from "src/modules/library/RuleEngineInvariantStorage.sol";

/**
 * @title RuleEngine2771DeploymentTest
 * @notice Deployment, ERC-165 and ERC-2771 context tests for the RBAC `RuleEngine2771`.
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

    function testHasRightVersion() public view {
        assertEq(engine.version(), "3.0.0-rc7");
    }

    function testCannotDeployIfAdminAddressIsZero() public {
        vm.expectRevert(RuleEngine_AdminWithAddressZeroNotAllowed.selector);
        new RuleEngine2771(address(0), address(forwarder), address(0));
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

    /// @notice `_msgData` returns the plain calldata on a direct call, and strips the sender on a relayed one.
    function testMsgDataStripsTheRelayedSender() public {
        RuleEngine2771Exposed exposed = new RuleEngine2771Exposed(ADMIN, address(forwarder), address(0));
        bytes memory selector = abi.encodeCall(exposed.exposedMsgData, ());

        assertEq(exposed.exposedMsgData(), selector);

        vm.prank(address(forwarder));
        (bool ok, bytes memory ret) = address(exposed).call(abi.encodePacked(selector, ADMIN));
        assertTrue(ok);
        assertEq(abi.decode(ret, (bytes)), selector);
    }
}
