## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RuleEngineOperation.sol | 428f410167252dbe376f484fccaa796cb1309851 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngineOperation** | Implementation | AccessControl, RuleInternal, IRuleEngineOperation |||
| └ | setRulesOperation | Public ❗️ | 🛑  | onlyRole |
| └ | clearRulesOperation | Public ❗️ | 🛑  | onlyRole |
| └ | _clearRulesOperation | Internal 🔒 | 🛑  | |
| └ | addRuleOperation | Public ❗️ | 🛑  | onlyRole |
| └ | removeRuleOperation | Public ❗️ | 🛑  | onlyRole |
| └ | _removeRuleOperation | Internal 🔒 | 🛑  | |
| └ | rulesCountOperation | External ❗️ |   |NO❗️ |
| └ | getRuleIndexOperation | External ❗️ |   |NO❗️ |
| └ | ruleOperation | External ❗️ |   |NO❗️ |
| └ | rulesOperation | External ❗️ |   |NO❗️ |
| └ | _operateOnTransfer | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
