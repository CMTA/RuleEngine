// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IAccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/IAccessControlEnumerable.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {ERC2771ModuleStandalone} from "src/modules/ERC2771ModuleStandalone.sol";
import {VersionModule} from "src/modules/VersionModule.sol";
import {ComplianceInterfaceId} from "src/modules/library/ComplianceInterfaceId.sol";
import {ERC1404InterfaceId} from "src/modules/library/ERC1404InterfaceId.sol";
import {OwnableInterfaceId} from "src/modules/library/OwnableInterfaceId.sol";
import {Ownable2StepInterfaceId} from "src/modules/library/Ownable2StepInterfaceId.sol";

/// @dev Minimal view of the `*2771Exposed` coverage mocks.
interface IExposedMsgData {
    function exposedMsgData() external view returns (bytes memory);
}

/**
 * @title ERC2771VariantTestBase
 * @notice Shared tests for the deployables with ERC-2771 support (`RuleEngine2771`, `RuleEngineOwnable2771`,
 * `RuleEngineOwnable2Step2771`): the forwarder is trusted, the ERC-2771 context unwraps relayed calls, and the
 * variant behaves like its counterpart without a forwarder everywhere else.
 */
abstract contract ERC2771VariantTestBase is Test {
    address internal constant ADMIN = address(0xA11CE);
    address internal constant FORWARDER = address(0xF0F0);
    address internal constant TOKEN = address(0x7070);

    /* ============ Variant hooks ============ */

    /// @dev Deploys the ERC-2771 variant.
    function _deploy2771(address admin, address forwarder, address token) internal virtual returns (address);

    /// @dev Deploys the same access-control variant without ERC-2771.
    function _deployWithoutForwarder(address admin, address token) internal virtual returns (address);

    /// @dev Deploys the variant's `*2771Exposed` coverage mock.
    function _deployExposed(address admin, address forwarder) internal virtual returns (address);

    /// @dev Revert data of the constructor when the admin/owner is the zero address.
    function _zeroAdminRevertData() internal pure virtual returns (bytes memory);

    /* ============ Tests ============ */

    function testForwarderIsTrusted() public {
        ERC2771ModuleStandalone engine = ERC2771ModuleStandalone(_deploy2771(ADMIN, FORWARDER, TOKEN));
        assertTrue(engine.isTrustedForwarder(FORWARDER));
        assertFalse(engine.isTrustedForwarder(ADMIN));
        assertEq(engine.trustedForwarder(), FORWARDER);
    }

    function testHasRightVersion() public {
        assertEq(VersionModule(_deploy2771(ADMIN, FORWARDER, TOKEN)).version(), "3.0.0-rc7");
    }

    function testCannotDeployIfAdminIsZero() public {
        vm.expectRevert(_zeroAdminRevertData());
        this.deploy2771External(address(0), FORWARDER, address(0));
    }

    /// @dev External wrapper so `vm.expectRevert` applies to the constructor call alone.
    function deploy2771External(address admin, address forwarder, address token) external returns (address) {
        return _deploy2771(admin, forwarder, token);
    }

    /// @notice ERC-2771 has no ERC-165 id: the variant advertises exactly what its counterpart advertises.
    function testAdvertisesTheSameInterfacesAsTheVariantWithoutForwarder() public {
        IERC165 withForwarder = IERC165(_deploy2771(ADMIN, FORWARDER, TOKEN));
        IERC165 without = IERC165(_deployWithoutForwarder(ADMIN, TOKEN));
        bytes4[13] memory ids = [
            type(IERC165).interfaceId,
            RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID,
            ERC1404InterfaceId.IERC1404_INTERFACE_ID,
            ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID,
            ComplianceInterfaceId.ERC3643_COMPLIANCE_INTERFACE_ID,
            ComplianceInterfaceId.ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID,
            ComplianceInterfaceId.IERC7551_COMPLIANCE_INTERFACE_ID,
            OwnableInterfaceId.IERC173_INTERFACE_ID,
            Ownable2StepInterfaceId.IOWNABLE2STEP_INTERFACE_ID,
            type(IAccessControl).interfaceId,
            type(IAccessControlEnumerable).interfaceId,
            bytes4(0x00000000),
            bytes4(0xffffffff)
        ];
        for (uint256 i = 0; i < ids.length; ++i) {
            assertEq(withForwarder.supportsInterface(ids[i]), without.supportsInterface(ids[i]));
        }
    }

    /// @notice `_msgData` returns the plain calldata on a direct call, and strips the sender on a relayed one.
    function testMsgDataStripsTheRelayedSender() public {
        IExposedMsgData exposed = IExposedMsgData(_deployExposed(ADMIN, FORWARDER));
        bytes memory selector = abi.encodeCall(exposed.exposedMsgData, ());

        assertEq(exposed.exposedMsgData(), selector);

        vm.prank(FORWARDER);
        (bool ok, bytes memory ret) = address(exposed).call(abi.encodePacked(selector, ADMIN));
        assertTrue(ok);
        assertEq(abi.decode(ret, (bytes)), selector);
    }
}
