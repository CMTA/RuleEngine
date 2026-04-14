## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./deployment/RuleEngine.sol | cfe52f0d2abd4758606453a366c289dda9d91300 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngine** | Implementation | ERC2771ModuleStandalone, RuleEngineBase, AccessControlEnumerable |||
| └ | <Constructor> | Public ❗️ | 🛑  | ERC2771ModuleStandalone |
| └ | hasRole | Public ❗️ |   |NO❗️ |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _onlyComplianceManager | Internal 🔒 | 🛑  | onlyRole |
| └ | _onlyRulesManager | Internal 🔒 | 🛑  | onlyRole |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
