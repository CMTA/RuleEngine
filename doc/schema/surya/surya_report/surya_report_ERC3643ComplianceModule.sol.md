## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/ERC3643ComplianceModule.sol | 2a66e7dd13981ffa96eb91f3063fc67a40480646 |


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
