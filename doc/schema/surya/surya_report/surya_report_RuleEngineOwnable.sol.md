## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./deployment/RuleEngineOwnable.sol | 0aefac400a5da4ebf228f8b9b788cb1d820be5c9 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngineOwnable** | Implementation | RuleEngineOwnableShared, Ownable |||
| └ | <Constructor> | Public ❗️ | 🛑  | RuleEngineOwnableShared Ownable |
| └ | transferOwnership | Public ❗️ | 🛑  | onlyOwner |
| └ | _onlyRulesManager | Internal 🔒 | 🛑  | onlyOwner |
| └ | _onlyRulesLimitManager | Internal 🔒 | 🛑  | onlyOwner |
| └ | _onlyComplianceManager | Internal 🔒 | 🛑  | onlyOwner |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
