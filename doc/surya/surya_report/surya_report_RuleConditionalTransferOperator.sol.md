## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./rules/operation/abstract/RuleConditionalTransferOperator.sol | 76e5a428623395575861a4d45bdc3f5b6f797f7e |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleConditionalTransferOperator** | Implementation | AccessControl, RuleConditionalTransferInvariantStorage |||
| └ | setIssuanceOptions | Public ❗️ | 🛑  | onlyRole |
| └ | setAutomaticTransfer | Public ❗️ | 🛑  | onlyRole |
| └ | setTimeLimit | Public ❗️ | 🛑  | onlyRole |
| └ | setAutomaticApproval | Public ❗️ | 🛑  | onlyRole |
| └ | createTransferRequestWithApproval | Public ❗️ | 🛑  | onlyRole |
| └ | approveTransferRequest | Public ❗️ | 🛑  | onlyRole |
| └ | approveTransferRequestWithId | Public ❗️ | 🛑  | onlyRole |
| └ | resetRequestStatus | Public ❗️ | 🛑  | onlyRole |
| └ | _resetRequestStatus | Internal 🔒 | 🛑  | |
| └ | _checkRequestStatus | Internal 🔒 |   | |
| └ | _approveRequest | Internal 🔒 | 🛑  | |
| └ | _updateProcessedTransfer | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
