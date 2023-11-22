# RuleSanctionList

[TOC]



## SanctionsList

### isSanctioned

```solidity
function isSanctioned(address addr) external view returns (bool)
```

## RuleSanctionList

### sanctionsList

```solidity
contract SanctionsList sanctionsList
```

### constructor

```solidity
constructor(address admin, address forwarderIrrevocable) public
```

#### Parameters

| Name                 | Type    | Description                                                |
| -------------------- | ------- | ---------------------------------------------------------- |
| admin                | address | Address of the contract (Access Control)                   |
| forwarderIrrevocable | address | Address of the forwarder, required for the gasless support |

### setSanctionListOracle

```solidity
function setSanctionListOracle(address sanctionContractOracle_) public
```

Set the oracle contract

_zero address is authorized to authorize all transfers_

#### Parameters

| Name                    | Type    | Description                     |
| ----------------------- | ------- | ------------------------------- |
| sanctionContractOracle_ | address | address of your oracle contract |

### validateTransfer

```solidity
function validateTransfer(address _from, address _to, uint256 _amount) public view returns (bool isValid)
```

Validate a transfer

#### Parameters

| Name    | Type    | Description             |
| ------- | ------- | ----------------------- |
| _from   | address | the origin address      |
| _to     | address | the destination address |
| _amount | uint256 | to transfer             |

#### Return Values

| Name    | Type | Description                                       |
| ------- | ---- | ------------------------------------------------- |
| isValid | bool | => true if the transfer is valid, false otherwise |

### detectTransferRestriction

```solidity
function detectTransferRestriction(address _from, address _to, uint256) public view returns (uint8)
```

Check if an addres is in the whitelist or not

#### Parameters

| Name  | Type    | Description             |
| ----- | ------- | ----------------------- |
| _from | address | the origin address      |
| _to   | address | the destination address |
|       | uint256 |                         |

#### Return Values

| Name | Type  | Description                                           |
| ---- | ----- | ----------------------------------------------------- |
| [0]  | uint8 | The restricion code or REJECTED_CODE_BASE.TRANSFER_OK |

### canReturnTransferRestrictionCode

```solidity
function canReturnTransferRestrictionCode(uint8 _restrictionCode) external pure returns (bool)
```

To know if the restriction code is valid for this rule or not.

#### Parameters

| Name             | Type  | Description                 |
| ---------------- | ----- | --------------------------- |
| _restrictionCode | uint8 | The target restriction code |

#### Return Values

| Name | Type | Description                                            |
| ---- | ---- | ------------------------------------------------------ |
| [0]  | bool | true if the restriction code is known, false otherwise |

### messageForTransferRestriction

```solidity
function messageForTransferRestriction(uint8 _restrictionCode) external pure returns (string)
```

Return the corresponding message

#### Parameters

| Name             | Type  | Description                 |
| ---------------- | ----- | --------------------------- |
| _restrictionCode | uint8 | The target restriction code |

#### Return Values

| Name | Type   | Description                                    |
| ---- | ------ | ---------------------------------------------- |
| [0]  | string | true if the transfer is valid, false otherwise |

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
