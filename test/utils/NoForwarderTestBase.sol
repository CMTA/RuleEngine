// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ITokenBinding} from "src/interfaces/ITokenBinding.sol";

/**
 * @title NoForwarderTestBase
 * @notice Shared tests for the deployables without ERC-2771 (`RuleEngine`, `RuleEngineOwnable`,
 * `RuleEngineOwnable2Step`): they expose no forwarder and never read a sender appended to the calldata.
 */
abstract contract NoForwarderTestBase is Test {
    address internal constant ADMIN = address(0xA11CE);
    address internal constant RELAYER = address(0xF0F0);
    address internal constant TOKEN = address(0x7070);

    address internal engine;

    /* ============ Variant hooks ============ */

    /// @dev Deploys the variant with `admin` as admin/owner and `token` bound (or none).
    function _deployEngine(address admin, address token) internal virtual returns (address);

    /// @dev Revert data of the variant's binding-manager check when `caller` is not authorized.
    function _managerRevertData(address caller) internal view virtual returns (bytes memory);

    function setUp() public virtual {
        engine = _deployEngine(ADMIN, address(0));
    }

    /* ============ Tests ============ */

    /// @notice There is no ERC-2771 surface: `isTrustedForwarder` / `trustedForwarder` do not exist.
    function testHasNoTrustedForwarder() public {
        (bool ok,) = engine.call(abi.encodeWithSignature("isTrustedForwarder(address)", RELAYER));
        assertFalse(ok, "must not expose isTrustedForwarder");
        (ok,) = engine.call(abi.encodeWithSignature("trustedForwarder()"));
        assertFalse(ok, "must not expose trustedForwarder");
    }

    /// @notice A sender appended to the calldata is ignored: the caller is always the raw `msg.sender`.
    function testAppendedSenderIsIgnored() public {
        vm.prank(RELAYER);
        (bool ok, bytes memory ret) =
            engine.call(abi.encodePacked(abi.encodeCall(ITokenBinding.bindToken, (TOKEN)), ADMIN));
        assertFalse(ok, "an appended admin address must not authorize the call");
        assertEq(ret, _managerRevertData(RELAYER));
        assertFalse(ITokenBinding(engine).isTokenBound(TOKEN));

        // The same call made by the admin itself succeeds.
        vm.prank(ADMIN);
        ITokenBinding(engine).bindToken(TOKEN);
        assertTrue(ITokenBinding(engine).isTokenBound(TOKEN));
    }
}
