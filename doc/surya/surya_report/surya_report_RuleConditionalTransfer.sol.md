## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./rules/operation/RuleConditionalTransfer.sol | d6c1c14a4196e7582019e913f409416d118edbd8 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleConditionalTransfer** | Implementation | RuleValidateTransfer, IRuleOperation, RuleConditionalTransferOperator, MetaTxModuleStandalone |||
| └ | <Constructor> | Public ❗️ | 🛑  | MetaTxModuleStandalone |
| └ | operateOnTransfer | Public ❗️ | 🛑  | onlyRole |
| └ | createTransferRequest | Public ❗️ | 🛑  |NO❗️ |
| └ | createTransferRequestBatch | Public ❗️ | 🛑  |NO❗️ |
| └ | cancelTransferRequest | Public ❗️ | 🛑  |NO❗️ |
| └ | cancelTransferRequestBatch | Public ❗️ | 🛑  |NO❗️ |
| └ | getRequestTrade | Public ❗️ |   |NO❗️ |
| └ | getRequestByStatus | Public ❗️ |   |NO❗️ |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | canReturnTransferRestrictionCode | External ❗️ |   |NO❗️ |
| └ | messageForTransferRestriction | External ❗️ |   |NO❗️ |
| └ | _validateTransfer | Internal 🔒 |   | |
| └ | _cancelTransferRequest | Internal 🔒 | 🛑  | |
| └ | _validateBurnMint | Internal 🔒 |   | |
| └ | _validateApproval | Internal 🔒 |   | |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
