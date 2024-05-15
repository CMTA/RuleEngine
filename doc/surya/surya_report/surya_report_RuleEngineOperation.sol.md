## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RuleEngineOperation.sol | a511cf11774bebce822a8b277f0d33a71d6df492 |


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
