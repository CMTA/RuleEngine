## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/TokenBindingExtendedModule.sol | 07e45e7ed920f4a2a7cc4e53ce13eef9de80549a |


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
| └ | _authorizeTokenBindingChange | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
