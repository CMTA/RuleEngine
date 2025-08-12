//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import {IRuleOperation} from "./IRuleOperation.sol";
interface IRuleEngineOperation {
    /**
     * @notice Defines the operation rules for the rule engine.
     * @dev Sets the list of rule contract addresses for operations. 
     *      Any previously set rules will be completely overwritten by the new list.
     *      Rules should be deployed contracts that implement the expected interface.
     * @param rules_ The array of addresses representing the new rules to be set.
     * @dev Revert if one rule is a zero address or if the rule is already present
     */
    function setRulesOperation(IRuleOperation[] calldata rules_) external;

    /**
     * @notice Returns the number of rules currently set for operations.
     * @dev The count corresponds to the total number of elements in the rules array.
     * @return The number of operation rules.
     */
    function rulesCountOperation() external view returns (uint256);

    /**
     * @notice Retrieves the rule address at a specific index.
     * @dev The index corresponds to the position in the rules array.
     *      Reverts if `ruleId` is out of bounds.
     * @param ruleId The index of the rule to retrieve.
     * @return The address of the rule contract.
     */
    function ruleOperation(uint256 ruleId) external view returns (address);

    /**
     * @notice Returns the full list of operation rules.
     * @dev This is a view-only function that returns all the currently stored rule addresses.
     * @return An array containing all the rule contract addresses.
     */
    function rulesOperation() external view returns (address[] memory);


    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function clearRulesOperation() external;

    /**
     * @notice Add a rule to the array of rules
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function addRuleOperation(
        IRuleOperation rule_
    ) external;


    /**
     * @notice Remove a rule from the array of rules
     * Revert if the rule found at the specified index does not match the rule in argument
     * @param rule_ address of the target rule
     * @dev To reduce the array size, the last rule is moved to the location occupied
     * by the rule to remove
     *
     *
     */
    function removeRuleOperation(
        IRuleOperation rule_
    ) external;
}
