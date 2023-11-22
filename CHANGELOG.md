# CHANGELOG

Please follow [https://changelog.md/](https://changelog.md/) conventions.

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
- 🎉 first release!
