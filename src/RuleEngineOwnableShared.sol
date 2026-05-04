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
    constructor(address forwarderIrrevocable, address tokenContract) ERC2771ModuleStandalone(forwarderIrrevocable) {
        if (tokenContract != address(0)) {
            _bindToken(tokenContract);
        }
    }

    /* ============ ERC-165 ============ */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return _supportsRuleEngineBaseInterface(interfaceId)
            || interfaceId == OwnableInterfaceId.IERC173_INTERFACE_ID
            || ERC165.supportsInterface(interfaceId);
    }

    /**
     * @dev Shared guard for ownership transfer targets in ownable variants.
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
