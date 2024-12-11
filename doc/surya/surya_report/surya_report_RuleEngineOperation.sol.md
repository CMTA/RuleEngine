## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RuleEngineOperation.sol | 1e2f612e6fd60aaec03b4ad3c9651085f87026c1 |


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
