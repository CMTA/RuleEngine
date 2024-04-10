## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./rules/operation/RuleConditionalTransfer.sol | 474d9ae65276913c7b367dbf47439e3a0558cf7a |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleConditionalTransfer** | Implementation | RuleValidateTransfer, IRuleOperation, RuleConditionalTransferOperator, MetaTxModuleStandalone |||
| └ | <Constructor> | Public ❗️ | 🛑  | MetaTxModuleStandalone |
| └ | createTransferRequest | Public ❗️ | 🛑  |NO❗️ |
| └ | cancelTransferRequest | Public ❗️ | 🛑  |NO❗️ |
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
