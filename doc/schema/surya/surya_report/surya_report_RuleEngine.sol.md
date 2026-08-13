## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| /home/ryan/Pictures/dev/RE-new/RuleEngineNew/src/deployment/RuleEngine.sol | db22b86109302bb91ebed984461f6436a4364dfc |


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
