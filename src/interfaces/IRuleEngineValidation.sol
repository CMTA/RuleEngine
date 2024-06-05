//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

interface IRuleEngineValidation {

    /**
     * @dev See ERC-1404
     *
     */
    function detectTransferRestrictionValidation(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (uint8);
    
    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     */
    function validateTransferValidation(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool isValid);
}


interface IRuleEngineValidationCommon {
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
