## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./RuleEngineOwnable.sol | ee4b074118dd5b6e5081dee278d7dbcc22f633ca |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleEngineOwnable** | Implementation | ERC2771ModuleStandalone, RuleEngineBase, Ownable |||
| └ | <Constructor> | Public ❗️ | 🛑  | ERC2771ModuleStandalone Ownable |
| └ | _onlyRulesManager | Internal 🔒 | 🛑  | onlyOwner |
| └ | _onlyComplianceManager | Internal 🔒 | 🛑  | onlyOwner |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
