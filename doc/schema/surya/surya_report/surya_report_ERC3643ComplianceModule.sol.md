## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/ERC3643ComplianceModule.sol | 69e2765f6876d799d9de6a4dc5a10da3d749485d |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC3643ComplianceModule** | Implementation | Context, IERC3643Compliance, ERC3643ComplianceModuleInvariantStorage |||
| └ | bindToken | Public ❗️ | 🛑  |NO❗️ |
| └ | unbindToken | Public ❗️ | 🛑  |NO❗️ |
| └ | isTokenBound | Public ❗️ |   |NO❗️ |
| └ | getTokenBound | Public ❗️ |   |NO❗️ |
| └ | _unbindToken | Internal 🔒 | 🛑  | |
| └ | _bindToken | Internal 🔒 | 🛑  | |
| └ | _checkBoundToken | Internal 🔒 |   | |
| └ | _authorizeComplianceBindingChange | Internal 🔒 | 🛑  | |
| └ | _onlyComplianceManager | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
