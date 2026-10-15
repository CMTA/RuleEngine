// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Base contract === */
import {RuleEngineAccessControlShared} from "../RuleEngineAccessControlShared.sol";

/**
 * @title Implementation of a ruleEngine as defined by the CMTAT, with RBAC access control
 * @dev No ERC-2771 support: every caller is the raw `msg.sender`. Deploy {RuleEngine2771} to
 * administer the engine through a trusted forwarder (gasless transactions).
 */
contract RuleEngine is RuleEngineAccessControlShared {
    /**
     * @notice Deploys the RBAC RuleEngine without a trusted forwarder.
     * @param admin Address receiving `DEFAULT_ADMIN_ROLE`; must not be the zero address.
     * @param tokenContract Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address admin, address tokenContract) RuleEngineAccessControlShared(admin, tokenContract) {}
}
