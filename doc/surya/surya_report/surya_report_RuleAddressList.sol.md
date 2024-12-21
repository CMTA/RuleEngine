## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./rules/validation/abstract/RuleAddressList/RuleAddressList.sol | a5490babb4ea88b10fd8d5adfceafb4f14fae5e3 |


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
| └ | hasRole | Public ❗️ |   |NO❗️ |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
