//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {IRuleEngineERC1404} from "CMTAT/interfaces/engine/IRuleEngine.sol";

/* ==== Interfaces === */

/**
 * @title IRule
 * @notice Interface every rule must implement to be usable by a RuleEngine.
 */
interface IRule is IRuleEngineERC1404 {
    /**
     * @notice Tells whether a restriction code belongs to this rule.
     * @dev Returns true if the restriction code exists, and false otherwise.
     * Rule authors should use unique restriction codes across rules when possible.
     * If a code is intentionally shared by multiple rules, all of them should return
     * the same message for that code in `messageForTransferRestriction`.
     * @param restrictionCode The target restriction code.
     * @return True if the restriction code is known by this rule, false otherwise.
     */
    function canReturnTransferRestrictionCode(uint8 restrictionCode) external view returns (bool);
}
