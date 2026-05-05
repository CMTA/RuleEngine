// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {RuleEngineOwnableShared} from "../RuleEngineOwnableShared.sol";
import {Ownable2StepInterfaceId} from "../modules/library/Ownable2StepInterfaceId.sol";

/**
 * @title Implementation of a ruleEngine with ERC-173 Ownable2Step access control
 */
contract RuleEngineOwnable2Step is RuleEngineOwnableShared, Ownable2Step {
    /**
     * @param owner_ Address of the contract owner (ERC-173)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     * @param tokenContract Address of the token contract to bind (can be zero address)
     */
    constructor(address owner_, address forwarderIrrevocable, address tokenContract)
        RuleEngineOwnableShared(forwarderIrrevocable, tokenContract)
        Ownable(owner_)
    {}

    /* ============ ACCESS CONTROL ============ */
    /**
     * @dev Access control check using Ownable pattern
     */
    function _onlyRulesManager() internal virtual override onlyOwner {}
    function _onlyRulesLimitManager() internal virtual override onlyOwner {}

    /**
     * @dev Access control check using Ownable pattern
     */
    function _onlyComplianceManager() internal virtual override onlyOwner {}

    /**
     * @notice Starts ownership transfer to `newOwner`.
     * @dev Reverts when `newOwner` is already configured as a rule.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        RuleEngineOwnableShared._checkOwnershipTransferTarget(newOwner);
        Ownable2Step.transferOwnership(newOwner);
    }

    /* ============ ERC-165 ============ */
    function supportsInterface(bytes4 interfaceId) public view virtual override(RuleEngineOwnableShared) returns (bool) {
        return interfaceId == Ownable2StepInterfaceId.IOWNABLE2STEP_INTERFACE_ID
            || RuleEngineOwnableShared.supportsInterface(interfaceId);
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgSender() internal view virtual override(RuleEngineOwnableShared, Context) returns (address sender) {
        return RuleEngineOwnableShared._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgData() internal view virtual override(RuleEngineOwnableShared, Context) returns (bytes calldata) {
        return RuleEngineOwnableShared._msgData();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _contextSuffixLength() internal view virtual override(RuleEngineOwnableShared, Context) returns (uint256) {
        return RuleEngineOwnableShared._contextSuffixLength();
    }
}
