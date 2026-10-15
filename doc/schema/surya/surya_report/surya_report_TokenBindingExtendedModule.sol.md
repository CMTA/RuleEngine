## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/TokenBindingExtendedModule.sol | c0f9b420d08f54a7fc4c133f7e3a5d336b991710 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **TokenBindingExtendedModule** | Implementation | TokenBindingModule, ITokenBindingExtended |||
| └ | bindTokens | Public ❗️ | 🛑  | onlyTokenBindingManager |
| └ | unbindTokens | Public ❗️ | 🛑  | onlyTokenBindingManager |
| └ | setTokenSelfBindingApproval | Public ❗️ | 🛑  | onlyTokenBindingManager |
| └ | setTokenSelfBindingApprovalBatch | Public ❗️ | 🛑  | onlyTokenBindingManager |
| └ | isTokenSelfBindingApproved | Public ❗️ |   |NO❗️ |
| └ | getTokenBounds | Public ❗️ |   |NO❗️ |
| └ | _unbindToken | Internal 🔒 | 🛑  | |
| └ | _setTokenSelfBindingApproval | Internal 🔒 | 🛑  | |
| └ | _authorizeTokenBindingChange | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
