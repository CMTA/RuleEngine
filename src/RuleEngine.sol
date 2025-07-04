// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "CMTAT/interfaces/engine/IRuleEngine.sol";
import "./modules/MetaTxModuleStandalone.sol";
import "./modules/RuleEngineOperation.sol";
import {RuleEngineValidation} from "./modules/RuleEngineValidation.sol";
import {IRuleValidation} from "./interfaces/IRuleValidation.sol";
/**
 * @title Implementation of a ruleEngine as defined by the CMTAT
 */
contract RuleEngine is
    IRuleEngine,
    RuleEngineOperation,
    RuleEngineValidation,
    MetaTxModuleStandalone
{
    
    /**
     * @notice
     * Get the current version of the smart contract
     */
    string public constant VERSION = "2.0.5";

    /**
     * @param admin Address of the contract (Access Control)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     */
    constructor(
        address admin,
        address forwarderIrrevocable,
        address tokenContract
    ) MetaTxModuleStandalone(forwarderIrrevocable) {
        if (admin == address(0)) {
            revert RuleEngine_AdminWithAddressZeroNotAllowed();
        }
        if (tokenContract != address(0)) {
            _grantRole(TOKEN_CONTRACT_ROLE, tokenContract);
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /**
     * @notice Go through all the rule to know if a restriction exists on the transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
     **/
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) public view override returns (uint8) {
        // Validation
        uint8 code = RuleEngineValidation.detectTransferRestrictionValidation(
            from,
            to,
            value
        );
        if (code != uint8(REJECTED_CODE_BASE.TRANSFER_OK)) {
            return code;
        }

        // Operation
        uint256 rulesLength = _rulesOperation.length;
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRuleValidation(_rulesOperation[i])
                .detectTransferRestriction(from, to, value);
            if (restriction > 0) {
                return restriction;
            }
        }

        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function detectTransferRestrictionFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view override returns (uint8) {
        // Validation
        uint8 code = RuleEngineValidation.detectTransferRestrictionValidationFrom(spender,
            from,
            to,
            value
        );
        if (code != uint8(REJECTED_CODE_BASE.TRANSFER_OK)) {
            return code;
        }

        // Operation
        uint256 rulesLength = _rulesOperation.length;
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRuleValidation(_rulesOperation[i])
                .detectTransferRestrictionFrom(spender,from, to, value);
            if (restriction > 0) {
                return restriction;
            }
        }

        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Validate a transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     * @return True if the transfer is valid, false otherwise
     **/
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view override returns (bool) {
        return
            detectTransferRestriction(from, to, value) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

       /**
     * @notice Validate a transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     * @return True if the transfer is valid, false otherwise
     **/
    function canTransferFrom(
        address /*spender*/,
        address from,
        address to,
        uint256 value
    ) public view override returns (bool) {
        return
            detectTransferRestriction(from, to, value) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Return the message corresponding to the code
     * @param _restrictionCode The target restriction code
     * @return True if the transfer is valid, false otherwise
     **/
    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external view override returns (string memory) {
        // Validation
        uint256 rulesLength = _rulesValidation.length;
        for (uint256 i = 0; i < rulesLength; ++i) {
            if (
                IRuleValidation(_rulesValidation[i])
                    .canReturnTransferRestrictionCode(_restrictionCode)
            ) {
                return
                    IRuleValidation(_rulesValidation[i])
                        .messageForTransferRestriction(_restrictionCode);
            }
        }
        // operation
        rulesLength = _rulesOperation.length;
        for (uint256 i = 0; i < rulesLength; ++i) {
            if (
                IRuleValidation(_rulesOperation[i])
                    .canReturnTransferRestrictionCode(_restrictionCode)
            ) {
                return
                    IRuleValidation(_rulesOperation[i])
                        .messageForTransferRestriction(_restrictionCode);
            }
        }
        return "Unknown restriction code";
    }

    /*
     * @notice function protected by access control
     */
    function transferred(
        address spender,
        address from,
        address to,
        uint256 amount
    ) external override onlyRole(TOKEN_CONTRACT_ROLE) {
        // Validate transfer
        require(RuleEngineValidation.canTransferValidation(from, to, amount),RuleEngine_InvalidTransfer(from, to, amount));
        
        // Apply operation on RuleEngine
        require(RuleEngineOperation._operateOnTransfer(from, to, amount),RuleEngine_InvalidTransfer(from, to, amount));
    }

    function transferred(
        address from,
        address to,
        uint256 amount
    ) external override onlyRole(TOKEN_CONTRACT_ROLE) {
        // Validate transfer
        require(RuleEngineValidation.canTransferValidation(from, to, amount),RuleEngine_InvalidTransfer(from, to, amount));
        
        // Apply operation on RuleEngine
        require(RuleEngineOperation._operateOnTransfer(from, to, amount),RuleEngine_InvalidTransfer(from, to, amount));
    }

    /* ============ ACCESS CONTROL ============ */
    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControl) returns (bool) {
        // The Default Admin has all roles
        if (AccessControl.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        }
        return AccessControl.hasRole(role, account);
    }

    /*//////////////////////////////////////////////////////////////
                           ERC-2771
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgSender()
        internal
        view
        override(ERC2771Context, Context)
        returns (address sender)
    {
        return ERC2771Context._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgData()
        internal
        view
        override(ERC2771Context, Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _contextSuffixLength()
        internal
        view
        override(ERC2771Context, Context)
        returns (uint256)
    {
        return ERC2771Context._contextSuffixLength();
    }
}
