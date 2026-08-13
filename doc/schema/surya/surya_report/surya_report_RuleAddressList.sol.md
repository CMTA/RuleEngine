## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./mocks/rules/validation/abstract/RuleAddressList/RuleAddressList.sol | 5799cfc64c654417d2dc429ab3ff09a947858799 |


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
