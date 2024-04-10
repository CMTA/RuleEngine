## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RuleEngineValidation.sol | 818bc0f7e4fc858d3aa6efc76811268aa81bd3ee |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngineValidation** | Implementation | AccessControl, RuleInternal, IRuleEngineValidation, IERC1404EnumCode |||
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
| └ | detectTransferRestrictionValidation | Public ❗️ |   |NO❗️ |
| └ | validateTransferValidation | Public ❗️ |   |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
