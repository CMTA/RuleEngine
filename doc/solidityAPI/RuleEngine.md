# RuleEngine

[TOC]



### RuleEngine_RuleAddressZeroNotAllowed

```solidity
error RuleEngine_RuleAddressZeroNotAllowed()
```

### RuleEngine_RuleAlreadyExists

```solidity
error RuleEngine_RuleAlreadyExists()
```

### RuleEngine_RuleDoNotMatch

```solidity
error RuleEngine_RuleDoNotMatch()
```

### RuleEngine_AdminWithAddressZeroNotAllowed

```solidity
error RuleEngine_AdminWithAddressZeroNotAllowed()
```

### RuleEngine_ArrayIsEmpty

```solidity
error RuleEngine_ArrayIsEmpty()
```

### RULE_ENGINE_ROLE

```solidity
bytes32 RULE_ENGINE_ROLE
```

_Role to manage the ruleEngine_

### _ruleIsPresent

```solidity
mapping(contract IRule => bool) _ruleIsPresent
```

_Indicate if a rule already exists_

### _rules

```solidity
contract IRule[] _rules
```

_Array of rules_

### AddRule

```solidity
event AddRule(contract IRule rule)
```

Generate when a rule is added

### RemoveRule

```solidity
event RemoveRule(contract IRule rule)
```

Generate when a rule is removed

### ClearRules

```solidity
event ClearRules(contract IRule[] rulesRemoved)
```

Generate when all the rules are cleared

### constructor

```solidity
constructor(address admin, address forwarderIrrevocable) public
```

#### Parameters

| Name                 | Type    | Description                                                |
| -------------------- | ------- | ---------------------------------------------------------- |
| admin                | address | Address of the contract (Access Control)                   |
| forwarderIrrevocable | address | Address of the forwarder, required for the gasless support |

### setRules

```solidity
function setRules(contract IRule[] rules_) external
```

Set all the rules, will overwrite all the previous rules. \n
Revert if one rule is a zero address or if the rule is already present

### clearRules

```solidity
function clearRules() public
```

Clear all the rules of the array of rules

### addRule

```solidity
function addRule(contract IRule rule_) public
```

Add a rule to the array of rules
Revert if one rule is a zero address or if the rule is already present

### removeRule

```solidity
function removeRule(contract IRule rule_, uint256 index) public
```

Remove a rule from the array of rules
Revert if the rule found at the specified index does not match the rule in argument

_To reduce the array size, the last rule is moved to the location occupied
by the rule to remove_

#### Parameters

| Name  | Type           | Description                           |
| ----- | -------------- | ------------------------------------- |
| rule_ | contract IRule | address of the target rule            |
| index | uint256        | the position inside the array of rule |

### rulesCount

```solidity
function rulesCount() external view returns (uint256)
```

#### Return Values

| Name | Type    | Description                          |
| ---- | ------- | ------------------------------------ |
| [0]  | uint256 | The number of rules inside the array |

### getRuleIndex

```solidity
function getRuleIndex(contract IRule rule_) external view returns (uint256 index)
```

Get the index of a rule inside the list

#### Return Values

| Name  | Type    | Description                                   |
| ----- | ------- | --------------------------------------------- |
| index | uint256 | if the rule is found, _rules.length otherwise |

### rule

```solidity
function rule(uint256 ruleId) external view returns (contract IRule)
```

Get the rule at the position specified by ruleId

#### Parameters

| Name   | Type    | Description       |
| ------ | ------- | ----------------- |
| ruleId | uint256 | index of the rule |

#### Return Values

| Name | Type           | Description    |
| ---- | -------------- | -------------- |
| [0]  | contract IRule | a rule address |

### rules

```solidity
function rules() external view returns (contract IRule[])
```

Get all the rules

#### Return Values

| Name | Type             | Description       |
| ---- | ---------------- | ----------------- |
| [0]  | contract IRule[] | An array of rules |

### detectTransferRestriction

```solidity
function detectTransferRestriction(address _from, address _to, uint256 _amount) public view returns (uint8)
```

Go through all the rule to know if a restriction exists on the transfer

#### Parameters

| Name    | Type    | Description             |
| ------- | ------- | ----------------------- |
| _from   | address | the origin address      |
| _to     | address | the destination address |
| _amount | uint256 | to transfer             |

#### Return Values

| Name | Type  | Description                                           |
| ---- | ----- | ----------------------------------------------------- |
| [0]  | uint8 | The restricion code or REJECTED_CODE_BASE.TRANSFER_OK |

### validateTransfer

```solidity
function validateTransfer(address _from, address _to, uint256 _amount) public view returns (bool)
```

Validate a transfer

#### Parameters

| Name    | Type    | Description             |
| ------- | ------- | ----------------------- |
| _from   | address | the origin address      |
| _to     | address | the destination address |
| _amount | uint256 | to transfer             |

#### Return Values

| Name | Type | Description                                    |
| ---- | ---- | ---------------------------------------------- |
| [0]  | bool | True if the transfer is valid, false otherwise |

### messageForTransferRestriction

```solidity
function messageForTransferRestriction(uint8 _restrictionCode) external view returns (string)
```

Return the message corresponding to the code

#### Parameters

| Name             | Type  | Description                 |
| ---------------- | ----- | --------------------------- |
| _restrictionCode | uint8 | The target restriction code |

#### Return Values

| Name | Type   | Description                                    |
| ---- | ------ | ---------------------------------------------- |
| [0]  | string | True if the transfer is valid, false otherwise |

### _msgSender

```solidity
function _msgSender() internal view returns (address sender)
```

_This surcharge is not necessary if you do not use the MetaTxModule_

### _msgData

```solidity
function _msgData() internal view returns (bytes)
```

_This surcharge is not necessary if you do not use the MetaTxModule_

## 
