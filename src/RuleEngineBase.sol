// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {AccessControl} from "OZ/access/AccessControl.sol";
import {Context} from "OZ/utils/Context.sol";
/* ==== CMTAT === */
import {IRuleEngine}from "CMTAT/interfaces/engine/IRuleEngine.sol";
/* ==== Modules === */
import {ERC3643Compliance, IERC3643Compliance} from "./modules/ERC3643Compliance.sol";
import {RuleEngineBaseModule} from "./modules/RuleEngineBaseModule.sol";
import {RuleEngineOperation} from "./modules/RuleEngineOperation.sol";
import {RuleEngineValidationRead, RuleEngineValidation} from "./modules/RuleEngineValidationRead.sol";

/* ==== Interface and other library === */
import {IRuleValidation} from "./interfaces/IRuleValidation.sol";
import {RuleEngineInvariantStorage} from "./modules/library/RuleEngineInvariantStorage.sol";
/**
 * @title Implementation of a ruleEngine as defined by the CMTAT
 */
abstract contract RuleEngineBase is
    RuleEngineBaseModule,
    RuleEngineOperation,
    RuleEngineValidationRead,
    ERC3643Compliance,
    RuleEngineInvariantStorage,   
    IRuleEngine
{
    /* ============ State functions ============ */
    /*
     * @notice function protected by access control
     */
    function transferred(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual override onlyBoundToken {
        // Validate transfer
        require(RuleEngineValidationRead.canTransferValidationFrom(spender, from, to, value), RuleEngine_InvalidTransfer(from, to, value));
        
        // Apply operation on RuleEngine
        RuleEngineOperation._transferred(from, to, value);
    }
    /**
    * @dev ERC-3643 function transferred
    */
    function transferred(
        address from,
        address to,
        uint256 value
    ) public virtual override onlyBoundToken {
       _transferred(from, to, value);
    }

    /// @inheritdoc IERC3643Compliance
    function created(address to, uint256 value) public virtual override onlyBoundToken{
       _transferred(address(0), to, value);
    }

    /// @inheritdoc IERC3643Compliance
    function destroyed(address from, uint256 value) public virtual override onlyBoundToken {
        _transferred(from, address(0), value);
    }



    /* ============ View functions ============ */
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
    ) public view virtual override returns (uint8) {
        // Validation
        uint8 code = RuleEngineValidationRead.detectTransferRestrictionValidation(
            from,
            to,
            value
        );
        if (code != uint8(REJECTED_CODE_BASE.TRANSFER_OK)) {
            return code;
        }

        // Operation
        uint256 rulesLength =  rulesCountOperation();
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRuleValidation(ruleOperation(i))
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
    ) public view virtual override returns (uint8) {
        // Validation
        uint8 code = RuleEngineValidationRead.detectTransferRestrictionValidationFrom(spender,
            from,
            to,
            value
        );
        if (code != uint8(REJECTED_CODE_BASE.TRANSFER_OK)) {
            return code;
        }

        // Operation
        uint256 rulesLength =  rulesCountOperation();
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRuleValidation(ruleOperation(i))
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
    ) public virtual view override returns (bool) {
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
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual view override returns (bool) {
        return
            detectTransferRestrictionFrom(spender, from, to, value) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Return the message corresponding to the code
     * @param restrictionCode The target restriction code
     * @return True if the transfer is valid, false otherwise
     **/
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) public virtual view override returns (string memory) {
        // Validation
        uint256 rulesLength = rulesCountValidation();
        for (uint256 i = 0; i < rulesLength; ++i) {
            if (
                IRuleValidation(ruleValidation(i))
                    .canReturnTransferRestrictionCode(restrictionCode)
            ) {
                return
                    IRuleValidation(ruleValidation(i))
                        .messageForTransferRestriction(restrictionCode);
            }
        }
        // operation
        rulesLength =  rulesCountOperation();
        for (uint256 i = 0; i < rulesLength; ++i) {
            if (
                IRuleValidation(ruleOperation(i))
                    .canReturnTransferRestrictionCode(restrictionCode)
            ) {
                return
                    IRuleValidation(ruleOperation(i))
                        .messageForTransferRestriction(restrictionCode);
            }
        }
        return "Unknown restriction code";
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
        } else {
            return AccessControl.hasRole(role, account);
        }
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Go through all the rule to know if a restriction exists on the transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     **/
    function _transferred(
        address from,
        address to,
        uint256 value
    ) internal virtual override(RuleEngineOperation){
         // Validate transfer
        require(RuleEngineValidationRead.canTransferValidation(from, to, value),RuleEngine_InvalidTransfer(from, to, value));
        
        // Apply operation on RuleEngine
        RuleEngineOperation._transferred(from, to, value);
    }
}
