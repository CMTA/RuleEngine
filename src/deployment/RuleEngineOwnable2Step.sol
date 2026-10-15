// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RuleEngineOwnableShared} from "../RuleEngineOwnableShared.sol";
import {Ownable2StepInterfaceId} from "../modules/library/Ownable2StepInterfaceId.sol";

/**
 * @title Implementation of a ruleEngine with ERC-173 Ownable2Step access control
 * @dev No ERC-2771 support: every caller is the raw `msg.sender`. Deploy {RuleEngineOwnable2Step2771} to
 * administer the engine through a trusted forwarder (gasless transactions).
 */
contract RuleEngineOwnable2Step is RuleEngineOwnableShared, Ownable2Step {
    /**
     * @notice Deploys a RuleEngine with ERC-173 two-step ownership transfer, without a trusted forwarder.
     * @param owner_ Address of the initial contract owner (ERC-173).
     * @param tokenContract Address of the token contract to bind at deployment (use zero address to skip).
     */
    constructor(address owner_, address tokenContract) RuleEngineOwnableShared(tokenContract) Ownable(owner_) {}

    /**
     * @notice Starts ownership transfer to `newOwner`.
     * @dev Reverts when `newOwner` is already configured as a rule.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        RuleEngineOwnableShared._checkOwnershipTransferTarget(newOwner);
        Ownable2Step.transferOwnership(newOwner);
    }

    /* ============ ERC-165 ============ */
    /**
     * @notice ERC-165 interface detection.
     * @param interfaceId The interface identifier to check.
     * @return True if the interface is supported, false otherwise.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(RuleEngineOwnableShared)
        returns (bool)
    {
        return interfaceId == Ownable2StepInterfaceId.IOWNABLE2STEP_INTERFACE_ID
            || RuleEngineOwnableShared.supportsInterface(interfaceId);
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
