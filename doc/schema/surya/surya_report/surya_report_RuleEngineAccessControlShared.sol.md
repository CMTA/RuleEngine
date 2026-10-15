## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./RuleEngineAccessControlShared.sol | 1652f17fd38320f26e3abaef7b447013ba7f2f16 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngineAccessControlShared** | Implementation | RuleEngineBase, AccessControlEnumerable, ERC3643ComplianceRolesStorage, RulesManagementModuleRolesStorage |||
| └ | <Constructor> | Public ❗️ | 🛑  |NO❗️ |
| └ | grantRole | Public ❗️ | 🛑  |NO❗️ |
| └ | hasRole | Public ❗️ |   |NO❗️ |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _onlyComplianceManager | Internal 🔒 | 🛑  | onlyRole |
| └ | _onlyRulesManager | Internal 🔒 | 🛑  | onlyRole |
| └ | _onlyRulesLimitManager | Internal 🔒 | 🛑  | onlyRole |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
