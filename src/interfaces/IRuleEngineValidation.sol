//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRuleValidation} from "./IRuleValidation.sol";
interface IRuleEngineValidationRead {
    /**
     * @dev See ERC-1404
     *
     */
    function detectTransferRestrictionValidation(
        address from,
        address to,
        uint256 value
    ) external view returns (uint8);

    function detectTransferRestrictionValidationFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) external view returns (uint8);

    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     */
    function canTransferValidationFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) external view returns (bool isValid);
}

interface IRuleEngineValidation {
    /**
     * @dev define the rules, the precedent rules will be overwritten
     */
    function setRulesValidation(IRuleValidation[] calldata rules_) external;

   /**
     * @return The number of rules inside the array
     */
    function rulesCountValidation() external view returns (uint256);

   /**
     * @notice Get the rule at the position specified by ruleId
     * @param ruleId index of the rule
     * @return a rule address
     */
    function ruleValidation(uint256 ruleId) external view returns (address);

    /**
     * @notice Get all the rules
     * @return An array of rules
     */
    function rulesValidation() external view returns (address[] memory);

    /**
     * @notice Remove a rule from the array of rules
     * Revert if the rule found at the specified index does not match the rule in argument
     * @param rule_ address of the target rule
     * @dev To reduce the array size, the last rule is moved to the location occupied
     * by the rule to remove
     *
     *
     */
    function removeRuleValidation(
        IRuleValidation rule_
    ) external;

    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function clearRulesValidation() external;

    /**
     * @notice Add a rule to the array of rules
     * @dev Revert if one rule is a zero address or if the rule is already present
     *
     */
    function addRuleValidation(
        IRuleValidation rule_
    ) external;

    /**
     * @notice Check if a rule is present
     *
     */
    function rulesValidationIsPresent(IRuleValidation rule_) external returns (bool);
}
