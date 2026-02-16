// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {ERC165} from "OZ/utils/introspection/ERC165.sol";

/**
 * @title RuleInvalidMock
 * @dev Mock contract that implements ERC-165 but does NOT support IRULE_INTERFACE_ID.
 *      Used to test that _checkRule rejects rules with invalid interfaces.
 */
contract RuleInvalidMock is ERC165 {
    // Intentionally does NOT override supportsInterface to add RULE_ENGINE_INTERFACE_ID

    }
