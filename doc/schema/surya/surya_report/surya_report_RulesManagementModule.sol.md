## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RulesManagementModule.sol | cf430f5f20aa0cbd61d3be802a04dfa0e7f00a17 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RulesManagementModule** | Implementation | RulesManagementModuleInvariantStorage, IRulesManagementModule |||
| └ | setRules | Public ❗️ | 🛑  | onlyRulesManager |
| └ | clearRules | Public ❗️ | 🛑  | onlyRulesManager |
| └ | addRule | Public ❗️ | 🛑  | onlyRulesManager |
| └ | setMaxRules | Public ❗️ | 🛑  | onlyRulesLimitManager |
| └ | removeRule | Public ❗️ | 🛑  | onlyRulesManager |
| └ | maxRules | Public ❗️ |   |NO❗️ |
| └ | rulesCount | Public ❗️ |   |NO❗️ |
| └ | containsRule | Public ❗️ |   |NO❗️ |
| └ | rule | Public ❗️ |   |NO❗️ |
| └ | rules | Public ❗️ |   |NO❗️ |
| └ | _clearRules | Internal 🔒 | 🛑  | |
| └ | _setMaxRules | Internal 🔒 | 🛑  | |
| └ | _addRule | Internal 🔒 | 🛑  | |
| └ | _removeRule | Internal 🔒 | 🛑  | |
| └ | _transferred | Internal 🔒 | 🛑  | |
| └ | _transferred | Internal 🔒 | 🛑  | |
| └ | _onlyRulesManager | Internal 🔒 | 🛑  | |
| └ | _onlyRulesLimitManager | Internal 🔒 | 🛑  | |
| └ | _checkRule | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
