## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| /home/ryan/Pictures/dev/RE-new/RuleEngineNew/src/modules/ERC3643ComplianceExtendedModule.sol | b724099045f572c919a690c34d113af3c0855ffc |


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
