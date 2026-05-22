## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./deployment/RuleEngineOwnable2Step.sol | bc745b539127f72509a7c603272a777879fec764 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngineOwnable2Step** | Implementation | RuleEngineOwnableShared, Ownable2Step |||
| └ | <Constructor> | Public ❗️ | 🛑  | RuleEngineOwnableShared Ownable |
| └ | _onlyRulesManager | Internal 🔒 | 🛑  | onlyOwner |
| └ | _onlyRulesLimitManager | Internal 🔒 | 🛑  | onlyOwner |
| └ | _onlyComplianceManager | Internal 🔒 | 🛑  | onlyOwner |
| └ | transferOwnership | Public ❗️ | 🛑  | onlyOwner |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
