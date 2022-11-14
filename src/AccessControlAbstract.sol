// SPDX-License-Identifier: MPL-2.0

pragma solidity 0.8.17;

import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

contract AccessControlAbstract is AccessControl {
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_OPERATOR");
    bytes32 public constant RULE_ENGINE_ROLE =
        keccak256("RULE_ENGINE_OPERATOR");
}
