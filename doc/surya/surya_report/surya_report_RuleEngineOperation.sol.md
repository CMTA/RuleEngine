## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RuleEngineOperation.sol | d3de41695a73eb2f2cb02dbea88b72174a2a9830 |


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
