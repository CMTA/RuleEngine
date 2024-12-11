## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./rules/operation/RuleConditionalTransfer.sol | eaf4569f1376ea3e0d975f9c9c1c5e078abf0c8d |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleConditionalTransfer** | Implementation | RuleValidateTransfer, IRuleOperation, RuleConditionalTransferOperator, MetaTxModuleStandalone |||
| └ | <Constructor> | Public ❗️ | 🛑  | MetaTxModuleStandalone |
| └ | createTransferRequest | Public ❗️ | 🛑  |NO❗️ |
| └ | createTransferRequestBatch | Public ❗️ | 🛑  |NO❗️ |
| └ | cancelTransferRequest | Public ❗️ | 🛑  |NO❗️ |
| └ | cancelTransferRequestBatch | Public ❗️ | 🛑  |NO❗️ |
| └ | _cancelTransferRequest | Internal 🔒 | 🛑  | |
| └ | getRequestTrade | Public ❗️ |   |NO❗️ |
| └ | getRequestByStatus | Public ❗️ |   |NO❗️ |
| └ | operateOnTransfer | Public ❗️ | 🛑  | onlyRole |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | canReturnTransferRestrictionCode | External ❗️ |   |NO❗️ |
| └ | messageForTransferRestriction | External ❗️ |   |NO❗️ |
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
