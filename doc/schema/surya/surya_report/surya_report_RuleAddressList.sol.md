## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./mocks/rules/validation/abstract/RuleAddressList/RuleAddressList.sol | b7592fbe098734a0b6ebb5524fbf4878bf7294db |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **RuleAddressList** | Implementation | AccessControl, ERC2771ModuleStandalone, RuleAddressListInternal, RuleAddressListInvariantStorage |||
| └ | <Constructor> | Public ❗️ | 🛑  | ERC2771ModuleStandalone |
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
