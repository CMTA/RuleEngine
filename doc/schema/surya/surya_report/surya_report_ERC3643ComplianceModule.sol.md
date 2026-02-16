## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/ERC3643ComplianceModule.sol | 182aff8d18ff3f6df8e27fd9a93df1788cdb9339 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC3643ComplianceModule** | Implementation | Context, IERC3643Compliance |||
| └ | bindToken | Public ❗️ | 🛑  | onlyComplianceManager |
| └ | unbindToken | Public ❗️ | 🛑  | onlyComplianceManager |
| └ | isTokenBound | Public ❗️ |   |NO❗️ |
| └ | getTokenBound | Public ❗️ |   |NO❗️ |
| └ | getTokenBounds | Public ❗️ |   |NO❗️ |
| └ | _unbindToken | Internal 🔒 | 🛑  | |
| └ | _bindToken | Internal 🔒 | 🛑  | |
| └ | _checkBoundToken | Internal 🔒 |   | |
| └ | _onlyComplianceManager | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
