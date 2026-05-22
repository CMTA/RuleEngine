## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./modules/ERC3643ComplianceExtendedModule.sol | 4afe34c0d43a0b0ba2e6f2ac77cdc7af3012b23d |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **ERC3643ComplianceExtendedModule** | Implementation | ERC3643ComplianceModule, IERC3643ComplianceExtended |||
| └ | bindTokens | Public ❗️ | 🛑  | onlyComplianceManager |
| └ | unbindTokens | Public ❗️ | 🛑  | onlyComplianceManager |
| └ | setTokenSelfBindingApproval | Public ❗️ | 🛑  | onlyComplianceManager |
| └ | setTokenSelfBindingApprovalBatch | Public ❗️ | 🛑  | onlyComplianceManager |
| └ | isTokenSelfBindingApproved | Public ❗️ |   |NO❗️ |
| └ | getTokenBounds | Public ❗️ |   |NO❗️ |
| └ | _authorizeComplianceBindingChange | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
