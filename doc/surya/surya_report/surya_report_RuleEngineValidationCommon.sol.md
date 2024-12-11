## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RuleEngineValidationCommon.sol | 922d0811abdd53bcc6a893c0c7877ec6402b6bfe |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngineValidationCommon** | Implementation | AccessControl, RuleInternal, IRuleEngineValidationCommon |||
| └ | setRulesValidation | Public ❗️ | 🛑  | onlyRole |
| └ | clearRulesValidation | Public ❗️ | 🛑  | onlyRole |
| └ | _clearRulesValidation | Internal 🔒 | 🛑  | |
| └ | addRuleValidation | Public ❗️ | 🛑  | onlyRole |
| └ | removeRuleValidation | Public ❗️ | 🛑  | onlyRole |
| └ | _removeRuleValidation | Internal 🔒 | 🛑  | |
| └ | rulesCountValidation | External ❗️ |   |NO❗️ |
| └ | getRuleIndexValidation | External ❗️ |   |NO❗️ |
| └ | ruleValidation | External ❗️ |   |NO❗️ |
| └ | rulesValidation | External ❗️ |   |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
