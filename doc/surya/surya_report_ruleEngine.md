## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| src/RuleEngine.sol | 4b956daef08af2a9e4285f4775f7f459d672c684 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngine** | Implementation | IRuleEngine, AccessControl, MetaTxModuleStandalone |||
| └ | <Constructor> | Public ❗️ | 🛑  | MetaTxModuleStandalone |
| └ | setRules | External ❗️ | 🛑  | onlyRole |
| └ | clearRules | Public ❗️ | 🛑  | onlyRole |
| └ | addRule | Public ❗️ | 🛑  | onlyRole |
| └ | removeRule | Public ❗️ | 🛑  | onlyRole |
| └ | rulesCount | External ❗️ |   |NO❗️ |
| └ | getRuleIndex | External ❗️ |   |NO❗️ |
| └ | rule | External ❗️ |   |NO❗️ |
| └ | rules | External ❗️ |   |NO❗️ |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | validateTransfer | Public ❗️ |   |NO❗️ |
| └ | messageForTransferRestriction | External ❗️ |   |NO❗️ |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
