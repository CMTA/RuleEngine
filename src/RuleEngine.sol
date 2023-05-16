// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "CMTAT/mocks/RuleEngine/interfaces/IRule.sol";
import "CMTAT/mocks/RuleEngine/interfaces/IRuleEngine.sol";
import "./RuleWhiteList.sol";
import "./modules/MetaTxModuleStandalone.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

/**
@title Implementation of a ruleEngine defined by the CMTAT
*/
contract RuleEngine is IRuleEngine, AccessControl, MetaTxModuleStandalone {
    bytes32 public constant RULE_ENGINE_ROLE = keccak256("RULE_ENGINE_ROLE");
    mapping(IRule => bool) ruleIsPresent;
    IRule[] internal _rules;
    event AddRule(IRule indexed rule);
    event RemoveRule(IRule indexed rule);
    event ClearRules(IRule[] rulesRemoved);

    constructor(address admin, address forwarderIrrevocable) MetaTxModuleStandalone(forwarderIrrevocable) {
        require(admin != address(0), "Address 0 not allowed");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RULE_ENGINE_ROLE, admin);
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
            emit AddRule(rules_[i]);
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
        emit ClearRules(_rules);
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
        emit AddRule(rule_);
    }



    /**
     * @notice Remove a rule from the array of rules
     * @dev To reduce the array size, the last rule is moved to the location occupied
     * by the rule to remove
     *
     *
     */
    function removeRule(IRule rule_, uint256 index) public onlyRole(RULE_ENGINE_ROLE) {
        require(_rules[index] == rule_, "The rule don't match");
        if (index != _rules.length - 1) {
            _rules[index] = _rules[_rules.length - 1];
        }
        _rules.pop(); 
        ruleIsPresent[rule_] = false;
        emit RemoveRule(rule_);      
    }

    function rulesCount() external view override returns (uint256) {
        return _rules.length;
    }

    /*
    @notice Get the index of a rule inside the list
    @return index if the rule is found, _rules.length otherwise
    */
    function getRuleIndex(IRule rule_) external view returns (uint256 index) {
        for (index = 0; index < _rules.length; ) {
            if (_rules[index] == rule_) {
                return index;
            }
            unchecked {
                ++index;
            }
        }
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

    /** 
    @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgSender()
        internal
        view
        override(MetaTxModuleStandalone, Context)
        returns (address sender)
    {
        return MetaTxModuleStandalone._msgSender();
    }

    /** 
    @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgData()
        internal
        view
        override(MetaTxModuleStandalone, Context)
        returns (bytes calldata)
    {
        return MetaTxModuleStandalone._msgData();
    }
}
