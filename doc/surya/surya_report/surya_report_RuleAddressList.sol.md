## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./rules/validation/abstract/RuleAddressList/RuleAddressList.sol | 7c34b72694e29bec42ce60e5d6c33971c583d109 |


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
