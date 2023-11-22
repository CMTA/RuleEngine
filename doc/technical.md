# Technical choice

[TOC]

## Schema

### UML

![uml](./schema/classDiagram1.0.3.svg)

## Graph

### RuleEngine

![surya_graph_RuleEngine](./schema/surya/surya_graph_RuleEngine.png)

### Whitelist

![surya_graph_Whitelist](./schema/surya/surya_graph_Whitelist.png)

### SanctionList

![surya_graph_Whitelist](./schema/surya/surya_graph_SanctionList.png)

## Access Control

### Admin

### Whitelist 

The default admin is the address put in argument(`admin`) inside the constructor. It is set in the constructor when the contract is deployed.

### RuleEngine

The default admin is the address put in argument(`admin`) inside the constructor. It is set in the constructor when the contract is deployed.

### Schema

Here a schema of the Access Control.

**RuleEngine**
![alt text](./accessControl/access-control-RuleEngine.png)

**RuleWhitelist**
![alt text](./accessControl/access-control-RuleWhitelist.png)



**RuleSanctionList**

![alt text](./accessControl/access-control-RuleSanctionList.drawio.png)

## Functionality

### Upgradeable

The Rule Engine, the Rule Whitelist and the Rule SanctionList contracts are not upgradeable. The reason is the following:
If we need a new on, we just issue a new one, and tell the CMTAT token (or the RuleEngine for the rules) to use the new. This would happen if we need more than just whitelisting, for ex.

### Urgency mechanism
* Pause
  There are no functionalities to put in pause the contracts.

* We have removed the possibility to Kill the contracts,  to destroy the bytecode, from
  the different contracts (RuleEngine and Rule)  for the following reasons:

  * The opcode SELFDESTRUCT which the property of destroying the contract (= deletion of any storage keys or code) will be remove with the Cancun Upgrade, an upgrade of the Ethereum network.

    Therefore, when the Ethereum Network will integrate this upgrade, this functionality will no longer be available.

    See [https://eips.ethereum.org/EIPS/eip-6780](https://eips.ethereum.org/EIPS/eip-6780) & [https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/cancun.md](https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/cancun.md)

  * It was recommended by the audit team

    > Implementing an ability to destroy a contract is a bad practice, as it cause more risks than benefits.


### Gasless support

> The gasless integration was not part of the audit performed by ABDK on the version [1.0.1](https://github.com/CMTA/RuleEngine/releases/tag/1.0.1)

The RuleEngine, the Whitelist and SanctionList contracts support client-side gasless transactions using the [Gas Station Network](https://docs.opengsn.org/#the-problem) (GSN) pattern, the main open standard for transfering fee payment to another account than that of the transaction issuer. The contract uses the OpenZeppelin contract `ERC2771Context`, which allows a contract to get the original client with `_msgSender()` instead of the fee payer given by `msg.sender` .

At deployment, the parameter  `forwarder` inside the contract constructor has to be set  with the defined address of the forwarder. Please note that the forwarder can not be changed after deployment.

Please see the OpenGSN [documentation](https://docs.opengsn.org/contracts/#receiving-a-relayed-call) for more details on what is done to support GSN in the contract.

## RuleEngine

### Duplicate rules

**setRules**

If one rule is already present, the function is reverted

**addRule** 

If one rule is already present, the function is reverted

### Null address

**setRules**

The function is reverted if one rule is the zero address

**addRule** 

The function is reverted if one rule is the zero address

## Whitelist

### Null address
It is possible to add the null address (0x0) to the whitelist. It is a requirement from the CMTAT to be able to mint tokens.

It is not a security problem because OpenZeppelin doesn't authorize the transfer of tokens to the zero address.

### Duplicate address

**addAddress**
If the address already exists, the transaction is reverted to save gas.
**addAddresses**
If one of addresses already exist, there is no change for this address. The transaction remains valid (no revert).

### NonExistent Address
**removeAddress**
If the address does not exist in the whitelist, the transaction is reverted to save gas.
**removeAddresses**
If the address does not exist in the whitelist, there is no change for this address. The transaction remains valid (no revert).

## SanctionList

No special remarks

## Other

### Gas Optimization

Inside a loop, we use `uncheck` to increment to save gas because an array has a length of < 2\**256.
```
 unchecked { ++i; }
```
See [hackmd.io - gas-optimization-loops](https://hackmd.io/@totomanov/gas-optimization-loops) and [https://github.com/ethereum/solidity/issues/10698](https://github.com/ethereum/solidity/issues/10698)
