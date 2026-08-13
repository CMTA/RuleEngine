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



### v3.0.0-rc5

### Changed

- `ERC3643ComplianceModule._bindToken` / `_unbindToken`: rely on the `EnumerableSet` mutation return value instead of a preceding `contains()` lookup, keeping the `TokenAlreadyBound` / `TokenNotBound` diagnostics (269 gas measured).
- `_bindToken`, `_unbindToken` and `RuleEngineBase._supportsRuleEngineBaseInterface` are now `virtual`, along with the remaining non-`virtual` internals in the mock rules, per the project convention.
- `RuleAddressList.addressIsListedBatch`: `memory` parameter changed to `calldata` (587 gas measured for 10 addresses).
- Deployment now emits `SetMaxRules` with the initial cap, so the event log alone is sufficient to reconstruct `maxRules`.
- `RulesManagementModule`: the rule-cap write and its event moved into a new `internal virtual _setMaxRules(uint256)`, called by `setMaxRules` and by the deployable contracts' constructors. `_maxRules` is now written from a single place, so the invariant "every change to the cap emits `SetMaxRules`" holds structurally rather than by convention, and the non-zero check guards every path including construction.
- `RulesManagementModule`: rule insertion moved into a new `internal virtual _addRule(IRule)`, called by `addRule` and by the `setRules` loop. `AddRule` is now emitted from a single site. The `maxRules` cap is deliberately checked by the callers, since `addRule` checks per insertion while `setRules` checks the whole batch up front.

### Added

- Add `ERC3643TokenMock`: a minimal ERC-3643 (T-REX) style token whose compliance interaction mirrors `Token.sol` from the reference implementation, used to test the RuleEngine through the ERC-3643 entry points (`setCompliance` self-binding, `transferred`, `created`, `destroyed`).
- Add `ERC3643TokenIntegration.t.sol` (11 tests), including a regression guard for the H-1 mint pre-check fail-open and one pinning the requirement that `address(0)` be whitelisted for an ERC-3643 token to mint.

