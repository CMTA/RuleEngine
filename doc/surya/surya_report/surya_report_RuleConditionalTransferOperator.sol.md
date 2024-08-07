## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./rules/operation/abstract/RuleConditionalTransferOperator.sol | 5e35d28ab99475759783fca1614544e132797487 |


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
