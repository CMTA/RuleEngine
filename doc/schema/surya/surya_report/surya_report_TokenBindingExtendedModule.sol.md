## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/TokenBindingExtendedModule.sol | d04d9b119b3a34f264d56830a6f41e57d9bc11de |


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