- **Renamed the reference rules in `src/mocks/rules/` with a `Mock` suffix**, so a reader cannot mistake them for the production rules of the same name maintained in [CMTA/Rules](https://github.com/CMTA/Rules): `RuleWhitelist` -> `RuleWhitelistMock`, `RuleConditionalTransferLight` -> `RuleConditionalTransferLightMock`, `RuleMintAllowance` -> `RuleMintAllowanceMock`, `RuleOperationRevert` -> `RuleOperationRevertMock`. Files renamed to match. The abstract bases and invariant-storage contracts they build on are unchanged, as they are not themselves rules.

### Removed

- `RuleEngine_ERC3643Compliance_OperationNotSuccessful`: unreachable after the bind/unbind simplification and referenced nowhere else.

### Documentation

- Document that the ERC-1404 3-argument `canTransfer` / `detectTransferRestriction` path fails open for spender-dependent rules, and that `canTransferFrom` / `detectTransferRestrictionFrom` must be used to pre-check an operation that has an operator.
- Add the code-quality review in [doc/security/audits/tools/v3.0.0-rc5/CLAUDE_ANALYSIS.md](./doc/security/audits/tools/v3.0.0-rc5/CLAUDE_ANALYSIS.md).
- Add integration guides in `doc/technical`: [RuleEngine-with-CMTAT.md](./doc/technical/RuleEngine-with-CMTAT.md) and [RuleEngine-with-ERC3643.md](./doc/technical/RuleEngine-with-ERC3643.md), covering entry points, configuration, warnings, limitations and test coverage for each token standard.
- Add the script review in [doc/security/audits/tools/v3.0.0-rc5/CLAUDE_ANALYSIS_SCRIPT.md](./doc/security/audits/tools/v3.0.0-rc5/CLAUDE_ANALYSIS_SCRIPT.md).
- Add the v3.0.0-rc5 Slither and Aderyn reports with their assessment feedback, each prefixed with a summary table of findings and dispositions.
- Add [doc/security/audits/AUDIT_OVERVIEW.md](./doc/security/audits/AUDIT_OVERVIEW.md) indexing every analysis performed, the static-analysis results per tool, and the substantive findings that were fixed.

### Fixed

- `RuleEngineScript.s.sol`: the CMTAT token is now bound to the engine (passed to the constructor). Previously the script produced a deployment in which every transfer, mint and burn reverted with `RuleEngine_ERC3643Compliance_UnauthorizedCaller`, because the token was never bound.
- `RuleEngineScript.s.sol`: `setRuleEngine` is now called through the typed interface instead of a low-level `.call` guarded by a bare `require(success)`. The previous form returned success when `CMTAT_ADDRESS` held no code, silently producing an unconfigured deployment, and discarded the revert reason on failure.
- `RuleEngineScript.s.sol`: the demo whitelist is now seeded with the deployer and `address(0)`, so the resulting deployment can transfer, mint and burn as-is.
- `test/script/RuleEngineScript.t.sol`: asserts the resulting deployment works (engine set, token bound, rule configured, a real mint) instead of only that `run()` does not revert.
- `doc/script/script_surya_*.sh`: fixed the shebang (`#/bin/bash` -> `#!/bin/bash`), the undefined `$dir` loop variable, `mkdir` without `-p` in the report script, and the output-directory guard in the inheritance script; added `set -euo pipefail` and null-delimited `find` iteration to all three. The loop iterates `find .` rather than an absolute path on purpose: `surya mdreport` embeds the path it is given, so an absolute one would write machine-specific paths into the committed reports under `doc/schema/surya/surya_report`.
- `package.json`: the `surya:*` and `uml:*` scripts now write beneath `docOut/` (gitignored) instead of the repository root.
- `doc/script/convert_links_for_pdf.sh`: the default input is now `doc/README.md` (the full documentation) rather than the short root README.

### Dependencies

- Update CMTAT submodule to [v3.3.0-rc3](https://github.com/CMTA/CMTAT/releases/tag/v3.3.0-rc3).
- Update OpenZeppelin Contracts and OpenZeppelin Contracts Upgradeable submodules to [v5.7.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.7.0).

### v3.0.0-rc4 - 2026-05-22

Commit: `66fcf2aafebd1f9d9de8a81dec92b88da071c9b3`

### Added

- Add `RuleMintAllowance` mock rule: admin-controlled per-minter mint allowance with `setMintAllowance(address, uint256)`, enforcement in `transferred(spender, from, to, value)` when `from == address(0)`, and `CODE_MINTER_INSUFFICIENT_ALLOWANCE` (code 81).
- Add `ERC3643ComplianceModuleInvariantStorage` in `src/modules/library/` to hold all `RuleEngine_ERC3643Compliance_*` custom errors, following the invariant storage pattern already used by `RulesManagementModule`.
- Add `ERC3643ComplianceRolesStorage` in `src/modules/library/` as a dedicated contract for `COMPLIANCE_MANAGER_ROLE`, separating role constants from error/event declarations.

### Changed

- `ERC3643ComplianceModule` now inherits `ERC3643ComplianceModuleInvariantStorage` and `ERC3643ComplianceRolesStorage`; errors and role constant are no longer declared inline.
- `RuleWhitelist.detectTransferRestrictionFrom`: spender check is now skipped for mint (`from == address(0)`) and burn (`to == address(0)`) operations, as the operator in those cases is the authorized minter/burner rather than a delegated spender.
- `RuleWhitelist.transferred` (both overloads): removed `view` modifier to match the intended mutable-callback semantics of the `IRule` interface.
- `RuleMintAllowance.transferred(address, address, uint256)`: removed `view` modifier for the same reason.
- `COMPLIANCE_MANAGER_ROLE` moved from inline declaration in `ERC3643ComplianceModule` to `ERC3643ComplianceRolesStorage`.
- `VersionModule.VERSION` constant visibility changed from `private` to `internal` to allow direct access by inheriting contracts and tests.
- `IRulesManagementModule.containsRule` now correctly declares `view`.
- `IRulesManagementModule.setMaxRules` NatSpec documents that high cap values re-expose O(n) gas cost for administrative operations such as `clearRules`.
- `IRulesManagementModule.clearRules` NatSpec updated to reflect O(n) cost relative to rule count and the interaction with `maxRules`.
- `RulesManagementModule.setRules` NatSpec now documents that `ClearRules` is emitted when replacing a non-empty rule set, in addition to `AddRule` per new rule.
- `RuleWhitelist` imports converted from plain imports with forge-lint suppression comments to named imports.
- `RuleEngineOwnable2Step` constructor now has full `@notice`/`@param` NatSpec.
- `RuleEngine.grantRole` NatSpec documents the intentional asymmetry: the check prevents granting roles to current rules but does not prevent adding a privileged address as a rule afterwards.
- `ERC3643ComplianceModule.bindToken` and `ERC3643ComplianceExtendedModule.bindTokens` now carry a `@custom:security-note` warning about cross-token state contamination in multi-tenant setups with stateful/operation rules.

### Documentation

- CLAUDE.md / AGENTS.md:
  - Inheritance hierarchy corrected to show `ERC3643ComplianceExtendedModule` → `ERC3643ComplianceModule` → `ERC3643ComplianceModuleInvariantStorage`.
  - Access control pattern section now documents the `_onlyRulesLimitManager` hook alongside `_onlyRulesManager` and `_onlyComplianceManager`.
  - Rule Execution Flow diagram extended with `created` and `destroyed` ERC-3643 entry points.
- README:
  - CMTAT target version updated to v3.3.0 in both the compatibility table and the dependencies section.
  - "Like CMTAT" section rewritten to document the v3.3.0 spender path for mint and burn, with an operation/address table and a rule-authoring note.
  - `bindToken`/`unbindToken` function table updated to reflect `COMPLIANCE_MANAGER_ROLE or approved token self-call` access path.

### Dependencies

- Update CMTAT submodule to v3.3.0-rc1.

### v3.0.0-rc3 - 2026-05-07

Commit: `5827604be4e38f65c055a929c7b62462a20f4bbd`

### Security

- Enforce an on-chain maximum rule count in `RulesManagementModule` to mitigate transfer liveness risk from unbounded per-transfer rule iteration (Nethermind AuditAgent finding 3 follow-up).
- Add cap checks in both `addRule` and `setRules`, reverting with `RuleEngine_RulesManagementModule_MaxRulesExceeded(uint256)` when exceeded.
- Enforce on-chain privilege-separation for rule accounts:
  - `RuleEngine.grantRole` now reverts for any role when `account` is currently in the rules set.
  - `RuleEngineOwnable` and `RuleEngineOwnable2Step` now reject `transferOwnership` targets that are currently in the rules set.
- Add T-REX compatibility path for compliance binding operations with admission control:
  - token self-calls (`msg.sender == token`) for `bindToken(token)` / `unbindToken(token)` are supported only when explicitly approved.
  - unapproved token self-calls are rejected and still require manager/owner authorization.

### Added

- Add `maxRules()` and `setMaxRules(uint256)` to `IRulesManagementModule`.
- Add `DEFAULT_MAX_RULES = 10` and initialize module state with this default cap.
- Add `SetMaxRules(uint256)` event emitted on cap updates.
- Add interface ID libraries:
  - `ERC1404InterfaceId` for `IERC1404` (`0xab84a5c8`)
  - `OwnableInterfaceId` for `IERC173` (`0x7f5828d0`)
  - `Ownable2StepInterfaceId` for Ownable2Step-specific methods (`0x9ab669ef`)
- Add dedicated access-control hook for cap governance:
  - `RuleEngine`: `DEFAULT_ADMIN_ROLE` can update cap.
  - `RuleEngineOwnable` and `RuleEngineOwnable2Step`: owner can update cap.
- Add `RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges()` error for rule-account privilege/ownership target protection.
- Add token self-binding approval management to `IERC3643ComplianceExtended` / `ERC3643ComplianceExtendedModule`:
  - `setTokenSelfBindingApproval(address token, bool approved)`
  - `isTokenSelfBindingApproved(address token)`
  - `TokenSelfBindingApprovalSet(address indexed token, bool approved)` event.
- Add batch self-binding approval API in `IERC3643ComplianceExtended` / `ERC3643ComplianceExtendedModule`:
  - `setTokenSelfBindingApprovalBatch(address[] tokens, bool approved)`.
  - `TokenSelfBindingApprovalBatchSet(address[] tokens, bool approved)` event.

### Changed

- Ownable variants now rely on OpenZeppelin `ERC165` inheritance in `RuleEngineOwnableShared` for base ERC-165 advertisement and extend it with RuleEngine + ERC-173 interface IDs.
- `supportsInterface` advertisement now explicitly includes `IERC1404` in addition to `IERC1404Extend`.
- `RuleEngineOwnable2Step.supportsInterface` now advertises the Ownable2Step-specific interface ID in addition to inherited RuleEngine/Ownable interfaces.
- `ERC3643ComplianceModule` authorization logic now requires explicit per-token approval for token-driven self-bind/self-unbind flows.
- Split compliance interfaces between standard and extensions:
  - `IERC3643Compliance` now contains the base ERC-3643 compliance surface.
  - supplementary functions are grouped in `IERC3643ComplianceExtended` and advertised through a dedicated ERC-165 extension interface ID.
- Split compliance modules between standard and extensions:
  - `ERC3643ComplianceModule` now contains the base ERC-3643 compliance surface.
  - supplementary functions are grouped in `ERC3643ComplianceExtendedModule`.
- Batch self-binding approval event emission now uses a single batch event (`TokenSelfBindingApprovalBatchSet`) per call instead of per-token `TokenSelfBindingApprovalSet` emissions.

### Testing

- Add tests for default cap value, cap enforcement for `addRule` and `setRules`, and access control on `setMaxRules`.
- Add event-emission coverage for `SetMaxRules`.
- Extend interface advertisement tests to validate interface IDs through both:
  - library constants
  - `type(<mock interface>).interfaceId`
  for `IERC1404` and `IERC173`.
- Extend `RuleEngineOwnable2Step` interface support tests to assert:
  - library constant support (`Ownable2StepInterfaceId.IOWNABLE2STEP_INTERFACE_ID`)
  - mock interface support (`type(IOwnable2StepSubset).interfaceId`).
- Add RBAC tests ensuring roles cannot be granted to rule accounts.
- Add ownable and ownable2step tests ensuring ownership cannot be transferred to rule accounts.
- Add compliance-binding authorization tests across RBAC/ownable/ownable2step variants for:
  - approved token self-bind
  - approved token self-unbind
  - unapproved token self-bind/self-unbind denial
  - cross-token bind/unbind denial
- Add tests for self-binding approval management across RBAC/ownable/ownable2step variants:
  - single approval set
  - batch approval set
  - zero-address rejection
  - unauthorized caller rejection.
- Add ERC-3643 `setCompliance`-style migration test with a dedicated mock token to validate unbind(old) + bind(new) flow against RuleEngine self-binding approval controls.

### Documentation

- Clarify README multi-token guidance with explicit data-plane vs control-plane wording:
  - data-plane = runtime compliance callbacks (`transferred`, `created`, `destroyed`)
  - control-plane = governance/configuration actions (`bindToken`, `unbindToken`, role grants, ownership changes, and rule management)
- Document that token-privilege separation in multi-token setups is an operational recommendation (not enforced on-chain) to preserve integrator flexibility for token-driven control-plane extensions.
- Document ERC-3643 `setCompliance` compatibility details in README:
  - token self-bind/self-unbind feature support
  - required explicit self-binding approval
  - recommended operational sequence for compliance migration.

### v3.0.0-rc2 - 2026-04-14

Commit: `ec4a24a96ca30e2ef8f79a06e49846a431e9b4b1`

### Dependencies

- Update CMTAT submodule to [v3.2.0](https://github.com/CMTA/CMTAT/releases/tag/v3.2.0).
- Update OpenZeppelin Contracts and OpenZeppelin Contracts Upgradeable submodules to [v5.6.1](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.6.1).
- Set Solidity version to [0.8.34](https://docs.soliditylang.org/en/v0.8.34/) in `hardhat.config.js` and `foundry.toml`.
- Standardize local OpenZeppelin imports on `@openzeppelin/contracts/...` and remove the legacy `OZ/` remapping to avoid Hardhat source-name collisions.

### Fixed

- `RuleEngineOwnable.supportsInterface` incorrectly advertised `IAccessControl` via the inherited `AccessControl.supportsInterface` fallback. Replaced with an explicit whitelist; `supportsInterface(IAccessControl)` now returns `false` as expected (Nethermind AuditAgent finding 2).
- Advertise ERC-3643 compliance interface ID (`0x3144991c`) and IERC7551Compliance subset interface ID (`0x7157797f`) in `supportsInterface` for both `RuleEngine` and `RuleEngineOwnable` (Nethermind AuditAgent finding 6).
- Fix Hardhat compatibility after the OpenZeppelin upgrade by removing duplicate import namespaces that resolved to the same file under `hardhat-foundry`.
- Fix `hardhat.config.js` Solidity config shape so Hardhat applies the configured optimizer and EVM target instead of falling back to defaults.

### Added

- Move deployable contracts to `src/deployment/` and rename RBAC deployable contract `RuleEngine` to `RuleEngine`.
- `RuleEngine.supportsInterface` now advertises `IAccessControlEnumerable`.

### Changed

- Switch `RuleEngine` RBAC base from OpenZeppelin `AccessControl` to `AccessControlEnumerable` while keeping the custom "default admin has all roles" behavior.
- Remove `AccessControl` inheritance from `RulesManagementModule`; RBAC responsibilities are now explicitly held by `RuleEngine`, while the module remains access-control agnostic.

### Security

- Add NatSpec and README warnings on `bindToken` / `unbindToken`: in a multi-tenant setup (multiple tokens sharing one engine), all bound tokens must be equally trusted and governed together; ERC-3643 callbacks do not carry the token address to rules (Nethermind AuditAgent finding 1).
- Add NatSpec warnings on `addRule`, `setRules`, and `_transferred`: rule contracts must not be granted `RULES_MANAGEMENT_ROLE` or admin privileges (Nethermind AuditAgent finding 5).
- Add NatSpec warnings on `addRule`, `setRules`, and `_transferred`: no on-chain maximum rule count is enforced; operators are responsible for sizing the rule set for the target chain gas limits (Nethermind AuditAgent finding 3).
- Add restriction-code uniqueness convention to `IRule.canReturnTransferRestrictionCode` and `_messageForTransferRestriction`: codes must be unique across rules, or rules sharing a code must return the same message (Nethermind AuditAgent finding 4).
- Add NatSpec on `setRules` documenting the empty-array rejection by design and referring to `clearRules` for explicit removal (Nethermind AuditAgent finding 7).

### Testing

- Add `testDoesNotSupportIAccessControlInterface` to `RuleEngineOwnableCoverage` asserting `IAccessControl` is not advertised.
- Add ERC-3643 and IERC7551Compliance `supportsInterface` coverage tests to both `RuleEngineCoverage` and `RuleEngineOwnableCoverage`.
- Add mock interfaces `src/mocks/ICompliance.sol` and `src/mocks/IERC7551ComplianceSubset.sol` used by coverage tests.
- Extend `RuleEngineDeployment` interface coverage to assert support for `IAccessControlEnumerable`.
- Add a small Hardhat smoke test (`test/hardhat/RuleEngine.smoke.js`) to confirm `RuleEngine` can be compiled, deployed, and queried through Hardhat.
- Add the npm script `test:hardhat` to run the Hardhat smoke test directly.

### Documentation

- Add Nethermind AuditAgent scan #1 report and remediation assessment (`doc/security/audits/tools/nethermind-audit-agent/`).
- Update README Security section with Nethermind AuditAgent findings summary table.
- Update README toolchain and testing sections to mention Hardhat compilation support and the small Hardhat smoke test.

### v3.0.0-rc1 - 2026-02-16

Commit: `f3e27c190635e91a64215276f4757d65eb2d2b2c`

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

Commit: `f3283c3b8a99089c3c6f674150831003a6bd2927`

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
