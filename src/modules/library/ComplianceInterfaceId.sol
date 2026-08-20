// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "CMTAT/interfaces/tokenization/draft-IERC7551.sol";
/* ==== Interfaces === */
import {IERC3643Compliance} from "../../interfaces/IERC3643Compliance.sol";
import {ITokenBinding} from "../../interfaces/ITokenBinding.sol";
import {ITokenBindingExtended} from "../../interfaces/ITokenBindingExtended.sol";

/**
 * @title ComplianceInterfaceId
 * @dev ERC-165 interface IDs used by RuleEngine for compliance interfaces.
 *
 * Each ID is computed from the interfaces themselves rather than hardcoded, because
 * `type(I).interfaceId` covers only the functions declared *directly* on `I`, never the inherited
 * ones. For an interface that inherits, the flattened ID is the XOR of its own ID with the IDs of
 * its parents, which is what the expressions below spell out. A marker interface that declares
 * nothing of its own, such as {IERC3643ComplianceExtended}, has a `type(...).interfaceId` of
 * `0x00000000` — use the constants here, never that expression.
 *
 * The values are unchanged from the hardcoded literals they replace, and the tests pin them
 * against both the flattened helper interfaces and the literal wire values.
 */
library ComplianceInterfaceId {
    /**
     * @notice ERC-165 interface ID of the core ERC-3643 compliance interface.
     * @dev Flattened: `IERC3643Compliance` (created, destroyed, getTokenBound) with its parents
     * `ITokenBinding` (bindToken, unbindToken, isTokenBound), `IERC3643ComplianceRead` (canTransfer)
     * and `IERC3643IComplianceContract` (transferred). Equals `0x3144991c`.
     */
    bytes4 public constant ERC3643_COMPLIANCE_INTERFACE_ID =
        type(IERC3643Compliance).interfaceId ^ type(ITokenBinding).interfaceId
        ^ type(IERC3643ComplianceRead).interfaceId ^ type(IERC3643IComplianceContract).interfaceId;

    /**
     * @notice ERC-165 interface ID of the extended ERC-3643 compliance interface.
     * @dev The extended surface is declared in full by `ITokenBindingExtended` — batch binding,
     * token self-binding and `getTokenBounds` — so its own ID is already the flattened one.
     * `IERC3643ComplianceExtended` adds no function of its own. Equals `0x646ba2be`.
     */
    bytes4 public constant ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID = type(ITokenBindingExtended).interfaceId;

    /**
     * @notice ERC-165 interface ID of the ERC-7551 compliance interface.
     * @dev `IERC7551Compliance` declares only `canTransferFrom`; `canTransfer`, inherited from
     * `IERC3643ComplianceRead`, is advertised through {ERC3643_COMPLIANCE_INTERFACE_ID} instead.
     * This is the subset interface CMTAT uses. Equals `0x7157797f`.
     */
    bytes4 public constant IERC7551_COMPLIANCE_INTERFACE_ID = type(IERC7551Compliance).interfaceId;
}
