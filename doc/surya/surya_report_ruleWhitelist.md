## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| src/RuleWhitelist.sol | d2514418c3f9a7255fcabba400edfb8a85d7c076 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleWhitelist** | Implementation | IRule, AccessControl, MetaTxModuleStandalone |||
| └ | <Constructor> | Public ❗️ | 🛑  | MetaTxModuleStandalone |
| └ | addAddressesToTheWhitelist | Public ❗️ | 🛑  | onlyRole |
| └ | removeAddressesFromTheWhitelist | Public ❗️ | 🛑  | onlyRole |
| └ | addAddressToTheWhitelist | Public ❗️ | 🛑  | onlyRole |
| └ | removeAddressFromTheWhitelist | Public ❗️ | 🛑  | onlyRole |
| └ | numberWhitelistedAddress | External ❗️ |   |NO❗️ |
| └ | addressIsWhitelisted | External ❗️ |   |NO❗️ |
| └ | validateTransfer | Public ❗️ |   |NO❗️ |
| └ | detectTransferRestriction | Public ❗️ |   |NO❗️ |
| └ | canReturnTransferRestrictionCode | External ❗️ |   |NO❗️ |
| └ | messageForTransferRestriction | External ❗️ |   |NO❗️ |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
