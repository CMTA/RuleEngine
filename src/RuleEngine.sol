// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "CMTAT/interfaces/IRule.sol";
import "CMTAT/interfaces/IRuleEngine.sol";
import "./RuleWhiteList.sol";
import "./AccessControlAbstract.sol";

/**
@title Implementation of a ruleEngine defined by the CMTAT
*/
contract RuleEngine is IRuleEngine, AccessControlAbstract {
    IRule[] internal _rules;

    constructor(RuleWhitelist _ruleWhitelist) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(RULE_ENGINE_ROLE, msg.sender);
        _rules.push(_ruleWhitelist);
    }

    /**
     * @dev revert if one rule is a zero address
     *
     */
    function setRules(
        IRule[] calldata rules_
    ) external override onlyRole(RULE_ENGINE_ROLE) {
        require(rules_.length != 0, "The array is empty");
        for (uint256 i = 0; i < rules_.length; ++i) {
            require(
                address(rules_[i]) != address(0x0),
                "One of the rules is a zero address"
            );
        }
        _rules = rules_;
    }

    /**
     * @dev clear all the rules of the array of rules
     *
     */
    function clearRules() public onlyRole(RULE_ENGINE_ROLE) {
        _rules = new IRule[](0);
    }

    /**
     * @dev Add a rule to the array of rules
     * The address 0 can not be add
     *
     */
    function addRule(IRule rule_) public onlyRole(RULE_ENGINE_ROLE) {
        require(
            address(rule_) != address(0x0),
            "The rule can't be a zero address"
        );
        _rules.push(rule_);
    }

    /**
     * @dev Remove a rule from the array of rules
     * To reduce the array size, the last rule is moved to the location occupied
     * by the rule to remove
     *
     *
     */
    function removeRule(IRule rule_) public onlyRole(RULE_ENGINE_ROLE) {
        for (uint256 i = 0; i < _rules.length; ++i) {
            if (_rules[i] == rule_) {
                if (i != _rules.length - 1) {
                    _rules[i] = _rules[_rules.length - 1];
                }
                _rules.pop();
                break;
            }
        }
    }

    function ruleLength() external view override returns (uint256) {
        return _rules.length;
    }

    function rule(uint256 ruleId) external view override returns (IRule) {
        return _rules[ruleId];
    }

    function rules() external view override returns (IRule[] memory) {
        return _rules;
    }

    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (uint8) {
        for (uint256 i = 0; i < _rules.length; i++) {
            uint8 restriction = _rules[i].detectTransferRestriction(
                _from,
                _to,
                _amount
            );
            if (restriction > 0) {
                return restriction;
            }
        }
        return 0;
    }

    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool) {
        return detectTransferRestriction(_from, _to, _amount) == 0;
    }

    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external view override returns (string memory) {
        for (uint256 i = 0; i < _rules.length; i++) {
            if (_rules[i].canReturnTransferRestrictionCode(_restrictionCode)) {
                return
                    _rules[i].messageForTransferRestriction(_restrictionCode);
            }
        }
        return "Unknown restriction code";
    }

    /**
     * @dev Destroy the contract bytecode
     * Warning: this action is irreversible and very critical
     *
     */
    function kill() public onlyRole(DEFAULT_ADMIN_ROLE) {
        selfdestruct(payable(msg.sender));
    }
}
