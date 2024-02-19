//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.0;

import "CMTAT/interfaces/draft-IERC1404/draft-IERC1404Wrapper.sol";

interface IRuleEngineValidation is IERC1404Wrapper {
    /**
     * @dev define the rules, the precedent rules will be overwritten
     */
    function setRulesValidation(address[] calldata rules_) external;

    /**
     * @dev return the number of rules
     */
    function rulesCountValidation() external view returns (uint256);

    /**
     * @dev return the rule at the index specified by ruleId
     */
    function ruleValidation(uint256 ruleId) external view returns (address);

    /**
     * @dev return all the rules
     */
    function rulesValidation() external view returns (address[] memory);
}
