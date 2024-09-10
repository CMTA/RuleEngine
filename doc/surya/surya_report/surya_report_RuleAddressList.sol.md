## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./rules/validation/abstract/RuleAddressList/RuleAddressList.sol | c967eb21311041eb58c7feb097a6224ec34b0c82 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleAddressList** | Implementation | AccessControl, MetaTxModuleStandalone, RuleAddressListInternal, RuleAddressListInvariantStorage |||
| └ | <Constructor> | Public ❗️ | 🛑  | MetaTxModuleStandalone |
| └ | addAddressesToTheList | Public ❗️ | 🛑  | onlyRole |
| └ | removeAddressesFromTheList | Public ❗️ | 🛑  | onlyRole |
| └ | addAddressToTheList | Public ❗️ | 🛑  | onlyRole |
| └ | removeAddressFromTheList | Public ❗️ | 🛑  | onlyRole |
| └ | numberListedAddress | Public ❗️ |   |NO❗️ |
| └ | addressIsListed | Public ❗️ |   |NO❗️ |
| └ | addressIsListedBatch | Public ❗️ |   |NO❗️ |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
