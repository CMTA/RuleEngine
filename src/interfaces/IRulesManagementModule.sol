//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Interfaces === */
import {IRule} from "./IRule.sol";
interface IRulesManagementModule {
    /**
     * @notice Defines the  rules for the rule engine.
     * @dev Sets the list of rule contract addresses for s. 
     *      Any previously set rules will be completely overwritten by the new list.
     *      Rules should be deployed contracts that implement the expected interface.
     * @param rules_ The array of addresses representing the new rules to be set.
     * @dev Revert if one rule is a zero address or if the rule is already present
     */
    function setRules(IRule[] calldata rules_) external;

   /**
     * @notice Returns the total number of currently configured rules.
     * @dev Equivalent to the length of the internal rules array.
     * @return numberOfrules The number of active rules.
     */
    function rulesCount() external view returns (uint256 numberOfrules);

    /**
     * @notice Retrieves the rule address at a specific index.
     * @dev Reverts if `ruleId` is out of bounds.
     * @param ruleId The index of the desired rule in the array.
     * @return ruleAddress The address of the corresponding IRule contract.
     */
    function rule(uint256 ruleId) external view returns (address ruleAddress);

     /**
     * @notice Returns the full list of currently configured rules.
     * @dev This is a view-only function that does not modify state.
     * @return ruleAddresses An array of all active rule contract addresses.
     */
    function rules() external view returns (address[] memory ruleAddresses);


    /**
     * @notice Removes all configured rules.
     * @dev After calling this function, no rules will remain set.
     */
    function clearRules() external;

    /**
     * @notice Adds a new rule to the current rule set.
     * @dev Reverts if the rule address is zero or already exists in the set.
     * @param rule_ The IRule contract to add.
     */
    function addRule(
        IRule rule_
    ) external;



    /**
     * @notice Removes a specific rule from the current rule set.
     * @dev Reverts if the provided rule is not found or does not match the stored rule at its index.
     * @param rule_ The IRule contract to remove.
     */
    function removeRule(
        IRule rule_
    ) external;

   /**
     * @notice Checks whether a specific rule is currently configured.
     * @param rule_ The IRule contract to check for membership.
     * @return exists True if the rule is present, false otherwise.
     */
    function containsRule(IRule rule_) external returns (bool exists);
}
