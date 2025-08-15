## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RulesManagementModule.sol | 01d405489c52d6b0e2feac077bfe0b4a95078119 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RulesManagementModule** | Implementation | AccessControl, RulesManagementModuleInvariantStorage, IRulesManagementModule |||
| └ | setRules | Public ❗️ | 🛑  | onlyRole |
| └ | clearRules | Public ❗️ | 🛑  | onlyRole |
| └ | addRule | Public ❗️ | 🛑  | onlyRole |
| └ | removeRule | Public ❗️ | 🛑  | onlyRole |
| └ | rulesCount | Public ❗️ |   |NO❗️ |
| └ | containsRule | Public ❗️ |   |NO❗️ |
| └ | rule | Public ❗️ |   |NO❗️ |
| └ | rules | Public ❗️ |   |NO❗️ |
| └ | _clearRules | Internal 🔒 | 🛑  | |
| └ | _removeRule | Internal 🔒 | 🛑  | |
| └ | _checkRule | Internal 🔒 |   | |
| └ | _transferred | Internal 🔒 | 🛑  | |
| └ | _transferred | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
