// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
/* ==== Modules === */
import {ERC2771ModuleStandalone, ERC2771Context} from "../modules/ERC2771ModuleStandalone.sol";
import {ERC3643ComplianceRolesStorage} from "../modules/library/ERC3643ComplianceRolesStorage.sol";
import {RulesManagementModuleRolesStorage} from "../modules/library/RulesManagementModuleRolesStorage.sol";
/* ==== Base contract === */
import {RuleEngineBase} from "../RuleEngineBase.sol";

/**
 * @title Implementation of a ruleEngine as defined by the CMTAT
 */
contract RuleEngine is
    ERC2771ModuleStandalone,
    RuleEngineBase,
    AccessControlEnumerable,
    ERC3643ComplianceRolesStorage,
    RulesManagementModuleRolesStorage
{
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Deploys the RBAC RuleEngine.
     * @param admin Address of the contract (Access Control)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     * @param tokenContract Token to bind at deployment, or the zero address to bind none.
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
        // Emit the initial cap so the event log alone is enough to reconstruct maxRules.
        _setMaxRules(DEFAULT_MAX_RULES);
    }

    /* ============ ACCESS CONTROL ============ */
    /**
     * @notice Grants `role` to `account`.
     * @dev Prevents granting any role to accounts currently configured as rules.
     * Note: this check is intentionally one-directional. {addRule} does not verify
     * whether the rule address already holds a privileged role, and this function does
     * not prevent adding a privileged address as a rule afterwards. Operators are
     * responsible for keeping rule contracts and privileged accounts disjoint.
     * @param role The role identifier to grant.
     * @param account The account receiving the role.
     */
    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        if (_rules.contains(account)) {
            revert RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges();
        }
        AccessControl.grantRole(role, account);
    }

    /**
     * @notice Returns `true` if `account` has been granted `role`.
     * @dev The Default Admin has all roles
     * @param role The role identifier to check.
     * @param account The account to check.
     * @return True if the account holds the role (or is the default admin), false otherwise.
     */
    function hasRole(bytes32 role, address account)
        public
        view
        virtual
        override(AccessControl, IAccessControl)
        returns (bool)
    {
        if (AccessControl.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        } else {
            return AccessControl.hasRole(role, account);
        }
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
        override(AccessControlEnumerable, IERC165)
        returns (bool)
    {
        return _supportsRuleEngineBaseInterface(interfaceId) || AccessControlEnumerable.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                           ERC-2771
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Access control check restricting compliance operations to COMPLIANCE_MANAGER_ROLE.
     */
    function _onlyComplianceManager() internal virtual override onlyRole(COMPLIANCE_MANAGER_ROLE) {}

    /**
     * @dev Access control check restricting rule management to RULES_MANAGEMENT_ROLE.
     */
    function _onlyRulesManager() internal virtual override onlyRole(RULES_MANAGEMENT_ROLE) {}

    /**
     * @dev Access control check restricting the rule cap update to DEFAULT_ADMIN_ROLE.
     */
    function _onlyRulesLimitManager() internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {}

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
