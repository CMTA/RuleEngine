## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./rules/operation/abstract/RuleConditionalTransferOperator.sol | dee2c32effd6ffa0da948f5a18219c8a7d4ebd14 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleConditionalTransferOperator** | Implementation | AccessControl, RuleConditionalTransferInvariantStorage |||
| └ | setConditionalWhitelist | Public ❗️ | 🛑  | onlyRole |
| └ | setIssuanceOptions | Public ❗️ | 🛑  | onlyRole |
| └ | setAutomaticTransfer | Public ❗️ | 🛑  | onlyRole |
| └ | setTimeLimit | Public ❗️ | 🛑  | onlyRole |
| └ | setAutomaticApproval | Public ❗️ | 🛑  | onlyRole |
| └ | createTransferRequestWithApproval | Public ❗️ | 🛑  | onlyRole |
| └ | approveTransferRequest | Public ❗️ | 🛑  | onlyRole |
| └ | approveTransferRequestWithId | Public ❗️ | 🛑  | onlyRole |
| └ | resetRequestStatus | Public ❗️ | 🛑  | onlyRole |
| └ | approveTransferRequestBatchWithId | Public ❗️ | 🛑  | onlyRole |
| └ | approveTransferRequestBatch | Public ❗️ | 🛑  | onlyRole |
| └ | createTransferRequestWithApprovalBatch | Public ❗️ | 🛑  | onlyRole |
| └ | resetRequestStatusBatch | Public ❗️ | 🛑  | onlyRole |
| └ | _approveTransferRequestKeyElement | Internal 🔒 | 🛑  | |
| └ | _createTransferRequestWithApproval | Public ❗️ | 🛑  | onlyRole |
| └ | _resetRequestStatus | Internal 🔒 | 🛑  | |
| └ | _checkRequestStatus | Internal 🔒 |   | |
| └ | _approveRequest | Internal 🔒 | 🛑  | |
| └ | _updateProcessedTransfer | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
