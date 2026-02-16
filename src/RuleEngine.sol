// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
/* ==== OpenZeppelin === */
import {Context} from "OZ/utils/Context.sol";
import {AccessControl} from "OZ/access/AccessControl.sol";
import {ERC165, IERC165} from "OZ/utils/introspection/ERC165.sol";
/* ==== Modules === */
import {ERC2771ModuleStandalone, ERC2771Context} from "./modules/ERC2771ModuleStandalone.sol";
/* ==== Base contract === */
import {RuleEngineBase} from "./RuleEngineBase.sol";

/**
 * @title Implementation of a ruleEngine as defined by the CMTAT
 */
contract RuleEngine is ERC2771ModuleStandalone, RuleEngineBase {
    /**
     * @param admin Address of the contract (Access Control)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     */
    constructor(address admin, address forwarderIrrevocable, address tokenContract)
        ERC2771ModuleStandalone(forwarderIrrevocable)
    {
        if (admin == address(0)) {
            revert RuleEngine_AdminWithAddressZeroNotAllowed();
        }
        if (tokenContract != address(0)) {
            _bindToken(tokenContract);
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /* ============ ACCESS CONTROL ============ */
    /**
     * @notice Returns `true` if `account` has been granted `role`.
     * @dev The Default Admin has all roles
     */
    function hasRole(bytes32 role, address account) public view virtual override(AccessControl) returns (bool) {
        if (AccessControl.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        } else {
            return AccessControl.hasRole(role, account);
        }
    }

    /* ============ ERC-165 ============ */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, IERC165) returns (bool) {
        return interfaceId == RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID
            || interfaceId == ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID
            || AccessControl.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                           ERC-2771
    //////////////////////////////////////////////////////////////*/
    function _onlyComplianceManager() internal virtual override onlyRole(COMPLIANCE_MANAGER_ROLE) {}
    function _onlyRulesManager() internal virtual override onlyRole(RULES_MANAGEMENT_ROLE) {}

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
