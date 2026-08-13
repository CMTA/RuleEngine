// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {RuleEngineOwnableShared} from "../RuleEngineOwnableShared.sol";

/**
 * @title Implementation of a ruleEngine with ERC-173 Ownable access control
 */
contract RuleEngineOwnable is RuleEngineOwnableShared, Ownable {
    /**
     * @param owner_ Address of the contract owner (ERC-173)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     * @param tokenContract Address of the token contract to bind (can be zero address)
     */
    constructor(address owner_, address forwarderIrrevocable, address tokenContract)
        RuleEngineOwnableShared(forwarderIrrevocable, tokenContract)
        Ownable(owner_)
    {}

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

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     * @return sender The transaction sender, unwrapped from the forwarder calldata when relayed.
     */
    function _msgSender() internal view virtual override(RuleEngineOwnableShared, Context) returns (address sender) {
        return RuleEngineOwnableShared._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     * @return The transaction calldata, with the appended sender stripped when relayed.
     */
    function _msgData() internal view virtual override(RuleEngineOwnableShared, Context) returns (bytes calldata) {
        return RuleEngineOwnableShared._msgData();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     * @return The length of the ERC-2771 calldata suffix.
     */
    function _contextSuffixLength() internal view virtual override(RuleEngineOwnableShared, Context) returns (uint256) {
        return RuleEngineOwnableShared._contextSuffixLength();
    }
}
