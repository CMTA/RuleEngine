// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
/* ==== OpenZeppelin === */
import {Context} from "OZ/utils/Context.sol";
import {Ownable} from "OZ/access/Ownable.sol";
import {IERC165} from "OZ/utils/introspection/IERC165.sol";
import {AccessControl} from "OZ/access/AccessControl.sol";
/* ==== Modules === */
import {ERC2771ModuleStandalone, ERC2771Context} from "./modules/ERC2771ModuleStandalone.sol";
/* ==== Base contract === */
import {RuleEngineBase} from "./RuleEngineBase.sol";

/**
 * @title Implementation of a ruleEngine with ERC-173 Ownable access control
 */
contract RuleEngineOwnable is ERC2771ModuleStandalone, RuleEngineBase, Ownable {
    bytes4 private constant ERC173_INTERFACE_ID = 0x7f5828d0;

    /**
     * @param owner_ Address of the contract owner (ERC-173)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     * @param tokenContract Address of the token contract to bind (can be zero address)
     */
    constructor(address owner_, address forwarderIrrevocable, address tokenContract)
        ERC2771ModuleStandalone(forwarderIrrevocable)
        Ownable(owner_)
    {
        // Note: zero-address check for owner_ is handled by Ownable(owner_),
        // which reverts with OwnableInvalidOwner(address(0)) before reaching here.
        if (tokenContract != address(0)) {
            _bindToken(tokenContract);
        }
    }

    /* ============ ACCESS CONTROL ============ */
    /**
     * @dev Access control check using Ownable pattern
     */
    function _onlyRulesManager() internal virtual override onlyOwner {}

    /**
     * @dev Access control check using Ownable pattern
     */
    function _onlyComplianceManager() internal virtual override onlyOwner {}

    /* ============ ERC-165 ============ */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, IERC165) returns (bool) {
        return interfaceId == RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID
            || interfaceId == ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID || interfaceId == ERC173_INTERFACE_ID
            || AccessControl.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                           ERC-2771
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgSender() internal view virtual override(ERC2771Context, Context) returns (address sender) {
        return ERC2771Context._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgData() internal view virtual override(ERC2771Context, Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _contextSuffixLength() internal view virtual override(ERC2771Context, Context) returns (uint256) {
        return ERC2771Context._contextSuffixLength();
    }
}
