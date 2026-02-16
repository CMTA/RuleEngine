# CHANGELOG

Please follow [https://changelog.md](https://changelog.md) conventions and the other conventions below

## Semantic Version 2.0.0

Given a version number MAJOR.MINOR.PATCH, increment the:

1. MAJOR version when the new version makes:
   -  Incompatible proxy **storage** change internally or through the upgrade of an external library (OpenZeppelin)
   -  A significant change in external APIs (public/external functions) or in the internal architecture
2. MINOR version when the new version adds functionality in a backward compatible manner
3. PATCH version when the new version makes backward compatible bug fixes

See [https://semver.org](https://semver.org)

## Type of changes

- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

Reference: [keepachangelog.com/en/1.1.0/](https://keepachangelog.com/en/1.1.0/)

Custom changelog tag: `Dependencies`, `Documentation`, `Testing`

## Checklist

> Before a new release, perform the following tasks

- Code: Update the version name, variable VERSION
- Run formatter and linter

```bash
forge fmt
forge lint
```

- Documentation
  - Perform a code coverage and update the files in the corresponding directory [./doc/coverage](./doc/coverage)
  - Perform an audit with several audit tools (Aderyn and Slither), update the report in the corresponding directory [./doc/security/audits/tools](./doc/security/audits/tools)
  - Update surya doc by running the 3 scripts in [./doc/script](./doc/script)
  - Update changelog

## v3.0.0-rc1 - 2026-02-16

### Added

- Add `RuleEngineOwnable` contract variant using ERC-173 ownership (`Ownable`) as an alternative to the RBAC-based `RuleEngine`. ERC-3643 compliance specification recommends ERC-173 for ownership.
- Add ERC-165 `supportsInterface` check when adding rules via `addRule` / `setRules`, ensuring that only valid rule contracts (implementing `IRule`) can be registered.
- Use CMTAT library for ERC-165 interface ID constants (`RuleEngineInterfaceId`, `ERC1404ExtendInterfaceId`).
- Add compatibility with CMTAT v3.0.0 and v3.2.0-rc0 (dual-version test support via `CMTATDeploymentV3`).

### Fixed

- Fix deployment script `CMTATWithRuleEngineScript`: deploy CMTAT with the deployer as admin instead of a hardcoded address, which caused `setRuleEngine` to revert with `AccessControlUnauthorizedAccount`.
- Remove dead code in `RuleEngineOwnable` constructor: the custom zero-address owner check was unreachable because `Ownable(owner_)` already reverts with `OwnableInvalidOwner(address(0))`.
- Remove duplicate code across rule contracts.

### Dependencies

- Update CMTAT library to [v3.2.0-rc0](https://github.com/CMTA/CMTAT)
- Update OpenZeppelin Contracts to [v5.4.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.4.0)
- Update Foundry (forge-std) to [v1.10.0](https://github.com/foundry-rs/forge-std/releases/tag/v1.10.0)
- Set Solidity version to [0.8.33](https://docs.soliditylang.org/en/v0.8.33/) and EVM version to Prague (Pectra upgrade)

### Code quality

- Resolve all `forge lint` warnings: convert plain imports to named imports, remove unused imports, rename variables/functions to mixedCase, refactor modifier logic, and add targeted lint suppressions where appropriate.
- Replace Prettier and Ethlint/Solium with Foundry-native `forge fmt` and `forge lint` for formatting and linting.
- Run `forge fmt` on the entire codebase.

### Testing

- Add deployment script tests (`test/script/`) for `CMTATWithRuleEngineScript` and `RuleEngineScript`.
- Add `RuleEngineOwnable` test suite: deployment, access control, ERC-3643 compliance, rules management, and coverage tests.
- Add `IRuleInterfaceId` test for ERC-165 interface ID computation.
- Add integration tests with CMTAT v3.0.0 and v3.2.0-rc0.
- Improve code coverage with additional edge-case tests.

### Documentation

- Expand README with contract variants comparison, constructor API, access control details, and ERC-173 ownership documentation.
- Add formatting & linting section to README and TOOLCHAIN documentation.
- Update surya diagrams, coverage reports, and specification documents.

## v3.0.0-rc0 - 2025-08-15

Commit: f3283c3b8a99089c3c6f674150831003a6bd2927

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

## v2.1.0 - 2025-07-04

- Update RuleEngine to CMTAT v3.0.0-rc5

- Add "partial" support of spender check introduced with CMTAT v3.0.0-rc5

  - Change several functions
    - `operateOnTransfer `-> `transferred(...)`

  - Add functions `detectTransferRestrictionFrom` and `canTransferFrom`

## v2.0.5 - 2024-12-21

- Fix a bug present in the Conditional Transfer rule and improve the corresponding tests.

## v2.0.4 - 2024-12-16

- Fix a bug present in the Conditional Transfer rule and the corresponding test.
- Config file:
  - Set Solidity version to 0.8.27 in config file
  - Set EVM version to `Cancun`
- Add events for the following rules : whitelist/blacklist and sanctionList rules
- Some improvements in testing
  - Integration test with CMTAT: set the CMTAT version to [v2.5.1](https://github.com/CMTA/CMTAT/releases/tag/v2.5.1)
- Access control: The default admin has by default all the roles for the RuleEngine and the different rules

## v2.0.3 - 2024-09-10

- Small optimization in WhitelistWrapper; add a break in a loop
- Set Solidity version to 0.8.26 in config file

## v2.0.2 - 2024-06-17

- Create abstract contract ruleWhitelistCommon to contain code shared between ruleWhitelist & ruleWhitelistWrapper
- Split ADDRESS_LIST_ROLE in two distinct roles : ADDRESS_LIST_ADD_ROLE && ADDRESS_LIST_REMOVE_ROLE

## v2.0.1 - 2024-06-11

- Add a new rule WhitelistWrapper

This rule can be used to restrict transfers from/to only addresses inside a group of whitelist rules managed by different operators.

## v2.0.0 - 2024-05-15

- Implement the new architecture for the RuleEngine, with ValidationRule and OperationRule
- Add the rule ConditionalTransfer as an Operation rule
- Add the rule Blacklist as a Validation rule
- Whitelist and blacklist rules share a part of their code.
- Upgrade the library CMTAT to the version [v2.4.0](https://github.com/CMTA/CMTAT/releases/tag/v2.4.0)
- Fix a minor bug when rules are deleted with clearRules

## v1.0.3 - 2023-11-22

- Upgrade the library CMTAT to the version [v2.3.1](https://github.com/CMTA/CMTAT/releases/tag/v2.3.1)
- Use custom errors instead of revert message (gas optimization)
- Add the rule `SanctionList`
- Upgrade OpenZeppelin to the version [v5.0.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.0.0)

## v1.0.2 - 2023-06-09

- Upgrade the library CMTAT to the vesion [v2.3.0](https://github.com/CMTA/CMTAT/releases/tag/v2.3.0)
- Set the number of runs for the optimizer to 200 for Hardhat and Foundry, see [https://docs.soliditylang.org/en/v0.8.17/using-the-compiler.html#optimizer-options](https://docs.soliditylang.org/en/v0.8.17/using-the-compiler.html#optimizer-options)

## 1.0.2-rc.0 - 2023-05-23

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

## 1.0.1 - 2023-01-22

- Update the library CMTAT to the version [2.2](https://github.com/CMTA/CMTAT/releases/tag/2.2)
- Update the library OpenZeppelin to the version [4.8.1](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v4.8.1)
- Improve integration test with CMTAT    

## 1.0.0 - 2022-11-14
- 🎉 first release!<
