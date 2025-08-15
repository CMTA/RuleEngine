## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./mocks/rules/operation/RuleConditionalTransferLight.sol | 563d9f2f21be53c588c4605313e344de5b74bf36 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleConditionalTransferLight** | Implementation | AccessControl, RuleConditionalTransferLightInvariantStorage, IRule |||
| └ | <Constructor> | Public ❗️ | 🛑  |NO❗️ |
| └ | approveTransfer | Public ❗️ | 🛑  | onlyRole |
| └ | approvedCount | Public ❗️ |   |NO❗️ |
| └ | transferred | Public ❗️ | 🛑  |NO❗️ |
| └ | transferred | Public ❗️ | 🛑  |NO❗️ |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | detectTransferRestrictionFrom | Public ❗️ |   |NO❗️ |
| └ | canReturnTransferRestrictionCode | External ❗️ |   |NO❗️ |
| └ | messageForTransferRestriction | External ❗️ |   |NO❗️ |
| └ | canTransfer | Public ❗️ |   |NO❗️ |
| └ | canTransferFrom | Public ❗️ |   |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
