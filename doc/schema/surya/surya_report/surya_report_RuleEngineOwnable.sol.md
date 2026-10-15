## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./deployment/RuleEngineOwnable.sol | 6aba3764a23397b847b9ee64e21753638216704d |


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


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
