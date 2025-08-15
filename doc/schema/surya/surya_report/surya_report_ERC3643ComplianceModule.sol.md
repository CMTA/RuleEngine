## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/ERC3643ComplianceModule.sol | 5d853a580045cc1107f0b4b00b012dd7a088b4be |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC3643ComplianceModule** | Implementation | IERC3643Compliance, AccessControl |||
| └ | bindToken | Public ❗️ | 🛑  | onlyRole |
| └ | unbindToken | Public ❗️ | 🛑  | onlyRole |
| └ | isTokenBound | Public ❗️ |   |NO❗️ |
| └ | getTokenBound | External ❗️ |   |NO❗️ |
| └ | getTokenBounds | External ❗️ |   |NO❗️ |
| └ | _unbindToken | Internal 🔒 | 🛑  | |
| └ | _bindToken | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
