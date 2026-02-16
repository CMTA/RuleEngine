## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RulesManagementModule.sol | eeb11b9ffc70fab119916187e532b859c6b45a37 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RulesManagementModule** | Implementation | AccessControl, RulesManagementModuleInvariantStorage, IRulesManagementModule |||
| └ | setRules | Public ❗️ | 🛑  | onlyRulesManager |
| └ | clearRules | Public ❗️ | 🛑  | onlyRulesManager |
| └ | addRule | Public ❗️ | 🛑  | onlyRulesManager |
| └ | removeRule | Public ❗️ | 🛑  | onlyRulesManager |
| └ | rulesCount | Public ❗️ |   |NO❗️ |
| └ | containsRule | Public ❗️ |   |NO❗️ |
| └ | rule | Public ❗️ |   |NO❗️ |
| └ | rules | Public ❗️ |   |NO❗️ |
| └ | _clearRules | Internal 🔒 | 🛑  | |
| └ | _removeRule | Internal 🔒 | 🛑  | |
| └ | _checkRule | Internal 🔒 |   | |
| └ | _transferred | Internal 🔒 | 🛑  | |
| └ | _transferred | Internal 🔒 | 🛑  | |
| └ | _onlyRulesManager | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
