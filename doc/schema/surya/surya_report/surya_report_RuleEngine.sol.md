## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./deployment/RuleEngine.sol | a6e71718a0950a4317d07e4b3481f26d6bc00fc9 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngine** | Implementation | ERC2771ModuleStandalone, RuleEngineBase, AccessControlEnumerable, ERC3643ComplianceRolesStorage, RulesManagementModuleRolesStorage |||
| └ | <Constructor> | Public ❗️ | 🛑  | ERC2771ModuleStandalone |
| └ | grantRole | Public ❗️ | 🛑  |NO❗️ |
| └ | hasRole | Public ❗️ |   |NO❗️ |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _onlyComplianceManager | Internal 🔒 | 🛑  | onlyRole |
| └ | _onlyRulesManager | Internal 🔒 | 🛑  | onlyRole |
| └ | _onlyRulesLimitManager | Internal 🔒 | 🛑  | onlyRole |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
