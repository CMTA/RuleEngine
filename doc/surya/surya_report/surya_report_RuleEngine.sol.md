## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./RuleEngine.sol | 0fc418971885c84c32fab8ba76462a7ae5c77b77 |


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
