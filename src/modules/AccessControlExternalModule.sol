// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/extensions/AccessControlDefaultAdminRules.sol)

pragma solidity ^0.8.20;

import {AccessControl} from "../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {AccessControlExternalModuleInternal} from "./AccessControlExternalModuleInternal.sol";

import {SafeCast} from "../../lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol";
import {Math} from "../../lib/openzeppelin-contracts/contracts/utils/math/Math.sol";

import {IERC5313} from "../../lib/openzeppelin-contracts/contracts/interfaces/IERC5313.sol";

/**
 * @dev Extension of {AccessControl} that allows specifying special rules to manage
 * the `DEFAULT_ADMIN_ROLE` holder, which is a sensitive role with special permissions
 * over other roles that may potentially have privileged rights in the system.
 *
 * If a specific role doesn't have an admin role assigned, the holder of the
 * `DEFAULT_ADMIN_ROLE` will have the ability to grant it and revoke it.
 *
 * This contract implements the following risk mitigations on top of {AccessControl}:
 *
 * * Only one account holds the `DEFAULT_ADMIN_ROLE` since deployment until it's potentially renounced.
 * * Enforces a 2-step process to transfer the `DEFAULT_ADMIN_ROLE` to another account.
 * * Enforces a configurable delay between the two steps, with the ability to cancel before the transfer is accepted.
 * * The delay can be changed by scheduling, see {changeDefaultAdminDelay}.
 * * It is not possible to use another role to manage the `DEFAULT_ADMIN_ROLE`.
 *
 * Example usage:
 *
 * ```solidity
 * contract MyToken is AccessControlDefaultAdminRules {
 *   constructor() AccessControlDefaultAdminRules(
 *     3 days,
 *     msg.sender // Explicit initial `DEFAULT_ADMIN_ROLE` holder
 *    ) {}
 * }
 * ```
 */
abstract contract AccessControlExternalModule is AccessControl, AccessControlExternalModuleInternal {
    // pending admin pair read/written together frequently
    address private _pendingDefaultAdmin;
    uint48 private _pendingDefaultAdminSchedule; // 0 == unset

    uint48 private _currentDelay;
    address private _currentDefaultAdmin;

    // pending delay pair read/written together frequently
    uint48 private _pendingDelay;
    uint48 private _pendingDelaySchedule; // 0 == unset

    /// @dev Role to manage the authorization
    bytes32 public constant AUTHORIZATION_ENGINE_ROLE = keccak256("AUTHORIZATION_ENGINE_ROLE");


    /**
    * 
    */
    constructor (
        uint48 initialDelay
    ) AccessControlExternalModuleInternal(initialDelay) {

    }


    ///
    /// Override AccessControl role management
    ///

        ///
    /// AccessControlDefaultAdminRules public and internal setters for defaultAdminDelay/pendingDefaultAdminDelay
    ///

    /**
     * See IAccessControlDefaultAdminRules
     */
    function changeDefaultAdminDelay(uint48 newDelay) public virtual onlyRole(AUTHORIZATION_ENGINE_ROLE) {
        _changeDefaultAdminDelay(newDelay);
    }

        /**
     * See IAccessControlDefaultAdminRules
     */
    function acceptDefaultAdminTransfer() public virtual {
        (address newDefaultAdmin, ) = pendingDefaultAdmin();
        if (_msgSender() != newDefaultAdmin) {
            // Enforce newDefaultAdmin explicit acceptance.
            revert AccessControlInvalidDefaultAdmin(_msgSender());
        }
        _acceptDefaultAdminTransfer();
    }

    /**
     * See IAccessControlDefaultAdminRules
     */
    function cancelDefaultAdminTransfer() public virtual onlyRole(AUTHORIZATION_ENGINE_ROLE) {
        _cancelDefaultAdminTransfer();
    }

    /**
     * See IAccessControlDefaultAdminRules
     */
    function beginDefaultAdminTransfer(address newAdmin) public virtual onlyRole(AUTHORIZATION_ENGINE_ROLE) {
        _beginDefaultAdminTransfer(newAdmin);
    }

    /**
     * See IAccessControlDefaultAdminRules
     */
    function rollbackDefaultAdminDelay() public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _rollbackDefaultAdminDelay();
    }


}