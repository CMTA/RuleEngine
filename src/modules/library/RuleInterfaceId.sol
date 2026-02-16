// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title RuleInterfaceId
 * @dev ERC-165 interface ID for the full IRule hierarchy (XOR of all function selectors).
 *      Computed from the flattened IRuleAllFunctions mock interface.
 *      See src/mocks/IRuleInterfaceIdHelper.sol for the detailed computation.
 */
library RuleInterfaceId {
    bytes4 public constant IRULE_INTERFACE_ID = 0x2497d6cb;
}
