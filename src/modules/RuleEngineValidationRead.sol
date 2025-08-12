// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import "OZ/access/AccessControl.sol";

/* ==== Modules === */
import {RuleEngineValidation} from "./RuleEngineValidation.sol";

/* ==== Interface and other library === */
import {IRuleEngineValidationRead} from "../interfaces/IRuleEngineValidation.sol";
import {IRuleValidation} from "../interfaces/IRuleValidation.sol";
import {IERC1404, IERC1404Extend} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";

/**
 * @title RuleEngine - Validation part
 */
abstract contract RuleEngineValidationRead is
    AccessControl,
    RuleEngineValidation,
    IRuleEngineValidationRead
{

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    /**
     * @notice Go through all the rule to know if a restriction exists on the transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
     **/
    function detectTransferRestrictionValidation(
        address from,
        address to,
        uint256 value
    ) public view virtual override returns (uint8) {
        //uint256 rulesLength = _rulesValidation.length();
        uint256 rulesLength = rulesCountValidation();
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRuleValidation(ruleValidation(i))
                .detectTransferRestriction(from, to, value);
            if (restriction > 0) {
                return restriction;
            }
        }

        return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function detectTransferRestrictionValidationFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override returns (uint8) {
        uint256 rulesLength = rulesCountValidation();
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRuleValidation(ruleValidation(i))
                .detectTransferRestrictionFrom(spender, from, to, value);
            if (restriction > 0) {
                return restriction;
            }
        }
        return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Validate a transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     * @return True if the transfer is valid, false otherwise
     **/
    function canTransferValidation(
        address from,
        address to,
        uint256 value
    ) public view virtual returns (bool) {
        return
            detectTransferRestrictionValidation(from, to, value) ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Validate a transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     * @return True if the transfer is valid, false otherwise
     **/
    function canTransferValidationFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override returns (bool) {
        return
            detectTransferRestrictionValidationFrom(spender, from, to, value) ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
    }
}
