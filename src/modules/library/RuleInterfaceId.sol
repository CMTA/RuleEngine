// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.27;

/* ==== OpenZeppelin === */
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
/* ==== CMTAT === */
import {IERC1404, IERC1404Extend} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";
import {IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";
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
     * (supportsInterface). Equals `0xb1a69752`. Up to v3.0.0-rc7 the interface also required
     * `canTransfer` and `canTransferFrom`, and the ID was `0x2497d6cb`; a rule advertising only that
     * value is rejected.
     */
    bytes4 public constant IRULE_INTERFACE_ID = type(IRule).interfaceId ^ type(IERC3643IComplianceContract).interfaceId
        ^ type(IERC1404).interfaceId ^ type(IERC1404Extend).interfaceId ^ type(IERC165).interfaceId;
}
