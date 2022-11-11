// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "CMTAT/interfaces/IRule.sol";
import "CMTAT/interfaces/IRuleEngine.sol";
import "./RuleWhiteList.sol";
import "./AccessControlAbstract.sol";

contract RuleEngine is IRuleEngine, AccessControlAbstract {
  IRule[] internal _rules;

  constructor(RuleWhitelist _ruleWhitelist ) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(RULE_ENGINE_ROLE, msg.sender);
    _rules.push( _ruleWhitelist);
  }

  function setRules(IRule[] calldata rules_) onlyRole(RULE_ENGINE_ROLE) external override {
    require(rules_.length != 0, "The array is empty");
    _rules = rules_;
  }

  function clearRules() onlyRole(RULE_ENGINE_ROLE) external{
    _rules = new IRule[](0);
  }

  function addRule(IRule rule_) onlyRole(RULE_ENGINE_ROLE) public{
    _rules.push(rule_);
  }

  function removeRule(IRule rule_) onlyRole(RULE_ENGINE_ROLE) public{
    for (uint256 i = 0; i < _rules.length; ++i) {
      if(_rules[i] == rule_){
        if(i != _rules.length - 1){
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

  function rules() external view override returns(IRule[] memory) {
    return _rules;
  }

  function detectTransferRestriction(
    address _from,
    address _to,
    uint256 _amount)
  public view override returns (uint8)
  {
    for (uint256 i = 0; i < _rules.length; i++) {
      uint8 restriction = _rules[i].detectTransferRestriction(_from, _to, _amount);
      if (restriction > 0) {
        return restriction;
      }
    }
    return 0;
  }

  function validateTransfer(
    address _from,
    address _to,
    uint256 _amount)
  public view override returns (bool)
  {
    return detectTransferRestriction(_from, _to, _amount) == 0;
  }

  function messageForTransferRestriction(uint8 _restrictionCode) public view override returns (string memory) {
    for (uint256 i = 0; i < _rules.length; i++) {
      if (_rules[i].canReturnTransferRestrictionCode(_restrictionCode)) {
        return _rules[i].messageForTransferRestriction(_restrictionCode);
      }
    }
    return "Unknown restriction code";
  }

  function kill() public onlyRole(DEFAULT_ADMIN_ROLE) {
        selfdestruct(payable(msg.sender));
  }
 
}
