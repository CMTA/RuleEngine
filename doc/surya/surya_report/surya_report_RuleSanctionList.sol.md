## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./rules/validation/RuleSanctionList.sol | 35a93e0000480f9386935a92e2f52c2a4e10d534 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **SanctionsList** | Interface |  |||
| └ | isSanctioned | External ❗️ |   |NO❗️ |
||||||
| **RuleSanctionList** | Implementation | AccessControl, MetaTxModuleStandalone, RuleValidateTransfer, RuleSanctionlistInvariantStorage |||
| └ | <Constructor> | Public ❗️ | 🛑  | MetaTxModuleStandalone |
| └ | setSanctionListOracle | Public ❗️ | 🛑  | onlyRole |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | canReturnTransferRestrictionCode | External ❗️ |   |NO❗️ |
| └ | messageForTransferRestriction | External ❗️ |   |NO❗️ |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
