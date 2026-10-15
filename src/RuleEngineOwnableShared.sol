// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.27;

/* ==== OpenZeppelin === */
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
/* ==== Base contract === */
import {RuleEngineBase} from "./RuleEngineBase.sol";
import {OwnableInterfaceId} from "./modules/library/OwnableInterfaceId.sol";
import {IRule} from "./interfaces/IRule.sol";

/**
 * @title Shared Ownable deployment logic for RuleEngine variants
 * @dev Kept abstract to let child contracts choose the ownership mechanism
 * (`Ownable` or `Ownable2Step`) while reusing constructor and ERC-165 code. Free of ERC-2771:
 * the `*2771` deployables add the trusted forwarder on top of the ownable deployables.
 */
abstract contract RuleEngineOwnableShared is RuleEngineBase, ERC165 {
    /**
     * @notice Optionally binds an initial token and emits the initial rule cap.
     * @param tokenContract Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address tokenContract) {
        if (tokenContract != address(0)) {
            _bindToken(tokenContract);
        }
        // Emit the initial cap so the event log alone is enough to reconstruct maxRules.
        _setMaxRules(DEFAULT_MAX_RULES);
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
}
