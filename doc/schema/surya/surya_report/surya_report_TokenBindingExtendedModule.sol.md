## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/TokenBindingExtendedModule.sol | e1440bc3566811a018a53341f62f5ea2b350eff4 |


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
