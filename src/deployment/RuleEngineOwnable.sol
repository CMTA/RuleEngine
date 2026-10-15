// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RuleEngineOwnableShared} from "../RuleEngineOwnableShared.sol";

/**
 * @title Implementation of a ruleEngine with ERC-173 Ownable access control
 * @dev No ERC-2771 support: every caller is the raw `msg.sender`. Deploy {RuleEngineOwnable2771} to
 * administer the engine through a trusted forwarder (gasless transactions).
 */
contract RuleEngineOwnable is RuleEngineOwnableShared, Ownable {
    /**
     * @notice Deploys a RuleEngine with ERC-173 ownership, without a trusted forwarder.
     * @param owner_ Address of the contract owner (ERC-173)
     * @param tokenContract Address of the token contract to bind (can be zero address)
     */
    constructor(address owner_, address tokenContract) RuleEngineOwnableShared(tokenContract) Ownable(owner_) {}

    /**
     * @notice Transfers ownership of the contract to a new account (`newOwner`).
     * @dev Reverts when `newOwner` is already configured as a rule.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        RuleEngineOwnableShared._checkOwnershipTransferTarget(newOwner);
        Ownable.transferOwnership(newOwner);
    }

    /* ============ ACCESS CONTROL ============ */
    /**
     * @dev Access control check using Ownable pattern
     */
    function _onlyRulesManager() internal virtual override onlyOwner {}

    /**
     * @dev Access control check using Ownable pattern
     */
    function _onlyRulesLimitManager() internal virtual override onlyOwner {}

    /**
     * @dev Access control check using Ownable pattern
     */
    function _onlyComplianceManager() internal virtual override onlyOwner {}
}
