// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
/* ==== CMTAT === */
import {IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {IERC1404, IERC1404Extend} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";
import {IERC7551Compliance} from "CMTAT/interfaces/tokenization/draft-IERC7551.sol";
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";
/* ==== Interfaces === */
import {IRule} from "../../interfaces/IRule.sol";

/**
 * @title RuleInterfaceId
 * @dev ERC-165 interface ID for the full IRule hierarchy (XOR of all function selectors).
 *
 * Computed from the interfaces themselves rather than hardcoded. `type(IRule).interfaceId` alone
 * covers only `canReturnTransferRestrictionCode`, the single function `IRule` declares directly, so
 * the flattened ID XORs in every parent of the hierarchy. `IRuleEngineERC1404` contributes nothing
 * of its own — it declares no function, and its `type(...).interfaceId` is `0x00000000` — so it does
 * not appear below; its parents do.
 *
 * The value is unchanged from the hardcoded literal it replaces, and is pinned by the tests against
 * both the flattened `IRuleAllFunctions` helper and the literal wire value.
 */
library RuleInterfaceId {
    /**
     * @notice ERC-165 interface ID advertised by every rule usable by the RuleEngine.
     * @dev Flattened over: `IRule` (canReturnTransferRestrictionCode), `IRuleEngine`
     * (transferred with spender), `IERC7551Compliance` (canTransferFrom), `IERC3643ComplianceRead`
     * (canTransfer), `IERC3643IComplianceContract` (transferred), `IERC1404`
     * (detectTransferRestriction, messageForTransferRestriction), `IERC1404Extend`
     * (detectTransferRestrictionFrom) and `IERC165` (supportsInterface). Equals `0x2497d6cb`.
     */
    bytes4 public constant IRULE_INTERFACE_ID =
        type(IRule).interfaceId ^ type(IRuleEngine).interfaceId ^ type(IERC7551Compliance).interfaceId
        ^ type(IERC3643ComplianceRead).interfaceId ^ type(IERC3643IComplianceContract).interfaceId
        ^ type(IERC1404).interfaceId ^ type(IERC1404Extend).interfaceId ^ type(IERC165).interfaceId;
}
