//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.27;

/* ==== OpenZeppelin === */
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
/* ==== CMTAT === */
import {IERC1404Extend} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";
import {IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";

/**
 * @title IRule
 * @notice Interface every rule must implement to be usable by a RuleEngine.
 * @dev Declares exactly the functions the engine calls on a rule, plus ERC-165:
 * - `transferred(from, to, value)` from {IERC3643IComplianceContract} and the 4-argument
 *   `transferred(spender, from, to, value)` declared below (state-changing callbacks);
 * - `detectTransferRestriction` and `messageForTransferRestriction` from {IERC1404}, and
 *   `detectTransferRestrictionFrom` from {IERC1404Extend} (views);
 * - `canReturnTransferRestrictionCode`, declared below.
 *
 * It does not require `canTransfer` / `canTransferFrom` (ERC-3643 / ERC-7551 compliance reads): the engine
 * never calls them on a rule, it derives its own answer from `detectTransferRestriction*`. A rule that
 * also wants to be set directly as a token's rule engine (no RuleEngine in between) implements CMTAT's
 * `IRuleEngineERC1404` as well and advertises `RULE_ENGINE_INTERFACE_ID`; that role is opt-in per rule.
 */
interface IRule is IERC1404Extend, IERC3643IComplianceContract, IERC165 {
    /**
     * @notice Applies the rule to an operation that carries a spender: `transferFrom`, and since CMTAT
     * v3.3.0 mint, burn and the minter `batchTransfer`, with the operator as `spender`.
     * @dev Must revert if the operation is not allowed. Same function as CMTAT's
     * `IRuleEngine.transferred(spender, from, to, value)`, declared here so that `IRule` does not inherit
     * the compliance reads of `IRuleEngine`. A zero `value` carries no economic meaning: a stateful rule
     * must treat it as a no-op (see the warning in CMTAT's `IRuleEngine`).
     * @param spender The account that initiated the operation.
     * @param from The origin address, zero on a mint.
     * @param to The destination address, zero on a burn.
     * @param value The number of tokens involved.
     */
    function transferred(address spender, address from, address to, uint256 value) external;

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
