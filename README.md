> This project has not undergone an audit and is provided as-is without any warranties.

# RuleEngine

This repository includes the RuleEngine contracts for [CMTAT](https://github.com/CMTA/CMTAT) and [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643) tokens.

The RuleEngine is an external contract used to apply transfer restrictions to another contract, such as CMTAT and ERC-3643 tokens. Acting as a controller, it can call different contract rules and apply these rules on each transfer.

[TOC]

## Contract Variants

Three deployable contracts are available:

| Contract | Access Control | Interface | Use Case |
|----------|---------------|-----------|----------|
| `RuleEngine` | Role-Based (AccessControlEnumerable) | RBAC roles | Multi-operator environments with granular permissions |
| `RuleEngineOwnable` | ERC-173 Ownership | `Ownable` | Single-owner setups, simpler administration |
| `RuleEngineOwnable2Step` | ERC-173 Ownership (two-step transfer) | `Ownable2Step` | Single-owner setups with safer ownership handover |

ERC-3643 compliance specification indicates the use of ERC-173.

> The standard relies on ERC-173 to define contract ownership, with the owner having the responsibility of setting the Compliance parameters and binding the Compliance to a Token contract.

All deployable contracts share the same core functionality (`RuleEngineBase`, directly or through `RuleEngineOwnableShared`) and support:

- ERC-1404 transfer restrictions
- ERC-3643 compliance interface
- ERC-2771 meta-transactions (gasless)
- Multiple token bindings

> **Warning (shared engine across multiple tokens):** A "multi-tenant" setup here means one RuleEngine instance is shared by several token contracts (all bound through `bindToken`). In this setup, tokens must be equally trusted and governed together. ERC-3643 callbacks (`transferred`, `created`, `destroyed`) do not pass the token address to rules, so stateful/accounting rules are not safe for mutually untrusted tokens sharing the same engine.

## Motivation

- Why use a dedicated contract with rules instead of implementing it directly in CMTAT or [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643) tokens?

There are several reasons to do this:

- Flexibility: These different features are not standard and common to all tokens. From an implementation perspective, using a rule engine with custom rules allows for each issuer or contract user to decide which rules to apply.

- Code efficiency: The CMTAT token (and generally also all ERC-3643 tokens) is currently "heavy," meaning its contract code size is close to the maximum limit. This makes it challenging to add new features directly inside the token contract.

- Reusability: 

  - The RuleEngine can be used inside other contracts besides CMTAT. For instance, the RuleEngine has been used in [our contract to distribute dividends](https://www.taurushq.com/blog/equity-tokenization-how-to-pay-dividend-on-chain-using-cmtat/). 

  - A same deployed `RuleEngine` can also be used with several different tokens if the rules allow it, which is the case for all read-only rules.

Why use this `RuleEngine` contract instead of setting the `rule` directly in the token contract?

- Using a RuleEngine allows to call several different rules. For example, a blacklist rule to allow the issuer to manage its own list of blacklisted addresses and a sanctionlist rule to use the [Chainalysis oracle for sanctions screening](https://go.chainalysis.com/chainalysis-oracle-docs.html) to forbid transfers from addresses listed in sanctions designations published by organizations such as the US, EU, or UN.

When may the use of `RuleEngine` not be appropriate?

- If you plan to call only one rule (e.g a whitelist rule), it could make sense to directly set the rule in the token contract instead of using a RuleEngine. This will simplify configuration and reduce runtime gas costs.

## How it works

This diagram illustrates how a transfer with a CMTAT or ERC-3643 token with a RuleEngine works:

![RuleEngine.drawio](./doc/schema/RuleEngine.drawio.png)

 

1. The token holders initiate a transfer transaction on the token contract.
2. The transfer function inside the token calls the ERC-3643 function `transferred` from the RuleEngine with the following parameters inside: `from, to, value`.
3. The Rule Engine calls each rule separately. If the transfer is not authorized by the rule, the rule must directly revert (no return value).

> **Warning:** The RuleEngine iterates over all configured rules on every transfer (and on every call to `detectTransferRestriction`, `canTransfer`, etc.). Adding a large number of rules increases gas consumption for each transfer and may eventually exceed the block gas limit, effectively preventing any transfer from succeeding. An on-chain rule cap is enforced (`maxRules`), set to `10` by default, and can be changed by governance (`DEFAULT_ADMIN_ROLE` on `RuleEngine`, owner on ownable variants). A misconfigured or gas-heavy rule can still impact all transfers.

> **Warning (restriction code conventions):** Rule implementations should use unique ERC-1404 restriction codes across the rule set. If several rules intentionally share the same restriction code, they should return the exact same `messageForTransferRestriction` text for that code to avoid inconsistent operator/user feedback.

### How to set it

#### Compatibility

| RuleEngine version                                           | Compatible Versions                                          |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| **v3.0.0-rc3**                                               | CMTAT ≥ v3.0.0<br />CMTAT target version: [v3.2.0](https://github.com/CMTA/CMTAT/releases/tag/v3.2.0) |
| **v3.0.0-rc2**                                               | CMTAT ≥ v3.0.0<br />CMTAT target version: [v3.2.0](https://github.com/CMTA/CMTAT/releases/tag/v3.2.0) |
| **v3.0.0-rc1**                                               | CMTAT ≥ v3.0.0<br />CMTAT target version: [v3.2.0](https://github.com/CMTA/CMTAT/releases/tag/v3.2.0) |
| **v3.0.0-rc0**                                               | CMTAT ≥ v3.0.0<br />                                         |
| **[v1.0.2.1](https://github.com/CMTA/RuleEngine/releases/tag/v1.0.2.1)** | CMTAT v2.3.0 (audited)                                       |

#### CMTAT v3.0.0

CMTAT provides the following function to set a RuleEngine inside a CMTAT token:

```solidity
setRuleEngine(IRuleEngine ruleEngine_) 
```

This function is defined in the extension module `ValidationModuleRuleEngine`

#### ERC-3643 token

[ERC-3643](https://eips.ethereum.org/EIPS/eip-3643) defined the following function in the standard interface to set a compliance contract

```solidity
setCompliance(address _compliance)
```



## How to include it

While the RuleEngine has been designed for CMTAT and ERC-3643 tokens, it can be used with other contracts to apply transfer restrictions.

For that, the only thing to do is to import in your contract the interface `IRuleEngine`(CMTAT) or `IERC3643Compliance` (ERC-3643), which declares the corresponding functions to call by the token contract. This interface can be found [here](https://github.com/CMTA/CMTAT/blob/23a1e59f913d079d0c09d32fafbd95ab2d426093/contracts/interfaces/engine/IRuleEngine.sol).

### Like CMTAT

Before each ERC-20 transfer, the CMTAT calls the function `transferred` which is the entrypoint for the RuleEngine.

```solidity
function transferred(address from,address to,uint256 value)
```

If you want to apply restrictions on the spender address, you have to call the `transferred` function which takes the spender argument in your ERC-20  function `transferFrom`.

```solidity
function transferred(address spender,address from,address to,uint256 value)
```

For example, CMTAT defines the interaction with the RuleEngine inside a specific module, [ValidationModuleRuleEngine](https://github.com/CMTA/CMTAT/blob/master/contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol) and [CMTATBaseRuleEngine](https://github.com/CMTA/CMTAT/blob/master/contracts/modules/1_CMTATBaseRuleEngine.sol).

- ValidationModuleRuleEngine

![transferred](./doc/other/CMTAT/transferred.png)

- CMTATBaseRuleEngine

![checkTransferred](./doc/other/CMTAT/checkTransferred.png)

This function `_transferred` is called before each transfer/burn/mint through the internal function `_checkTransferred` defined in [CMTAT_BASE](https://github.com/CMTA/CMTAT/blob/23a1e59f913d079d0c09d32fafbd95ab2d426093/contracts/modules/CMTAT_BASE.sol#L198).

### Like ERC-3643

The ERC-3643 defines several functions used as entrypoints for an ERC-3643 token.

As for CMTAT, the main entrypoint is `transferred` which must be called for each ERC-20 transfer.

Contrary to CMTAT, ERC-3643 does not apply restriction on the spender address (`transferFrom`).

They are the following:

```solidity
// read-only function
function canTransfer(address from, address to, uint256 value) external view returns (bool);
// ERC-20 transfer
function transferred(address from, address to, uint256 value) external;
// mint
function created(address to, uint256 value) external;
// burn
function destroyed(address from, uint256 value) external;
```

## Interface

### CMTAT

The `RuleEngine` base interface is defined in the CMTAT repository.

![cmtat_surya_inheritance_IRuleEngine.sol](./doc/schema/cmtat_surya_inheritance_IRuleEngine.sol.png)

It inherits from several others interfaces: `IERC1404`, `IERC1404Extend`, `IERC7551Compliance`, `IERC3643ComplianceContract`

```solidity
// IRuleEngine
function transferred(address spender, address from, address to, uint256 value) 
external;

// IERC-1404
function detectTransferRestriction(address from,address to,uint256 value) 
external view returns (uint8);

function messageForTransferRestriction(uint8 restrictionCode) 
external view returns (string memory);
    
// IERC-1404Extend    
enum REJECTED_CODE_BASE {
        TRANSFER_OK,
        TRANSFER_REJECTED_DEACTIVATED,
        TRANSFER_REJECTED_PAUSED,
        TRANSFER_REJECTED_FROM_FROZEN,
        TRANSFER_REJECTED_TO_FROZEN,
        TRANSFER_REJECTED_SPENDER_FROZEN,
        TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE
    }

function detectTransferRestrictionFrom(address spender,address from,address to,uint256 value) 
external view returns (uint8);
   
 
// IERC7551Compliance
function canTransferFrom(address spender,address from,address to,uint256 value)
external view returns (bool);


// IER3643ComplianceRead
function canTransfer(address from,address to,uint256 value) 
external view returns (bool isValid);

// IERC3643IComplianceContract
function transferred(address from, address to, uint256 value) 
external;
```

> Note: `IERC7551Compliance` comes from `draft-IERC7551` (not final) and, in this project, is used as a subset compliance interface focused on `canTransferFrom`.



### ERC-3643

The [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643) compliance interface is defined in [IERC3643Compliance.sol](src/interfaces/IERC3643Compliance.sol).

A specific module implements this interface for the RuleEngine: [ERC3643ComplianceModule.sol](src/modules/ERC3643ComplianceModule.sol)

![ERC3643ComplianceModuleUML](./doc/schema/vscode-uml/ERC3643ComplianceModuleUML.png)

## Technical

### Dependencies

The toolchain includes the following components, where the versions are the latest ones that we tested:

- Foundry (forge-std) [v1.14.0](https://github.com/foundry-rs/forge-std/releases/tag/v1.14.0)
- Solidity [0.8.34](https://docs.soliditylang.org/en/v0.8.34/)
- OpenZeppelin Contracts (submodule) [v5.6.1](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.6.1)
- CMTAT [v3.2.0](https://github.com/CMTA/CMTAT/releases/tag/v3.2.0)

### Access Control

Two access control mechanisms are available depending on which contract you deploy:

#### RuleEngine (RBAC - AccessControlEnumerable)

The `RuleEngine` contract uses Role-Based Access Control (RBAC) via OpenZeppelin's `AccessControlEnumerable`.

Each module defines the roles useful to restrict its functions. The contract overrides the OpenZeppelin function `hasRole` to give by default all the roles to the `admin`.
`RulesManagementModule` itself is access-control agnostic; RBAC is wired at the concrete `RuleEngine` level.
Note: this `hasRole` override does not add the admin address to each role's enumerable member set. As a result, `getRoleMember` / `getRoleMemberCount` for a specific role do not include the admin unless that role is explicitly granted.

See also [docs.openzeppelin.com - AccessControlEnumerable](https://docs.openzeppelin.com/contracts/5.x/api/access#AccessControlEnumerable)

#### RuleEngineOwnable (ERC-173 Ownership)

The `RuleEngineOwnable` contract uses [ERC-173](https://eips.ethereum.org/EIPS/eip-173) ownership via OpenZeppelin's `Ownable`.

All protected functions require the caller to be the contract owner. The owner can:
- Transfer ownership to another address via `transferOwnership(address)`
- Renounce ownership via `renounceOwnership()` (makes the contract ownerless)

This is a simpler access control model suitable for single-owner deployments.

See also [docs.openzeppelin.com - Ownable](https://docs.openzeppelin.com/contracts/5.x/api/access#Ownable)

#### RuleEngineOwnable2Step (ERC-173 Ownership, two-step transfer)

The `RuleEngineOwnable2Step` contract uses OpenZeppelin's `Ownable2Step`, which keeps the same owner-only protections and adds safer ownership handover with `transferOwnership(address)` + `acceptOwnership()`.

See also [docs.openzeppelin.com - Ownable2Step](https://docs.openzeppelin.com/contracts/5.x/api/access#Ownable2Step)

### ERC-165 Support by Deployment Version

The table below summarizes which ERC-165 interfaces are advertised by each deployment version via `supportsInterface(bytes4)`.

| Interface | Interface ID | RuleEngine (RBAC deployment) | RuleEngineOwnable deployment | RuleEngineOwnable2Step deployment |
| --- | --- | --- | --- | --- |
| `IERC165` | `0x01ffc9a7` | Yes | Yes | Yes |
| `IRuleEngine` | `0x20c49ce7` | Yes | Yes | Yes |
| `IERC1404` | `0xab84a5c8` | Yes | Yes | Yes |
| `IERC1404Extend` | `0x78a8de7d` | Yes | Yes | Yes |
| `IERC3643Compliance` | `0x3144991c` | Yes | Yes | Yes |
| `IERC7551Compliance` (subset) | `0x7157797f` | Yes | Yes | Yes |
| `IERC173` | `0x7f5828d0` | No | Yes | Yes |
| `Ownable2Step` specific (`pendingOwner()`, `acceptOwnership()`) | `0x9ab669ef` | No | No | Yes |
| `IAccessControl` | `0x7965db0b` | Yes | No | No |
| `IAccessControlEnumerable` | `0x5a05180f` | Yes | No | No |

Notes:
- `RuleEngine` advertises OpenZeppelin RBAC interfaces because it inherits `AccessControlEnumerable`.
- `RuleEngineOwnable` / `RuleEngineOwnable2Step` intentionally do not advertise `IAccessControl`.
- `Ownable2Step` specific interface ID is defined in `Ownable2StepInterfaceId` and includes only `pendingOwner()` and `acceptOwnership()`.

#### Role list (RuleEngine only)

Here is the list of roles and their 32 bytes identifier for the `RuleEngine` contract.

The default admin is the address put in argument (`admin`) inside the constructor.

It is set in the constructor when the contract is deployed.

> Note: For `RuleEngineOwnable` and `RuleEngineOwnable2Step`, all protected functions are controlled by the single `owner` address instead of roles.

> **Warning (role assignment):** Rule contracts should be treated as trusted logic components and kept separate from governance/operator identities. The protocol now enforces key protections on-chain: in RBAC deployments, `grantRole` reverts if the target account is in the rule set; in ownable deployments, `transferOwnership` reverts if the new owner is in the rule set. In multi-token deployments, do not grant any governance/operator privileges to token contract addresses (bound tokens should remain data-plane callers only, meaning runtime compliance callbacks such as `transferred`, `created`, and `destroyed`). This token-privilege separation is intentionally documented as an operational constraint (not enforced on-chain) to preserve flexibility for integrators who explicitly want to extend their token and route selected RuleEngine control-plane actions through token logic (`control-plane` here means configuration/governance actions such as `bindToken`, `unbindToken`, role grants, ownership changes, and rule management).

|                         | Defined in                       | 32 bytes identifier                                          |
| ----------------------- | -------------------------------- | ------------------------------------------------------------ |
| DEFAULT_ADMIN_ROLE      | OpenZeppelin<br />AccessControl  | 0x0000000000000000000000000000000000000000000000000000000000000000 |
| **Modules**             |                                  |                                                              |
| COMPLIANCE_MANAGER_ROLE | ERC3643ComplianceModule          | 0xe5c50d0927e06141e032cb9a67e1d7092dc85c0b0825191f7e1cede600028568 |
| RULES_MANAGEMENT_ROLE   | RulesManagementModuleInvariantStorage | 0xea5f4eb72290e50c32abd6c23e45de3d8300b3286e1cbc2e293114b92e034e5e |



#### Schema (RuleEngine)

Here is a schema of the Access Control for `RuleEngine`.
![alt text](./doc/security/accessControl/access-control-RuleEngine.png)

#### Role by modules (RuleEngine)

Here is a summary table for each restricted function defined in a module.
For function signatures, struct arguments are represented with their corresponding native type.

> Note: For `RuleEngineOwnable` and `RuleEngineOwnable2Step`, replace the role requirement with `onlyOwner` for all protected functions.

|                      | Function signature | Visibility [public/external] | Input variables (Function arguments) | Output variables<br />(return value) | Role Required |
| -------------------- | ------------------ | ---------------------------- | ------------------------------------ | ------------------------------------ | ------------- |
| **Modules**          |                    |                              |                                      |                                      |               |
| RulesManagementModule |                    |                              |                                      |                                      |               |
|                      | `setRules(address[] rules_)`                                 | public                       | `IRule[] rules_`                                         | -                                    | RULES_MANAGEMENT_ROLE     |
|                         | `clearRules()`                                               | public                              | - |-|RULES_MANAGEMENT_ROLE|
|                         | `addRule(address rule_)`                                     | public | `IRule rule_` |-|RULES_MANAGEMENT_ROLE|
|                         | `removeRule(address rule_)`                                  | public | `IRule rule_` |-|RULES_MANAGEMENT_ROLE|
| ERC3643ComplianceModule |  |                              |                                      |                                      |               |
|  | `bindToken(address token)` | public | `address token` | - | COMPLIANCE_MANAGER_ROLE |
|  | `unbindToken(address token)` | public | `address token` | - | COMPLIANCE_MANAGER_ROLE |
| RuleEngineBase |  | | | | |
|  | `transferred(address from,address to,uint256 value)` | public | `address from,address to, uint256 value` | - | onlyBoundToken (modifier) |
|  | `transferred(address spender,address from,address to,uint256 value)` | public | `address spender,address from,address to, uint256 value` | - | onlyBoundToken (modifier) |



### UML

Here is the UML of the main contracts:

#### RuleEngine
![RuleEngineUML](./doc/schema/vscode-uml/RuleEngineUML.png)

#### RuleEngineOwnable

![RuleEngineOwnableUML](./doc/schema/vscode-uml/RuleEngineOwnableUML.png)

`RuleEngineOwnable` shares the same base functionality as `RuleEngine` but uses ERC-173 ownership instead of RBAC.

```
RuleEngineOwnable
├── ERC2771ModuleStandalone (gasless support)
├── RuleEngineBase (core functionality)
│   ├── VersionModule
│   ├── RulesManagementModule
│   ├── ERC3643ComplianceModule
│   └── IRuleEngineERC1404
└── Ownable (ERC-173 access control)
```

**Key differences from RuleEngine:**
- Constructor takes `owner_` instead of `admin`
- All protected functions use `onlyOwner` modifier
- Supports `transferOwnership()` and `renounceOwnership()`
- Implements ERC-173 interface (`supportsInterface(0x7f5828d0)` returns `true`)

#### RuleEngineOwnable2Step

![RuleEngineOwnable2StepUML](./doc/schema/vscode-uml/RuleEngineOwnable2StepUML.png)

`RuleEngineOwnable2Step` shares the same base functionality as `RuleEngineOwnable` but uses OpenZeppelin's `Ownable2Step` for safer ownership handover.

```
RuleEngineOwnable2Step
├── ERC2771ModuleStandalone (gasless support)
├── RuleEngineOwnableShared (shared ownable deployment logic)
│   └── RuleEngineBase
│       ├── VersionModule
│       ├── RulesManagementModule
│       ├── ERC3643ComplianceModule
│       └── IRuleEngineERC1404
└── Ownable2Step (ERC-173 access control with pending owner)
```

**Key differences from RuleEngineOwnable:**
- Uses a two-step ownership transfer flow: `transferOwnership()` then `acceptOwnership()`
- The current owner retains privileges until the pending owner accepts ownership
- Reuses `RuleEngineOwnableShared` for constructor, ERC-165 (via OpenZeppelin `ERC165`), and ERC-2771 behavior
- Implements ERC-173 interface (`supportsInterface(0x7f5828d0)` returns `true`)
- Implements Ownable2Step-specific ERC-165 interface (`supportsInterface(0x9ab669ef)` returns `true`), covering `pendingOwner()` and `acceptOwnership()`





### Graph

Here is the surya graph of the main contract:

![surya_graph_RuleEngine](./doc/schema/surya/surya_graph/surya_graph_RuleEngine.sol.png)

## Functionality

Several functionalities are not implemented because it makes more sense to directly implement them in the token smart contract

The RuleEngine can be removed from the main token contract by calling these dedicated functions

- CMTAT v3.0.0: `setRuleEngine(address ruleEngine)`
- ERC-3643 token: `setCompliance(address _compliance)`

### Available Rules

Rules are maintained in a dedicated repository: [github.com/CMTA/Rules](https://github.com/CMTA/Rules).

Rules can be used in two ways:

- Directly on CMTAT (single-rule setup, no RuleEngine orchestration).
- Through this RuleEngine (multi-rule orchestration with sequential execution).

Rule families:

| Family | Behavior | Examples |
| --- | --- | --- |
| Validation rules (read-only) | Evaluate transfer eligibility without mutating rule state | `RuleWhitelist`, `RuleBlacklist`, `RuleSanctionList`, `RuleIdentityRegistry`, `RuleSpenderWhitelist`, `RuleERC2980`, `RuleMaxTotalSupply` |
| Operation rules (read-write) | Evaluate transfer eligibility and can update rule-specific state on transfer | `RuleConditionalTransferLight` |

Additional integration notes:

- For RuleEngine integration, a rule must implement `IRule` (including ERC-165 support for the Rule interface ID).
- RuleEngine executes configured rules in order and reverts on the first failing rule in state-changing paths.
- Restriction codes should remain unique across the composed rule set. Keep CMTAT-reserved ranges free and use dedicated code ranges per rule 
- For the latest list of production rules, audits, and status, use the Rules repository as the source of truth.

#### Rules details

Here is a summary tab of available rules, see [github.com/CMTA/Rules](https://github.com/CMTA/Rules)

| Rule                                                         | Type <br />[read-only / read-write] | Description                                                  |
| ------------------------------------------------------------ | ----------------------------------- | ------------------------------------------------------------ |
| RuleWhitelist                                                | Read-only                           | This rule can be used to restrict transfers from/to only addresses inside a whitelist. |
| RuleWhitelistWrapper                                         | Read-Only                           | This rule can be used to restrict transfers from/to only addresses inside a group of whitelist rules managed by different operators. |
| RuleBlacklist                                                | Read-Only                           | This rule can be used to forbid transfer from/to addresses in the blacklist |
| RuleSanctionList                                             | Read-Only                           | The purpose of this contract is to use the oracle contract from [Chainalysis](https://go.chainalysis.com/chainalysis-oracle-docs.html) to forbid transfer from/to an address included in a sanctions designation (US, EU, or UN). |
| RuleMaxTotalSupply                                           | Read-Only                           | This rule limits minting so that the total supply never exceeds a configured maximum. |
| RuleIdentityRegistry                                         | Read-Only                           | This rule checks the ERC-3643 Identity Registry for transfer participants when configured. |
| RuleSpenderWhitelist                                         | Read-Only                           | This rule blocks `transferFrom` when the spender is not in the whitelist. Direct transfers are always allowed. |
| RuleERC2980                                                  | Read-Only                           | ERC-2980 Swiss Compliant rule combining a whitelist (recipient-only) and a frozenlist (blocks sender, recipient, and spender for `transferFrom`). Frozenlist takes priority over whitelist. |
| RuleConditionalTransferLight                                 | Read-Write                          | This rule requires that transfers have to be approved by an operator before being executed. Each approval is consumed once and the same transfer can be approved multiple times. |
| [RuleConditionalTransfer](https://github.com/CMTA/RuleConditionalTransfer) (external) | Read-Write                          | Full-featured approval-based transfer rule implementing Swiss law *Vinkulierung*. Supports automatic approval after three months, automatic transfer execution, and a conditional whitelist for address pairs that bypass approval. Maintained in a separate repository. |
| [RuleSelf](https://github.com/rya-sge/ruleself) (community)  | —                                   | Use [Self](https://self.xyz), a zero-knowledge identity  solution to determine which is allowed to interact with the token.<br />Community-maintained rule project. Not developed or maintained by CMTA. |

### Gasless support (ERC-2771)

![surya_inheritance_ERC2771ModuleStandalone.sol](./doc/schema/surya/surya_inheritance/surya_inheritance_ERC2771ModuleStandalone.sol.png)

The RuleEngine supports client-side gasless transactions using the standard [ERC-2771](https://eips.ethereum.org/EIPS/eip-2771).

The contract uses the OpenZeppelin contract `ERC2771ContextUpgradeable`, which allows a contract to get the original client with `_msgSender()` instead of the feepayer given by `msg.sender`.

At deployment, the parameter  `forwarder` inside the RuleEngine contract constructor has to be set  with the defined address of the forwarder. 

After deployment, the forwarder is immutable and can not be changed.

References:

- [OpenZeppelin Meta Transactions](https://docs.openzeppelin.com/contracts/5.x/api/metatx)

- OpenGSN has deployed several forwarders, see their [documentation](https://docs.opengsn.org/contracts/#receiving-a-relayed-call) for examples.

### Upgradeable

A proxy architecture (upgradeable) increases the code complexity as well as the runtime gas cost for each transaction. This is why the RuleEngine is not upgradeable.

Moreover, in a proxy architecture, each new implementation must be compatible (storage) with the precedent implementation, which can reduce the ability to improve the code.

In case you use the same RuleEngine for several different tokens, unfortunately, you will have to update the address of the RuleEngine set in each token contract separately. 

### Urgency mechanism

#### Pause

There are no functionalities to put the RuleEngine in pause . 

The RuleEngine can be removed from the main token contract by calling the dedicated functions to manage the RuleEngine

#### Kill / Deactivate the contracts

There are no functionalities to kill/deactivate the contracts.

Similar to the pause functionality, the RuleEngine can be directly removed from the main token contract.

## Ethereum API

### Contract Constructors

#### RuleEngine Constructor

```solidity
constructor(
    address admin,
    address forwarderIrrevocable,
    address tokenContract
)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| admin | address | Address granted DEFAULT_ADMIN_ROLE (has all roles) |
| forwarderIrrevocable | address | ERC-2771 trusted forwarder address (can be zero) |
| tokenContract | address | Token to bind at deployment (can be zero) |

#### RuleEngineOwnable Constructor

```solidity
constructor(
    address owner_,
    address forwarderIrrevocable,
    address tokenContract
)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| owner_ | address | Address set as contract owner (ERC-173) |
| forwarderIrrevocable | address | ERC-2771 trusted forwarder address (can be zero) |
| tokenContract | address | Token to bind at deployment (can be zero) |

### RuleEngineBase

![RuleEngineBaseUML](./doc/schema/vscode-uml/RuleEngineBaseUML.png)

#### Contracts Description Table


|      Contract      |             Type              |                            Bases                             |                |                |
| :----------------: | :---------------------------: | :----------------------------------------------------------: | :------------: | :------------: |
|         └          |       **Function Name**       |                        **Visibility**                        | **Mutability** | **Modifiers**  |
|                    |                               |                                                              |                |                |
| **RuleEngineBase** |        Implementation         | VersionModule, RulesManagementModule, ERC3643ComplianceModule, RuleEngineInvariantStorage, IRuleEngine |                |                |
|         └          |          transferred          |                           Public ❗️                           |       🛑        | onlyBoundToken |
|         └          |          transferred          |                           Public ❗️                           |       🛑        | onlyBoundToken |
|         └          |            created            |                           Public ❗️                           |       🛑        | onlyBoundToken |
|         └          |           destroyed           |                           Public ❗️                           |       🛑        | onlyBoundToken |
|         └          |   detectTransferRestriction   |                           Public ❗️                           |                |      NO❗️       |
|         └          | detectTransferRestrictionFrom |                           Public ❗️                           |                |      NO❗️       |
|         └          |          canTransfer          |                           Public ❗️                           |                |      NO❗️       |
|         └          |        canTransferFrom        |                           Public ❗️                           |                |      NO❗️       |
|         └          | messageForTransferRestriction |                           Public ❗️                           |                |      NO❗️       |
|         └          |            hasRole            |                           Public ❗️                           |                |      NO❗️       |


##### Legend

| Symbol | Meaning                   |
| :----: | ------------------------- |
|   🛑    | Function can modify state |
|   💵    | Function is payable       |

#### IRuleEngine

![IRuleEngineUML](./doc/schema/vscode-uml/IRuleEngineUML.png)

##### transferred(address spender, address from, address to, uint256 value)

```solidity
function transferred(address spender,address from,address to,uint256 value) 
public virtual override(IRuleEngine) 
onlyBoundToken
```

Function called whenever tokens are transferred from one wallet to another.

Must revert if the transfer is invalid.
 Same name as ERC-3643 but with an additional `spender` parameter.
 This function can be used to update state variables of the RuleEngine contract.
 Can only be called by the token contract bound to the RuleEngine.

**Input Parameters:**

| Name    | Type    | Description                                    |
| ------- | ------- | ---------------------------------------------- |
| spender | address | The spender address initiating the transfer.   |
| from    | address | The token holder address.                      |
| to      | address | The receiver address.                          |
| value   | uint256 | The amount of tokens involved in the transfer. |

#### IERC7551Compliance

![IERC7551ComplianceUML](./doc/schema/vscode-uml/IERC7551ComplianceUML.png)

> Note: ERC-7551 is draft (not final). The `IERC7551Compliance` interface used here is a subset interface exposing the compliance check `canTransferFrom`.

##### canTransferFrom(address spender, address from, address to, uint256 value) -> bool

Checks if `spender` can transfer `value` tokens from `from` to `to` under compliance rules.

Does not check balances or access rights (Access Control).

**Input Parameters:**

| Name    | Type    | Description                          |
| ------- | ------- | ------------------------------------ |
| spender | address | The address performing the transfer. |
| from    | address | The source address.                  |
| to      | address | The destination address.             |
| value   | uint256 | The number of tokens to transfer.    |



**Return Values:**

| Type | Description                                |
| ---- | ------------------------------------------ |
| bool | True if the transfer complies with policy. |

#### IERC3643ComplianceRead

![IERC3643ComplianceReadUML](./doc/schema/vscode-uml/IERC3643ComplianceReadUML.png)

------

##### canTransfer(address from, address to, uint256 value) -> bool

Returns true if the transfer is valid, and false otherwise.

Does not check balances or access rights (Access Control).

**Input Parameters:**

| Name  | Type    | Description                       |
| ----- | ------- | --------------------------------- |
| from  | address | The source address.               |
| to    | address | The destination address.          |
| value | uint256 | The number of tokens to transfer. |



**Return Values:**

| Type | Description                                     |
| ---- | ----------------------------------------------- |
| bool | True if the transfer is valid, false otherwise. |

#### IERC3643IComplianceContract

![IERC3643IComplianceContractUML](./doc/schema/vscode-uml/IERC3643IComplianceContractUML.png)

------

##### transferred(address from, address to, uint256 value)

```solidity
function transferred(address from,address to,uint256 value) 
public virtual override(IERC3643IComplianceContract) 
onlyBoundToken
```

Updates the compliance contract state whenever tokens are transferred.

Can only be called by the token contract bound to this compliance logic.
 This function can be used to update internal state variables.

**Input Parameters:**

| Name  | Type    | Description                                    |
| ----- | ------- | ---------------------------------------------- |
| from  | address | The address of the sender.                     |
| to    | address | The address of the receiver.                   |
| value | uint256 | The number of tokens involved in the transfer. |



#### IERC3643Compliance

------

##### created(address to, uint256 value)

```solidity
function created(address to, uint256 value) 
public virtual override(IERC3643Compliance) 
onlyBoundToken
```

Updates the compliance contract state when tokens are created (minted).

Called by the token contract when new tokens are issued to an account.
 Reverts if the minting does not comply with the rules.

**Input Parameters:**

| Name  | Type    | Description                              |
| ----- | ------- | ---------------------------------------- |
| to    | address | The address receiving the minted tokens. |
| value | uint256 | The number of tokens created.            |



------

##### destroyed(address from, uint256 value)

```solidity
function destroyed(address from, uint256 value) 
public virtual override(IERC3643Compliance) 
onlyBoundToken 
```

Updates the compliance contract state when tokens are destroyed (burned).

Called by the token contract when tokens are redeemed or burned.
 Reverts if the burning does not comply with the rules.

**Input Parameters:**

| Name  | Type    | Description                                   |
| ----- | ------- | --------------------------------------------- |
| from  | address | The address whose tokens are being destroyed. |
| value | uint256 | The number of tokens destroyed.               |



#### IERC1404

![IERC1404UML](./doc/schema/vscode-uml/IERC1404UML.png)

------

##### detectTransferRestriction(address from, address to, uint256 value) -> uint8

Returns a uint8 code to indicate if a transfer is restricted or not.

Implements the restriction logic of {ERC-1404}.
 Examples of restriction logic include:

- checking if the recipient is whitelisted,
- checking if the sender’s tokens are frozen during a lock-up period, etc.

**Input Parameters:**

| Name  | Type    | Description                       |
| ----- | ------- | --------------------------------- |
| from  | address | The source address.               |
| to    | address | The destination address.          |
| value | uint256 | The number of tokens to transfer. |



**Return Values:**

| Type  | Description                                            |
| ----- | ------------------------------------------------------ |
| uint8 | Restriction code (0 means the transfer is authorized). |



------

##### messageForTransferRestriction(uint8 restrictionCode) -> string

Returns a human-readable explanation for a transfer restriction code.

Implements {ERC-1404} standard message accessor.

**Input Parameters:**

| Name            | Type  | Description                        |
| --------------- | ----- | ---------------------------------- |
| restrictionCode | uint8 | The restriction code to interpret. |



**Return Values:**

| Type   | Description                                          |
| ------ | ---------------------------------------------------- |
| string | A message describing why the transfer is restricted. |



------

#### IERC1404Extend

![IERC1404ExtendUML](./doc/schema/vscode-uml/IERC1404ExtendUML.png)

##### enum REJECTED_CODE_BASE

Error codes for transfer restrictions.
 Codes `6–9` are reserved for future CMTAT ruleEngine extensions.

| Name                                               | Value | Description                                                  |
| -------------------------------------------------- | ----- | ------------------------------------------------------------ |
| TRANSFER_OK                                        | 0     | Transfer authorized.                                         |
| TRANSFER_REJECTED_PAUSED                           | 1     | Transfer rejected because the token is paused.               |
| TRANSFER_REJECTED_FROM_FROZEN                      | 2     | Transfer rejected because the sender’s address is frozen.    |
| TRANSFER_REJECTED_TO_FROZEN                        | 3     | Transfer rejected because the recipient’s address is frozen. |
| TRANSFER_REJECTED_SPENDER_FROZEN                   | 4     | Transfer rejected because the spender’s address is frozen.   |
| TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE | 5     | Transfer rejected because the sender does not have enough active (unfrozen) balance. |



------

##### detectTransferRestrictionFrom(address spender, address from, address to, uint256 value) -> uint8

Returns a uint8 code to indicate if a transfer is restricted or not.

This is an extension of {ERC-1404} with an additional `spender` parameter to enforce restriction logic on delegated transfers.
 Examples of restriction logic include:

- verifying if the recipient is whitelisted,
- verifying if tokens are locked for either sender or spender, etc.

**Input Parameters:**

| Name    | Type    | Description                                                  |
| ------- | ------- | ------------------------------------------------------------ |
| spender | address | The address initiating the transfer (for delegated transfers). |
| from    | address | The source address.                                          |
| to      | address | The destination address.                                     |
| value   | uint256 | The number of tokens to transfer.                            |



**Return Values:**

| Type  | Description                                            |
| ----- | ------------------------------------------------------ |
| uint8 | Restriction code (0 means the transfer is authorized). |



------

### VersionModule

![VersionModuleUML](./doc/schema/vscode-uml/VersionModuleUML.png)

#### Contracts Description Table


|     Contract      |       Type        |     Bases      |                |               |
| :---------------: | :---------------: | :------------: | :------------: | :-----------: |
|         └         | **Function Name** | **Visibility** | **Mutability** | **Modifiers** |
|                   |                   |                |                |               |
| **VersionModule** |  Implementation   |  IERC3643Base  |                |               |
|         └         |      version      |    Public ❗️    |                |      NO❗️      |

#### version()

```solidity
function version() external view returns (string memory version_);
```

```solidity
function version() 
public view virtual override(IERC3643Base) 
returns (string memory version_)
```

 **Description**

Returns the current version of the token contract.
Useful for identifying which version of the smart contract is deployed and in use. 

**Return**

| Name       | Type   | Description                                                  |
| ---------- | ------ | ------------------------------------------------------------ |
| `version_` | string | The version string of the token implementation (e.g., "1.0.0"). |



### ERC3643ComplianceModule

![ERC3643ComplianceModuleUML](./doc/schema/vscode-uml/ERC3643ComplianceModuleUML.png)

#### Contracts Description Table


|          Contract           |       Type        |               Bases               |                |               |
| :-------------------------: | :---------------: | :-------------------------------: | :------------: | :-----------: |
|              └              | **Function Name** |          **Visibility**           | **Mutability** | **Modifiers** |
|                             |                   |                                   |                |               |
| **ERC3643ComplianceModule** |  Implementation   | Context, IERC3643Compliance |                |               |
|              └              |     bindToken     |             Public ❗️              |       🛑        |   onlyRole    |
|              └              |    unbindToken    |             Public ❗️              |       🛑        |   onlyRole    |
|              └              |   isTokenBound    |             Public ❗️              |                |      NO❗️      |
|              └              |   getTokenBound   |            External ❗️             |                |      NO❗️      |
|              └              |  getTokenBounds   |            External ❗️             |                |      NO❗️      |
|              └              |   _unbindToken    |            Internal 🔒             |       🛑        |               |
|              └              |    _bindToken     |            Internal 🔒             |       🛑        |               |

#### Events

##### TokenBound(address token)

```solidity
event TokenBound(address token)
```

Emitted when a token is successfully bound to the compliance contract.

**Event Parameters:**

| Name  | Type    | Description                              |
| ----- | ------- | ---------------------------------------- |
| token | address | The address of the token that was bound. |



------

##### TokenUnbound(address token)

```solidity
event TokenUnbound(address token)
```

Emitted when a token is successfully unbound from the compliance contract.

**Event Parameters:**

| Name  | Type    | Description                                |
| ----- | ------- | ------------------------------------------ |
| token | address | The address of the token that was unbound. |



------

#### Functions

##### bindToken(address token)

```solidity
function bindToken(address token) 
public override virtual 
onlyRole(COMPLIANCE_MANAGER_ROLE)
```

Associates a token contract with this compliance contract.

The compliance contract may restrict operations on the bound token according to its internal compliance logic.
 Reverts if the token is already bound.

**Input Parameters:**

| Name  | Type    | Description                       |
| ----- | ------- | --------------------------------- |
| token | address | The address of the token to bind. |



------

##### unbindToken(address token)

```solidity
function unbindToken(address token) 
public override virtual 
onlyRole(COMPLIANCE_MANAGER_ROLE)
```

Removes the association of a token contract from this compliance contract.

Reverts if the token is not currently bound.

**Input Parameters:**

| Name  | Type    | Description                         |
| ----- | ------- | ----------------------------------- |
| token | address | The address of the token to unbind. |



------

##### isTokenBound(address token) -> bool

```solidity
function isTokenBound(address token) 
public view virtual override 
returns (bool)
```

Checks whether a token is currently bound to this compliance contract.

**Input Parameters:**

| Name  | Type    | Description                  |
| ----- | ------- | ---------------------------- |
| token | address | The token address to verify. |



**Return Values:**

| Type | Description                                  |
| ---- | -------------------------------------------- |
| bool | True if the token is bound, false otherwise. |



------

#####  getTokenBound() -> address

```solidity
function getTokenBound() 
public view virtual override 
returns (address)
```

Returns the single token currently bound to this compliance contract.

If multiple tokens are supported, consider using `getTokenBounds()`.

Note that there are no guarantees on the ordering of values inside the array, and it may change when more values are added or removed.

**Return Values:**

| Type    | Description                               |
| ------- | ----------------------------------------- |
| address | The address of the currently bound token. |



------

##### getTokenBounds() -> address[]

```solidity
function getTokenBounds() 
public view override 
returns (address[] memory)
```

Returns all tokens currently bound to this compliance contract.

This is a view-only function and does not modify state.
This function is not part of the original ERC-3643 specification.

This operation will copy the entire storage to memory, which can be quite expensive. 

This is designed to mostly be used by view accessors that are queried without any gas fees.

**Return Values:**

| Type      | Description                                     |
| --------- | ----------------------------------------------- |
| address[] | An array of addresses of bound token contracts. |



### RulesManagementModule

![RuleManagementModuleUML](./doc/schema/vscode-uml/RuleManagementModuleUML.png)

#### Events

##### event AddRule(address rule)

```solidity
event AddRule(IRule indexed rule)
```

Emitted when a new rule is added to the rule set.

**Event Parameters:**

| Name | Type  | Description                                      |
| ---- | ----- | ------------------------------------------------ |
| rule | IRule | The address of the rule contract that was added. |

------

##### event RemoveRule(address rule)

```solidity
event RemoveRule(IRule indexed rule)
```

Emitted when a rule is removed from the rule set.

**Event Parameters:**

| Name | Type  | Description                                        |
| ---- | ----- | -------------------------------------------------- |
| rule | IRule | The address of the rule contract that was removed. |

------

##### event ClearRules()

```solidity
event ClearRules()
```

Emitted when all rules are cleared from the rule set.

This event has no parameters.

#### Functions

##### setRules(address[] rules_)

```solidity
function setRules(IRule[] calldata rules_) 
public virtual override(IRulesManagementModule) 
onlyRole(RULES_MANAGEMENT_ROLE)
```

Defines the complete list of rules for the rule engine.

Any previously configured rules are completely replaced.
 Rules must be deployed contracts implementing the expected `IRule` interface.
 Reverts if any rule address is zero or if duplicates are detected.

This function calls _clearRules if at least one rule is still configured

**Input Parameters:**

| Name   | Type    | Description                                                  |
| ------ | ------- | ------------------------------------------------------------ |
| rules_ | IRule[] | The array of IRule contracts to configure as the active rules. |



------

##### rulesCount() -> uint256

```solidity
function rulesCount() 
public view virtual override(IRulesManagementModule) 
returns (uint256)
```

Returns the total number of currently configured rules.

Equivalent to the length of the internal rules array.

**Return Values:**

| Type    | Description                 |
| ------- | --------------------------- |
| uint256 | The number of active rules. |



------

##### rule(uint256 ruleId) -> address

```solidity
function rule(uint256 ruleId) 
public view virtual override(IRulesManagementModule) 
returns (address)
```

Retrieves the rule address at a specific index.

Return the `zero address` if out of bounds.

Note that there are no guarantees on the ordering of values inside the array, and it may change when more values are added or removed.

**Input Parameters:**

| Name   | Type    | Description                                 |
| ------ | ------- | ------------------------------------------- |
| ruleId | uint256 | The index of the desired rule in the array. |



**Return Values:**

| Type    | Description                                      |
| ------- | ------------------------------------------------ |
| address | The address of the corresponding IRule contract. |



------

##### rules() -> address[]

```solidity
function rules()
public view virtual override(IRulesManagementModule)
returns (address[] memory)
```

Returns the full list of currently configured rules.

This is a view-only function and does not modify state.

This operation will copy the entire storage to memory, which can be quite expensive. 

This is designed to mostly be used by view accessors that are queried without any gas fees.

**Return Values:**

| Type      | Description                                             |
| --------- | ------------------------------------------------------- |
| address[] | An array containing all active rule contract addresses. |



------

##### clearRules() 

```solidity
function clearRules() 
public virtual override(IRulesManagementModule) 
onlyRole(RULES_MANAGEMENT_ROLE)
```

Removes all configured rules.

After calling this function, no rules will remain set.

Developers should keep in mind that this function has an unbounded cost and using it may render the function uncallable if the set grows to the point where clearing it consumes too much gas to fit in a block.

------

##### addRule(address rule_) 

```solidity
function addRule(IRule rule_) 
public virtual override(IRulesManagementModule) 
onlyRole(RULES_MANAGEMENT_ROLE)
```

Adds a new rule to the current rule set.

Reverts if the rule address is zero or already exists in the set.

**Input Parameters:**

| Name  | Type  | Description                |
| ----- | ----- | -------------------------- |
| rule_ | IRule | The IRule contract to add. |



------

##### removeRule(address rule_)

```solidity
 function removeRule(IRule rule_) 
 public virtual 
 override(IRulesManagementModule) 
 onlyRole(RULES_MANAGEMENT_ROLE)
```

Removes a specific rule from the current rule set.

Reverts if the provided rule is not found or does not match the stored rule at its index.

**Input Parameters:**

| Name  | Type  | Description                   |
| ----- | ----- | ----------------------------- |
| rule_ | IRule | The IRule contract to remove. |



------

##### containsRule(address rule_) -> bool

```solidity
function containsRule(IRule rule_) 
public view virtual override(IRulesManagementModule) 
returns (bool)
```

Checks whether a specific rule is currently configured.

**Input Parameters:**

| Name  | Type  | Description                                 |
| ----- | ----- | ------------------------------------------- |
| rule_ | IRule | The IRule contract to check for membership. |



**Return Values:**

| Type | Description                                   |
| ---- | --------------------------------------------- |
| bool | True if the rule is present, false otherwise. |

## Security

### Vulnerability disclosure

Please see [SECURITY.md](https://github.com/CMTA/CMTAT/blob/master/SECURITY.md) (CMTAT main repository).

### Audit

#### First Audit - March 2022

> The contracts (v.1.0.2) have been audited by [ABDK Consulting](https://www.abdk.consulting/), a globally recognized firm specialized in smart contracts' security.

Fixed version : [v1.0.2](https://github.com/CMTA/RuleEngine/releases/tag/v1.0.2)

The first audit was performed by ABDK on the version [1.0.1](https://github.com/CMTA/RuleEngine/releases/tag/1.0.1).

The release [v1.0.2](https://github.com/CMTA/RuleEngine/releases/tag/v1.0.2) contains the different fixes and improvements related to this audit.

The final report is available in [ABDK_CMTA_CMTATRuleEngine_v_1_0.pdf](https://github.com/CMTA/CMTAT/blob/master/doc/audits/ABDK_CMTA_CMTATRuleEngine_v_1_0/ABDK_CMTA_CMTATRuleEngine_v_1_0.pdf).

### Tools

#### Nethermind AuditAgent

> **Note:** This scan was performed by an AI-powered automated tool, not a formal human-led audit.

| Version | Report | Assessment |
|---------|--------|------------|
| Scan #1 (Feb 2026) | [audit_agent_report_1_v3.0.0-rc1.pdf](./doc/security/audits/tools/nethermind-audit-agent/v3.0.0-rc1/audit_agent_report_1_v3.0.0-rc1.pdf) | [feedback.md](./doc/security/audits/tools/nethermind-audit-agent/v3.0.0-rc1/audit_agent_report_1_v3.0.0-rc1-feedback.md) |

7 findings — 0 High · 1 Medium · 1 Low · 4 Info · 1 Best Practices

| # | Severity | Finding | Status |
|---|----------|---------|--------|
| 1 | Medium | Cross-token rule state pollution in multi-tenant deployments | NatSpec + README warnings. Interface fix deferred (requires CMTAT coordination). |
| 2 | Low | `RuleEngineOwnable` misreports `IAccessControl` via ERC-165 | Fixed: explicit interface whitelist + negative test added. |
| 3 | Info | Unbounded rules loop — potential permanent DoS | Fixed in `v3.0.0-rc3`: on-chain configurable cap (`maxRules`) with default `10`, enforced in `addRule` and `setRules`. |
| 4 | Info | Restriction code and message can come from different rules | Convention documented in NatSpec and README (no logic change by design). |
| 5 | Info | Re-entrant rule can modify rule set during `transferred()` | Fixed in `v3.0.0-rc3`: rule accounts cannot receive roles in RBAC `RuleEngine`; ownable variants reject ownership transfer to rule accounts. |
| 6 | Info | Missing ERC-3643 and IERC7551Compliance interface IDs | Fixed: both IDs added to `supportsInterface` in both contracts, with tests. |
| 7 | Best Practices | `setRules` does not allow an empty array | NatSpec clarification added (behavior unchanged by design). |

#### Slither

Here is the list of report performed with [Slither](https://github.com/crytic/slither)

| Version | Report | Assessment |
| ------- | ------ | ---------- |
| v3.0.0-rc2 | [slither-report.md](./doc/security/audits/tools/slither-report.md) | [slither-report-feedback.md](./doc/security/audits/tools/slither-report-feedback.md) |

```bash
slither .  --checklist --filter-paths "openzeppelin-contracts|test|CMTAT|forge-std|mocks" > slither-report.md
```

4 finding categories — 0 High · 0 Medium · 10 Low · 4 Informational

| ID | Detector | Impact | Instances | Assessment |
|----|----------|--------|-----------|------------|
| 0–9 | `calls-loop` | Low | 10 | Accepted by design — fan-out to rule contracts is the core architecture |
| 10 | `dead-code` | Informational | 1 | Accepted / no action — `_msgData` override is required by inheritance/context pattern |
| 11 | `naming-convention` | Informational | 1 | Ignored — finding is in external CMTAT dependency code |
| 12–13 | `unindexed-event-address` | Informational | 2 | Deferred — adding `indexed` to `TokenBound`/`TokenUnbound` is interface-breaking |

#### Aderyn

Here is the list of report performed with [Aderyn](https://github.com/Cyfrin/aderyn)

```bash
aderyn -x mocks --output aderyn-report.md
```

| Version | Report | Assessment |
| ------- | ------ | ---------- |
| v3.0.0-rc2 | [aderyn-report.md](./doc/security/audits/tools/aderyn-report.md) | [aderyn-report-feedback.md](./doc/security/audits/tools/aderyn-report-feedback.md) |

Report scope: 18 Solidity files, 542 nSLOC.

0 High · 8 Low

| ID | Finding | Instances | Assessment |
|----|---------|-----------|------------|
| L-1 | Centralization Risk | 14 | Accepted by design — privileged compliance tool |
| L-2 | Unspecific Solidity Pragma | 14 | Accepted by design — intentional for library reusability |
| L-3 | PUSH0 Opcode | 18 | Not applicable — project targets Prague EVM |
| L-4 | Modifier Invoked Only Once | 1 | Accepted by design — keeps hook-style access-control abstraction |
| L-5 | Empty Block | 9 | Accepted by design — access-control hook pattern |
| L-6 | Loop Contains `require`/`revert` | 1 | Accepted by design — `setRules` is an atomic batch operation |
| L-7 | Costly Operations Inside Loop | 1 | Accepted — unavoidable `SSTORE` in `setRules` |
| L-8 | Unchecked Return | 1 | Accepted — `_grantRole` return is irrelevant in constructor |

## Documentation

Here a summary of the main documentation

| Document     | Link/Files                              |
| ------------ | --------------------------------------- |
| Toolchain    | [doc/TOOLCHAIN.md](./doc/TOOLCHAIN.md)  |
| Surya report | [doc/schema/surya](./doc/schema/surya/) |

See also [Taurus - Token Transfer Management: How to Apply Restrictions with CMTAT and ERC-1404](https://www.taurushq.com/blog/token-transfer-management-how-to-apply-restrictions-with-cmtat-and-erc-1404/) (RuleEngine v2.02 and CMTAT v2.4.0)

## Toolchains and Usage

This repository is primarily developed and tested with Foundry.

Hardhat configuration is also present to allow compiling the contracts and running a small smoke test with Hardhat.

### Configuration

Here are the settings for [Hardhat](https://hardhat.org) and [Foundry](https://getfoundry.sh).

- `hardhat.config.js`
  - Solidity [v0.8.34](https://docs.soliditylang.org/en/v0.8.34/)
  - EVM version: Prague (Pectra upgrade)
  - Optimizer: true, 200 runs

- `foundry.toml`
  - Solidity [v0.8.34](https://docs.soliditylang.org/en/v0.8.34/)
  - EVM version: Prague (Pectra upgrade)
  - Optimizer: true, 200 runs




### Toolchain installation
The contracts are developed and tested with [Foundry](https://book.getfoundry.sh), a smart contract development toolchain.

To install the Foundry suite, please refer to the official instructions in the [Foundry book](https://book.getfoundry.sh/getting-started/installation).

### Initialization

You must first initialize the submodules, with

```
forge install
```

See also the command's [documentation](https://book.getfoundry.sh/reference/forge/forge-install).

Later you can update all the submodules with:

```
forge update
```

See also the command's [documentation](https://book.getfoundry.sh/reference/forge/forge-update).

### Compilation

The official documentation is available in the Foundry [website](https://book.getfoundry.sh/reference/forge/build-commands)

```bash
# Build all contracts
forge build

# Build specific contract
forge build --contracts src/deployment/RuleEngine.sol
forge build --contracts src/deployment/RuleEngineOwnable.sol
forge build --contracts src/deployment/RuleEngineOwnable2Step.sol
```
### Contract size

```bash
forge build --sizes
```

Latest output (`2026-03-18`) for the main RuleEngine contracts:

| Contract | Runtime Size (B) | Initcode Size (B) | Runtime Margin (B) | Initcode Margin (B) |
|----------|------------------:|------------------:|--------------------:|---------------------:|
| RuleEngine | 6,756 | 7,805 | 17,820 | 41,347 |
| RuleEngineOwnable | 6,170 | 6,833 | 18,406 | 42,319 |

Both `RuleEngine` and `RuleEngineOwnable` remain well below the EIP-170 runtime limit. `RuleEngineOwnable` is slightly smaller because `Ownable` has less overhead than `AccessControl`.

### Testing

You can run the tests with

```bash
forge test
```

To run a specific test, use

```bash
forge test --match-contract <contract name> --match-test <function name>
```

Generate gas report

```bash
forge test --gas-report
```

See also the test framework's [official documentation](https://book.getfoundry.sh/forge/tests), and that of the [test commands](https://book.getfoundry.sh/reference/forge/test-commands).

There is also a small Hardhat smoke test to confirm the main `RuleEngine` contract can be compiled and deployed through Hardhat:

```bash
npx hardhat test test/hardhat/RuleEngine.smoke.js
```

### Coverage

A code coverage is available in [index.html](./doc/coverage/coverage/index.html).

![code-coverage](./doc/coverage/code-coverage.png)

* Perform a code coverage
```
forge coverage
```

* Generate LCOV report
```
forge coverage --report lcov
```

- Generate `index.html`

```bash
forge coverage --no-match-coverage "(script|mocks|test)" --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage
```

See [Solidity Coverage in VS Code with Foundry](https://mirror.xyz/devanon.eth/RrDvKPnlD-pmpuW7hQeR5wWdVjklrpOgPCOA-PJkWFU) & [Foundry forge coverage](https://www.rareskills.io/post/foundry-forge-coverage)

### Deployment
The official documentation is available in the Foundry [website](https://getfoundry.sh/forge/deploying)

#### Choosing a Contract

| Scenario | Recommended Contract |
|----------|---------------------|
| Multiple operators with different permissions | `RuleEngine` |
| Single administrator | `RuleEngineOwnable` |
| Single administrator with safer ownership handover | `RuleEngineOwnable2Step` |
| Integration with existing RBAC systems | `RuleEngine` |
| Simpler deployment and management | `RuleEngineOwnable` |

#### Script

The scripts in `script/` are example deployment flows.

> Warning: `RuleEngineScript.s.sol` and `CMTATWithRuleEngineScript.s.sol` deploy `RuleWhitelist` from `src/mocks/`. That contract is a reference/mock rule for testing and demos, not a production rule contract.

For production deployments, source rule contracts from the dedicated [CMTA/Rules](https://github.com/CMTA/Rules) repository and adapt the script parameters accordingly.

To run the example scripts, create a `.env` file. The value for `CMTAT_ADDRESS` is required only for `RuleEngineScript.s.sol`.

Warning: putting your private key in a .env file is not the most secure approach.

* File `.env`
```
PRIVATE_KEY=<YOUR_PRIVATE_KEY>
CMTAT_ADDRESS=<CMTAT_ADDRESS>
```
**Private Keys**: Never expose your private keys. The `.env` file here used in this project should not be used for production. See [getfoundry.sh - Key Management](https://getfoundry.sh/guides/best-practices/key-management/)

* Command

CMTAT with RuleEngine

```bash
forge script script/CMTATWithRuleEngineScript.s.sol:CMTATWithRuleEngineScript --rpc-url=$RPC_URL  --broadcast --verify -vvv
```


- Value of YOUR_RPC_URL with a local instance of anvil : [127.0.0.1:8545](http://127.0.0.1:8545)

```bash
forge script script/CMTATWithRuleEngineScript.s.sol:CMTATWithRuleEngineScript --rpc-url=127.0.0.1:8545  --broadcast --verify -vvv
```

Only RuleEngine with the mock/reference `RuleWhitelist` contract

```bash
forge script script/RuleEngineScript.s.sol:RuleEngineScript --rpc-url=$RPC_URL  --broadcast --verify -vvv
```

- With anvil

```bash
forge script script/RuleEngineScript.s.sol:RuleEngineScript --rpc-url=127.0.0.1:8545  --broadcast --verify -vvv
```

#### Production Deployment Checklist

- Choose the deployable variant: `RuleEngine`, `RuleEngineOwnable`, or `RuleEngineOwnable2Step`.
- Choose the trusted forwarder address, or use `address(0)` if ERC-2771 support is not needed.
- Decide whether the token should be bound in the constructor or later via `bindToken`.
- Source production rule contracts from the [CMTA/Rules](https://github.com/CMTA/Rules) repository, not from `src/mocks/`.
- Verify post-deployment permissions: owner for ownable variants, or admin plus role assignments for the RBAC variant.

### Solidity style guideline

RuleEngine follows the [solidity style guideline](https://docs.soliditylang.org/en/latest/style-guide.html) and the [natspec format](https://docs.soliditylang.org/en/latest/natspec-format.html) for comments

#### Formatting & Linting

We use Foundry's built-in formatter and linter:

```bash
# Format all Solidity files
forge fmt

# Check formatting without modifying files
forge fmt --check

# Run the Solidity linter
forge lint
```

- Orders of Functions

Functions are grouped according to their visibility and ordered:

```
1. constructor

2. receive function (if exists)

3. fallback function (if exists)

4. external

5. public

6. internal

7. private
```

Within a grouping, place the `view` and `pure` functions last

- Function declaration

```
1. Visibility
2. Mutability
3. Virtual
4. Override
5. Custom modifiers
```

## Intellectual property

The code is copyright (c) Capital Market and Technology Association, 2022-2026, and is released under [Mozilla Public License 2.0](https://github.com/CMTA/CMTAT/blob/master/LICENSE.md).
