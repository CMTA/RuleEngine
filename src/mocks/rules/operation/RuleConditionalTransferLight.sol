// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import {IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {RuleConditionalTransferLightInvariantStorage} from "./abstract/RuleConditionalTransferLightInvariantStorage.sol";
import {IRule} from "../../../interfaces/IRule.sol";

/**
 * @title TransferApprovalRule
 * @dev Requires operator approval for each ERC20 transfer.
 *      Same transfer (from, to, value) can be approved multiple times.
 */
contract RuleConditionalTransferLight is
    AccessControl,
    RuleConditionalTransferLightInvariantStorage,
    IRule
{
    // Mapping from transfer hash to approval count
    mapping(bytes32 => uint256) public approvalCounts;

    constructor(address admin, IRuleEngine ruleEngineContract) {
        require(admin != address(0), "Invalid operator");

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, admin);
        if (address(ruleEngineContract) != address(0x0)) {
            _grantRole(RULE_ENGINE_CONTRACT_ROLE, address(ruleEngineContract));
        }
    }

    /**
     * @notice Approve a specific transfer. Can be approved multiple times.
     */
    function approveTransfer(
        address from,
        address to,
        uint256 value
    ) public onlyRole(OPERATOR_ROLE) {
        bytes32 transferHash = keccak256(abi.encodePacked(from, to, value));
        approvalCounts[transferHash] += 1;
        emit TransferApproved(from, to, value, approvalCounts[transferHash]);
    }

    /**
     * @notice Returns number of times a transfer is approved.
     */
    function approvedCount(
        address from,
        address to,
        uint256 value
    ) public view returns (uint256) {
        bytes32 transferHash = keccak256(abi.encodePacked(from, to, value));
        return approvalCounts[transferHash];
    }

    /**
     * @notice Called when a transfer occurs. Decrements approval count if allowed.
     * @dev `spender` is part of the interface but unused.
     */
    function transferred(address from, address to, uint256 value) public {
        bytes32 transferHash = keccak256(abi.encodePacked(from, to, value));
        uint256 count = approvalCounts[transferHash];

        if (count == 0) revert TransferNotApproved();

        approvalCounts[transferHash] = count - 1;
        emit TransferExecuted(from, to, value, approvalCounts[transferHash]);
    }

    function transferred(
        address /* spender */,
        address from,
        address to,
        uint256 value
    ) public {
        transferred(from, to, value);
    }

    /**
     * @notice Check if the transfer is valid
     * @param from the origin address
     * @param to the destination address
     * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
     **/
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) public view override returns (uint8) {
        bytes32 transferHash = keccak256(abi.encodePacked(from, to, value));
        uint256 count = approvalCounts[transferHash];
        if (count == 0) {
            return CODE_TRANSFER_REQUEST_NOT_APPROVED;
        }
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
    ) public view override returns (uint8) {
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
     * @param restrictionCode The target restriction code
     * @return true if the transfer is valid, false otherwise
     **/
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) external pure override returns (string memory) {
        if (restrictionCode == CODE_TRANSFER_REQUEST_NOT_APPROVED) {
            return TEXT_TRANSFER_REQUEST_NOT_APPROVED;
        } else {
            return TEXT_CODE_NOT_FOUND;
        }
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
    ) public view override returns (bool isValid) {
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
