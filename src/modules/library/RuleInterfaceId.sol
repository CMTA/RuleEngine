// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.27;

/* ==== OpenZeppelin === */
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
/* ==== CMTAT === */
import {IERC1404, IERC1404Extend} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "CMTAT/interfaces/tokenization/draft-IERC7551.sol";
/* ==== Interfaces === */
import {IRule} from "../../interfaces/IRule.sol";

/**
 * @title RuleInterfaceId
 * @dev ERC-165 interface ID for the full IRule hierarchy (XOR of all function selectors).
 *
 * Computed from the interfaces themselves rather than hardcoded. `type(IRule).interfaceId` alone
 * covers only the two functions `IRule` declares directly (the 4-argument `transferred` and
 * `canReturnTransferRestrictionCode`), so the flattened ID XORs in every parent of the hierarchy.
 * Pinned by the tests against the flattened `IRuleAllFunctions` helper and the literal wire value.
 */
library RuleInterfaceId {
    /**
     * @notice ERC-165 interface ID every rule must advertise to be accepted by the RuleEngine.
     * @dev Flattened over: `IRule` (4-argument transferred, canReturnTransferRestrictionCode),
     * `IERC3643IComplianceContract` (3-argument transferred), `IERC1404` (detectTransferRestriction,
     * messageForTransferRestriction), `IERC1404Extend` (detectTransferRestrictionFrom) and `IERC165`
     * (supportsInterface). Equals `0xb1a69752`.
     */
    bytes4 public constant IRULE_INTERFACE_ID = type(IRule).interfaceId ^ type(IERC3643IComplianceContract).interfaceId
        ^ type(IERC1404).interfaceId ^ type(IERC1404Extend).interfaceId ^ type(IERC165).interfaceId;

    /**
     * @notice Legacy ERC-165 interface ID of `IRule`, before v3.0.0-rc7 narrowed it.
     * @dev The current ID plus `canTransfer` ({IERC3643ComplianceRead}) and `canTransferFrom`
     * ({IERC7551Compliance}), which the engine never calls on a rule. Equals `0x2497d6cb`. Still accepted by
     * the engine, so rules built against the previous interface keep working.
     */
    bytes4 public constant IRULE_LEGACY_INTERFACE_ID =
        IRULE_INTERFACE_ID ^ type(IERC3643ComplianceRead).interfaceId ^ type(IERC7551Compliance).interfaceId;
}
