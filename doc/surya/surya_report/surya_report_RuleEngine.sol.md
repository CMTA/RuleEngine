## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./RuleEngine.sol | 9ac4a4a50634a369d5b88418fc8d1af7a3b1df77 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngine** | Implementation | IRuleEngine, RuleEngineOperation, RuleEngineValidation, MetaTxModuleStandalone |||
| └ | <Constructor> | Public ❗️ | 🛑  | MetaTxModuleStandalone |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | validateTransfer | Public ❗️ |   |NO❗️ |
| └ | messageForTransferRestriction | External ❗️ |   |NO❗️ |
| └ | operateOnTransfer | External ❗️ | 🛑  | onlyRole |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
