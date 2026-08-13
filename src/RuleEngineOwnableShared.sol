// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
/* ==== Modules === */
import {ERC2771ModuleStandalone, ERC2771Context} from "./modules/ERC2771ModuleStandalone.sol";
/* ==== Base contract === */
import {RuleEngineBase} from "./RuleEngineBase.sol";
import {OwnableInterfaceId} from "./modules/library/OwnableInterfaceId.sol";
import {IRule} from "./interfaces/IRule.sol";

/**
 * @title Shared Ownable deployment logic for RuleEngine variants
 * @dev Kept abstract to let child contracts choose the ownership mechanism
 * (`Ownable` or `Ownable2Step`) while reusing constructor, ERC-165 and ERC-2771 code.
 */
abstract contract RuleEngineOwnableShared is ERC2771ModuleStandalone, RuleEngineBase, ERC165 {
    /**
     * @notice Sets the trusted forwarder and optionally binds an initial token.
     * @param forwarderIrrevocable Address of the trusted ERC-2771 forwarder, immutable after construction.
     * @param tokenContract Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address forwarderIrrevocable, address tokenContract) ERC2771ModuleStandalone(forwarderIrrevocable) {
        if (tokenContract != address(0)) {
            _bindToken(tokenContract);
        }
        // Emit the initial cap so the event log alone is enough to reconstruct maxRules.
        emit SetMaxRules(_maxRules);
    }

    /* ============ ERC-165 ============ */
    /**
     * @notice ERC-165 interface detection.
     * @param interfaceId The interface identifier to check.
     * @return True if the interface is supported, false otherwise.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return _supportsRuleEngineBaseInterface(interfaceId) || interfaceId == OwnableInterfaceId.IERC173_INTERFACE_ID
            || ERC165.supportsInterface(interfaceId);
    }

    /**
     * @dev Shared guard for ownership transfer targets in ownable variants.
     * @param newOwner The candidate new owner; must not be a configured rule.
     */
    function _checkOwnershipTransferTarget(address newOwner) internal view virtual {
        if (containsRule(IRule(newOwner))) {
            revert RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges();
        }
    }

    /*//////////////////////////////////////////////////////////////
                           ERC-2771
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     * @return sender The transaction sender, unwrapped from the forwarder calldata when relayed.
     */
    function _msgSender() internal view virtual override(ERC2771Context, Context) returns (address sender) {
        return ERC2771Context._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     * @return The transaction calldata, with the appended sender stripped when relayed.
     */
    function _msgData() internal view virtual override(ERC2771Context, Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     * @return The length of the ERC-2771 calldata suffix.
     */
    function _contextSuffixLength() internal view virtual override(ERC2771Context, Context) returns (uint256) {
        return ERC2771Context._contextSuffixLength();
    }
}
