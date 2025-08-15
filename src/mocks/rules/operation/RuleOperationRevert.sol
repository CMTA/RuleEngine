// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "../validation/abstract/RuleCommonInvariantStorage.sol";
import {IRule} from "../../../interfaces/IRule.sol";

/**
 * @title TransferApprovalRule
 * @dev Requires operator approval for each ERC20 transfer.
 *      Same transfer (from, to, value) can be approved multiple times.
 */
contract RuleOperationRevert is
    AccessControl,
    IRule,
    RuleCommonInvariantStorage
{
    error RuleConditionalTransferLight_InvalidTransfer();
    // It is very important that each rule uses an unique code
    uint8 public constant CODE_TRANSFER_REQUEST_NOT_APPROVED = 71;

    /**
     * @notice Called when a transfer occurs. Decrements approval count if allowed.
     * @dev `spender` is part of the interface but unused.
     */
    function transferred(
        address /*from*/,
        address /* to */,
        uint256 /* value */
    ) public pure {
        revert RuleConditionalTransferLight_InvalidTransfer();
    }

    function transferred(
        address /* spender */,
        address /*from*/,
        address /* to */,
        uint256 /* value */
    ) public pure {
        revert RuleConditionalTransferLight_InvalidTransfer();
    }

    /**
     * @notice Check if the transfer is valid
     * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
     **/
    function detectTransferRestriction(
        address /* from */,
        address /* to */,
        uint256 /* value */
    ) public pure override returns (uint8) {
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Check if the transfer is valid
     * @param from the origin address
     * @param to the destination address
     * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
     **/
    function detectTransferRestrictionFrom(
        address /* spender*/,
        address from,
        address to,
        uint256 value
    ) public pure override returns (uint8) {
        return detectTransferRestriction(from, to, value);
    }

    /**
     * @notice To know if the restriction code is valid for this rule or not.
     * @param restrictionCode The target restriction code
     * @return true if the restriction code is known, false otherwise
     **/
    function canReturnTransferRestrictionCode(
        uint8 restrictionCode
    ) external pure override returns (bool) {
        return restrictionCode == CODE_TRANSFER_REQUEST_NOT_APPROVED;
    }

    /**
     * @notice Return the corresponding message
     * @return true if the transfer is valid, false otherwise
     **/
    function messageForTransferRestriction(
        uint8 /* restrictionCode */
    ) external pure override returns (string memory) {
        return TEXT_CODE_NOT_FOUND;
    }

    /**
     * @notice Validate a transfer
     * @param _from the origin address
     * @param _to the destination address
     * @param _amount to transfer
     * @return isValid => true if the transfer is valid, false otherwise
     **/
    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public pure override returns (bool isValid) {
        return
            detectTransferRestriction(_from, _to, _amount) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override returns (bool) {
        return
            detectTransferRestrictionFrom(spender, from, to, value) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }
}
