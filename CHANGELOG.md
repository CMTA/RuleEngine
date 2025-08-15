# CHANGELOG

Please follow [https://changelog.md/](https://changelog.md/) conventions.

## Checklist

> Before a new release, perform the following tasks

- Code: Update the version name, variable VERSION
- Run linter

> npm run-script lint:all:prettier

- Documentation
  - Perform a code coverage and update the files in the corresponding directory [./doc/coverage](./doc/coverage)
  - Perform an audit with several audit tools (Mythril and Slither), update the report in the corresponding directory [./doc/security/audits/tools](./doc/security/audits/tools)
  - Update surya doc by running the 3 scripts in [./doc/script](./doc/script)
  - Update changelog

## v3.0.0-rc0

- Rule contracts, requires to perform compliance check, have now their own dedicated [GitHub repository](https://github.com/CMTA/Rules). It means that these contract will be developed and audited separately from the `RuleEngine`. This provides more flexibility and makes it easier to manage audits.
- There is now only one type of rule (read-write rules). Before that:
  - First RuleEngine version (audited) had only one type of rule, read-only (whitelist, blacklist)
  - A second RuleEngine version (not audited) had two types of rules: operation (read-write) and validation (read-only).  A read-write rule is typically a ConditionalTransfer check which require each transfer must be pre-approved.
- Implement ERC-3643 compliance interface, which means that the RuleEngine can be also used with an ERC-3643 token to perform supplementary compliance check on transfer.
- Technical: 
  - Use [EnumerableSet](https://docs.openzeppelin.com/contracts/5.x/api/utils#EnumerableSet) from OpenZeppelin to store rules, which reduce the whole contract code size.
  - Rename several abstract contract
    - `RuleEngineOperation`-> `RulesManagementModule`
    - `MetaTxModuleStandalone` -> `ERC2771ModuleStandalone`

## v2.1.0

- Update RuleEngine to CMTAT v3.0.0-rc5

- Add "partial" support of spender check introduced with CMTAT v3.0.0-rc5

  - Change several functions
    - `operateOnTransfer `-> `transferred(...)`

  - Add functions `detectTransferRestrictionFrom` and `canTransferFrom`

## v2.0.5

- Fix a bug present in the Conditional Transfer rule and improve the corresponding tests.

## v2.0.4

- Fix a bug present in the Conditional Transfer rule and the corresponding test.
- Config file:
  - Set Solidity version to 0.8.27 in config file
  - Set EVM version to `Cancun`
- Add events for the following rules : whitelist/blacklist and sanctionList rules
- Some improvements in testing
  - Integration test with CMTAT: set the CMTAT version to [v2.5.1](https://github.com/CMTA/CMTAT/releases/tag/v2.5.1)
- Access control: The default admin has by default all the roles for the RuleEngine and the different rules

## v2.0.3 - 20240910

- Small optimization in WhitelistWrapper; add a break in a loop
- Set Solidity version to 0.8.26 in config file

## v2.0.2 - 20240617

- Create abstract contract ruleWhitelistCommon to contain code shared between ruleWhitelist & ruleWhitelistWrapper
- Split ADDRESS_LIST_ROLE in two distinct roles : ADDRESS_LIST_ADD_ROLE && ADDRESS_LIST_REMOVE_ROLE

## v2.0.1 - 20240611

- Add a new rule WhitelistWrapper

This rule can be used to restrict transfers from/to only addresses inside a group of whitelist rules managed by different operators.

## v2.0.0 - 20240515

- Implement the new architecture for the RuleEngine, with ValidationRule and OperationRule
- Add the rule ConditionalTransfer as an Operation rule
- Add the rule Blacklist as a Validation rule
- Whitelist and blacklist rules share a part of their code.
- Upgrade the library CMTAT to the version [v2.4.0](https://github.com/CMTA/CMTAT/releases/tag/v2.4.0)
- Fix a minor bug when rules are deleted with clearRules

## v1.0.3 - 20231122

- Upgrade the library CMTAT to the version [v2.3.1](https://github.com/CMTA/CMTAT/releases/tag/v2.3.1)
- Use custom errors instead of revert message (gas optimization)
- Add the rule `SanctionList`
- Upgrade OpenZeppelin to the version [v5.0.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.0.0)

## v1.0.2 - 20230609

- Upgrade the library CMTAT to the vesion [v2.3.0](https://github.com/CMTA/CMTAT/releases/tag/v2.3.0)
- Set the number of runs for the optimizer to 200 for Hardhat and Foundry, see [https://docs.soliditylang.org/en/v0.8.17/using-the-compiler.html#optimizer-options](https://docs.soliditylang.org/en/v0.8.17/using-the-compiler.html#optimizer-options)

## 1.0.2-rc.0 - 20230523

The release 1.0.2 contains mainly the different fixes and improvements related to the audit performed on the version 1.0.1.

**Documentation**

- Update the documentation for the release
- Add slither report
- Install hardhat in order to generic docgen documentation

**General modifications**

- Upgrade the library CMTAT to the latest version [2.3.0-rc.0](https://github.com/CMTA/CMTAT/releases/tag/2.3-Beta) ([pull/28](https://github.com/CMTA/RuleEngine/pull/28))
  - In RuleEngine, `ruleLength` is changed to `rulesCount()`
- Add the gasless suport / MetaTx module ([pull/27](https://github.com/CMTA/RuleEngine/pull/27))
- RuleWhitelist: update RuleWhitelist to use code from IEIP1404Wrapper ([pull/29](https://github.com/CMTA/RuleEngine/pull/29))

**Audit report**

This version also includes improvements suggested by the audit report, addressing the following findings:

General

- CVF-10: use a floating pragma for the version ([pull/25](https://github.com/CMTA/RuleEngine/pull/25))
- CVF2, CVF-6: remove the function kill for the contracts RuleEngine and Whitelist ([pull/17](https://github.com/CMTA/RuleEngine/pull/17))

RuleEngine

- CVF-1 / removeRule: add an additional argument with the rule index hint ([pull/23](https://github.com/CMTA/RuleEngine/pull/23))
- CVF-7, CVF-8, CVF-9: check for duplicate rule ([pull/20](https://github.com/CMTA/RuleEngine/pull/20))

Whitelist

- CVF-3: use a local variable for iterate inside a loop ([pull/18/](https://github.com/CMTA/RuleEngine/pull/18/))
- CVF-4, CVF-5: remove useless conditional statement ([pull/19/](https://github.com/CMTA/RuleEngine/pull/19/))
- CVF-15, CVF-16, CVF-17: improve readibility ([pull/24](https://github.com/CMTA/RuleEngine/pull/24))

## 1.0.1 - 20230122

- Update the library CMTAT to the version [2.2](https://github.com/CMTA/CMTAT/releases/tag/2.2)
- Update the library OpenZeppelin to the version [4.8.1](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v4.8.1)
- Improve integration test with CMTAT    

## 1.0.0 - 20221114
- 🎉 first release!<
