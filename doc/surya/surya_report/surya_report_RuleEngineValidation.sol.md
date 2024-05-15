## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/RuleEngineValidation.sol | 389f8e6a721d981e7704f67c608138af0b3bed97 |


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
