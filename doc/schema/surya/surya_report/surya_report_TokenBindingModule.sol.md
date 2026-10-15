## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/TokenBindingModule.sol | 290217014db5b97af70da677d27a410d8bff13a8 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **TokenBindingModule** | Implementation | Context, ITokenBinding, TokenBindingModuleInvariantStorage |||
| └ | bindToken | Public ❗️ | 🛑  |NO❗️ |
| └ | unbindToken | Public ❗️ | 🛑  |NO❗️ |
| └ | isTokenBound | Public ❗️ |   |NO❗️ |
| └ | _bindToken | Internal 🔒 | 🛑  | |
| └ | _checkBindingTarget | Internal 🔒 |   | |
| └ | _unbindToken | Internal 🔒 | 🛑  | |
| └ | _authorizeTokenBindingChange | Internal 🔒 | 🛑  | |
| └ | _onlyTokenBindingManager | Internal 🔒 | 🛑  | |
| └ | _checkBoundToken | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
