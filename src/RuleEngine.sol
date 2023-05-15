// SPDX-License-Identifier: MPL-2.0

pragma solidity 0.8.17;

import "CMTAT/interfaces/IRule.sol";
import "CMTAT/interfaces/IRuleEngine.sol";
import "./RuleWhiteList.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

/**
@title Implementation of a ruleEngine defined by the CMTAT
*/
contract RuleEngine is IRuleEngine, AccessControl {
    bytes32 public constant RULE_ENGINE_ROLE = keccak256("RULE_ENGINE_ROLE");
    mapping(IRule => bool) ruleIsPresent;
    IRule[] internal _rules;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(RULE_ENGINE_ROLE, msg.sender);
    }

    /**
     * @dev revert if one rule is a zero address
     *
     */
    function setRules(
        IRule[] calldata rules_
    ) external override onlyRole(RULE_ENGINE_ROLE) {
        require(rules_.length != 0, "The array is empty");
        for (uint256 i = 0; i < rules_.length; ) {
            require(
                address(rules_[i]) != address(0x0),
                "One of the rules is a zero address"
            );
            require(!ruleIsPresent[rules_[i]], "The rule is already present");
            ruleIsPresent[rules_[i]] = true;
            unchecked {
                ++i;
            }
        }
        _rules = rules_;
    }

    /**
     * @notice clear all the rules of the array of rules
     *
     */
    function clearRules() public onlyRole(RULE_ENGINE_ROLE) {
        _rules = new IRule[](0);
    }

    /**
     * @notice Add a rule to the array of rules
     * @dev The address 0 can not be add
     *
     */
    function addRule(IRule rule_) public onlyRole(RULE_ENGINE_ROLE) {
        require(
            address(rule_) != address(0x0),
            "The rule can't be a zero address"
        );
        require(!ruleIsPresent[rule_], "The rule is already present");
        _rules.push(rule_);
        ruleIsPresent[rule_] = true;
    }

    /**
     * @notice Remove a rule from the array of rules
     * @dev To reduce the array size, the last rule is moved to the location occupied
     * by the rule to remove
     *
     *
     */
    function removeRule(IRule rule_) public onlyRole(RULE_ENGINE_ROLE) {
        for (uint256 i = 0; i < _rules.length; ) {
            if (_rules[i] == rule_) {
                if (i != _rules.length - 1) {
                    _rules[i] = _rules[_rules.length - 1];
                }
                _rules.pop();
                ruleIsPresent[rule_] = false;
                break;
            }
            unchecked {
                ++i;
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
        for (uint256 i = 0; i < _rules.length; ) {
            uint8 restriction = _rules[i].detectTransferRestriction(
                _from,
                _to,
                _amount
            );
            if (restriction > 0) {
                return restriction;
            }
            unchecked {
                ++i;
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
        for (uint256 i = 0; i < _rules.length; ) {
            if (_rules[i].canReturnTransferRestrictionCode(_restrictionCode)) {
                return
                    _rules[i].messageForTransferRestriction(_restrictionCode);
            }
            unchecked {
                ++i;
            }
        }
        return "Unknown restriction code";
    }
}
