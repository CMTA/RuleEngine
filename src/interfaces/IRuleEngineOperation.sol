//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.0;


interface IRuleEngineOperation{
    /**
     * @dev define the rules, the precedent rules will be overwritten
     */
    function setRulesOperation(address[] calldata rules_) external;

    /**
     * @dev return the number of rules
     */
    function rulesOperationCount() external view returns (uint256);

    /**
     * @dev return the rule at the index specified by ruleId
     */
    function ruleOperation(uint256 ruleId) external view returns (address);

    /**
     * @dev return all the rules
     */
    function rulesOperation() external view returns (address[] memory);

}
