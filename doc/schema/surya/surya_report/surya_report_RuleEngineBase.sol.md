## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./RuleEngineBase.sol | 980b240b1a4a9a7b888410cf13a40f47e6bacdfe |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngineBase** | Implementation | VersionModule, RulesManagementModule, ERC3643ComplianceExtendedModule, RuleEngineInvariantStorage, IRuleEngineERC1404 |||
| └ | transferred | Public ❗️ | 🛑  | onlyBoundToken |
| └ | transferred | Public ❗️ | 🛑  | onlyBoundToken |
| └ | created | Public ❗️ | 🛑  | onlyBoundToken |
| └ | destroyed | Public ❗️ | 🛑  | onlyBoundToken |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | detectTransferRestrictionFrom | Public ❗️ |   |NO❗️ |
| └ | messageForTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | canTransfer | Public ❗️ |   |NO❗️ |
| └ | canTransferFrom | Public ❗️ |   |NO❗️ |
| └ | _detectTransferRestriction | Internal 🔒 |   | |
| └ | _detectTransferRestrictionFrom | Internal 🔒 |   | |
| └ | _messageForTransferRestriction | Internal 🔒 |   | |
| └ | _checkRule | Internal 🔒 |   | |
| └ | _supportsRuleEngineBaseInterface | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
