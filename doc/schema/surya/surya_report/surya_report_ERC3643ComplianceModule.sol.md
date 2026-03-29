## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/ERC3643ComplianceModule.sol | 450f861a6a5d7178fb1b038503e093e3a5491ac8 |


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
