// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "./RuleInternal.sol";
import "./RuleEngineValidationCommon.sol";
import "../interfaces/IRuleEngineValidation.sol";
import "../interfaces/IRuleValidation.sol";
import "CMTAT/interfaces/tokenization/draft-IERC1404.sol";

/**
 * @title Implementation of a ruleEngine defined by the CMTAT
 */
abstract contract RuleEngineValidation is
    AccessControl,
    RuleInternal,
    RuleEngineValidationCommon,
    IRuleEngineValidation
{
    /**
     * @notice Go through all the rule to know if a restriction exists on the transfer
     * @param _from the origin address
     * @param _to the destination address
     * @param _amount to transfer
     * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
     **/
    function detectTransferRestrictionValidation(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (uint8) {
        uint256 rulesLength = _rulesValidation.length;
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRuleValidation(_rulesValidation[i])
                .detectTransferRestriction(_from, _to, _amount);
            if (restriction > 0) {
                return restriction;
            }
        }

        return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function detectTransferRestrictionValidationFrom(
        address spender,
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (uint8) {
        uint256 rulesLength = _rulesValidation.length;
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRuleValidation(_rulesValidation[i])
                .detectTransferRestrictionFrom(spender, _from, _to, _amount);
            if (restriction > 0) {
                return restriction;
            }
        }
        return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Validate a transfer
     * @param _from the origin address
     * @param _to the destination address
     * @param _amount to transfer
     * @return True if the transfer is valid, false otherwise
     **/
    function canTransferValidation(
        address _from,
        address _to,
        uint256 _amount
    ) public view returns (bool) {
        return
            detectTransferRestrictionValidation(_from, _to, _amount) ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Validate a transfer
     * @param _from the origin address
     * @param _to the destination address
     * @param _amount to transfer
     * @return True if the transfer is valid, false otherwise
     **/
    function canTransferValidationFrom(
        address spender,
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool) {
        return
            detectTransferRestrictionValidationFrom(spender, _from, _to, _amount) ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
    }
}
