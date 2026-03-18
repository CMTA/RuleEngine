// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
/* ==== OpenZeppelin === */
import {Context} from "OZ/utils/Context.sol";
import {IERC165} from "OZ/utils/introspection/IERC165.sol";
/* ==== Modules === */
import {ERC2771ModuleStandalone, ERC2771Context} from "./modules/ERC2771ModuleStandalone.sol";
/* ==== Base contract === */
import {RuleEngineBase} from "./RuleEngineBase.sol";
import {ComplianceInterfaceId} from "./modules/library/ComplianceInterfaceId.sol";

/**
 * @title Shared Ownable deployment logic for RuleEngine variants
 * @dev Kept abstract to let child contracts choose the ownership mechanism
 * (`Ownable` or `Ownable2Step`) while reusing constructor, ERC-165 and ERC-2771 code.
 */
abstract contract RuleEngineOwnableShared is ERC2771ModuleStandalone, RuleEngineBase {
    bytes4 private constant ERC173_INTERFACE_ID = 0x7f5828d0;

    constructor(address forwarderIrrevocable, address tokenContract) ERC2771ModuleStandalone(forwarderIrrevocable) {
        if (tokenContract != address(0)) {
            _bindToken(tokenContract);
        }
    }

    /* ============ ERC-165 ============ */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID
            || interfaceId == ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID
            || interfaceId == ERC173_INTERFACE_ID
            || interfaceId == ComplianceInterfaceId.ERC3643_COMPLIANCE_INTERFACE_ID
            || interfaceId == ComplianceInterfaceId.IERC7551_COMPLIANCE_INTERFACE_ID
            || interfaceId == type(IERC165).interfaceId;
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
