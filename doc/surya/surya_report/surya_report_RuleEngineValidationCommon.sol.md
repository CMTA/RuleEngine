## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RuleEngineValidationCommon.sol | 10414c0f3b47baecd5d5e8abe9d9d05c35ca7599 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngineValidationCommon** | Implementation | AccessControl, RuleInternal, IRuleEngineValidationCommon |||
| └ | setRulesValidation | Public ❗️ | 🛑  | onlyRole |
| └ | clearRulesValidation | Public ❗️ | 🛑  | onlyRole |
| └ | addRuleValidation | Public ❗️ | 🛑  | onlyRole |
| └ | removeRuleValidation | Public ❗️ | 🛑  | onlyRole |
| └ | rulesCountValidation | External ❗️ |   |NO❗️ |
| └ | getRuleIndexValidation | External ❗️ |   |NO❗️ |
| └ | ruleValidation | External ❗️ |   |NO❗️ |
| └ | rulesValidation | External ❗️ |   |NO❗️ |
| └ | _clearRulesValidation | Internal 🔒 | 🛑  | |
| └ | _removeRuleValidation | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
