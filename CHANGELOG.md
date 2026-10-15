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

Custom changelog tag

- `breaking change`: breaking change regarding storage [ERC-7201](https://eips.ethereum.org/EIPS/eip-7201) namespace , as well as external engine
- `Dependencies` (npm package, openzeppelin,...)
- `Documentation`
- `Testing`

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



## v3.0.0 - Unreleased (pending audit)

Commit: to be added once the audit is done and the release is tagged.

> **Note:** this section summarises the main changes between **v2.1.0** and **v3.0.0**. It will be finalised, with the audit report and its findings, once the audit is done. Per-item details, tests and documentation are in the release-candidate entries below (`v3.0.0-rc0` to `v3.0.0-rc7`).

### Summary

v3.0.0 turns the RuleEngine into a generic compliance controller for both CMTAT and ERC-3643 tokens. There is a single rule type, and the rules themselves move to a dedicated repository. There are six deployable variants (RBAC, `Ownable` and `Ownable2Step`, each with or without ERC-2771), and tokens must be explicitly bound to the engine. On-chain safeguards bound the rule set and separate rule accounts from privileged ones.

### Breaking change

- **Rules are no longer part of this repository.** Production rules are developed and audited separately in [CMTA/Rules](https://github.com/CMTA/Rules); `src/mocks/rules/` only holds reference mocks (suffixed `Mock` since rc5). (rc0)
- **Single rule type.** The separate validation (read-only) and operation (read-write) rule lists are merged into one rule set, managed by `RulesManagementModule` (`addRule`, `removeRule`, `setRules`, `clearRules`, `rules`, `rule`, `rulesCount`, `containsRule`). `RuleEngineOperation` is renamed `RulesManagementModule` and `MetaTxModuleStandalone` `ERC2771ModuleStandalone`. (rc0)
- **Rules must implement `IRule` and advertise it through ERC-165** (`0x2497d6cb`); `addRule` / `setRules` reject any other contract. A v2.x rule cannot be added as is. (rc1)
- **Only bound tokens may call the engine.** `transferred`, `created` and `destroyed` revert with `TokenBinding_UnauthorizedCaller` unless the caller was bound, with `bindToken` or the constructor's `tokenContract` argument. A token's own `bindToken(this)` / `unbindToken(this)` (ERC-3643 `setCompliance`) requires a prior `setTokenSelfBindingApproval`. (rc0, rc3)
- **Rule-set cap.** `addRule` / `setRules` revert with `RuleEngine_RulesManagementModule_MaxRulesExceeded` above `maxRules` (default 10, changed with `setMaxRules`). (rc3)
- **Rule accounts cannot hold privileges.** `RuleEngine.grantRole` and the ownable variants' `transferOwnership` revert for an address in the rule set. (rc3)
- **Interfaces split.** The base ERC-3643 surface is in `IERC3643Compliance`, and the helpers (batch binding, self-binding approval, `getTokenBounds`) are in `IERC3643ComplianceExtended`. Binding moved to the standard-agnostic `ITokenBinding` / `ITokenBindingExtended`. Selectors and ERC-165 IDs of the existing functions are unchanged. (rc3, rc6)
- **Errors renamed.** `RuleEngine_ERC3643Compliance_*` became `TokenBinding_*`, which changes their selectors. (rc6)
- **RBAC base.** `RuleEngine` uses `AccessControlEnumerable` (still with "default admin has all roles"). The deployable contracts moved to `src/deployment/`. (rc2)
- **CMTAT v3.3.0 routing.** With CMTAT ≥ v3.3.0, mint, burn and the minter `batchTransfer` reach the engine on the 4-argument `transferred(spender, from, to, value)` with the operator as `spender`. Rules that check the spender must handle `from == address(0)` / `to == address(0)`. On CMTAT v3.0.0 – v3.2.0 those operations still use the 3-argument overload. (rc4, CMTAT side)
- **Compiler floor.** The CMTAT engine interfaces require `pragma ^0.8.24`, so the engine compiles with Solidity ≥ 0.8.24 despite its own `^0.8.20` pragma.
- **`version()`** returns the release string with its suffix while in release candidate (`"3.0.0-rc7"`). (rc7)
- **No storage change to migrate.** The RuleEngine is not upgradeable: moving from v2.x means deploying a new engine, re-adding the rules and re-pointing each token (`setRuleEngine` / `setCompliance`).

### Added

- **ERC-3643 compliance.** The engine implements `IERC3643Compliance` (`canTransfer`, `transferred`, `created`, `destroyed`, `bindToken`, `unbindToken`, `isTokenBound`, `getTokenBound`), so it can be set as the compliance contract of an ERC-3643 (T-REX) token. (rc0)
- **Two ownable variants:** `RuleEngineOwnable` (ERC-173 `Ownable`) and `RuleEngineOwnable2Step` (`Ownable2Step`), next to the RBAC `RuleEngine`. (rc1, rc2)
- **Each access-control model with or without ERC-2771:** `RuleEngine`, `RuleEngineOwnable` and `RuleEngineOwnable2Step` no longer have a trusted forwarder, and their constructors are `(admin|owner_, tokenContract)`; the new `RuleEngine2771`, `RuleEngineOwnable2771` and `RuleEngineOwnable2Step2771` carry an immutable forwarder, `(admin|owner_, forwarderIrrevocable, tokenContract)`, as the three contracts did up to rc6. (rc7)
- **Token binding registry**, reusable outside this project: `TokenBindingModule` / `TokenBindingExtendedModule`, with batch binding, `getTokenBounds()` and gated token self-binding (`setTokenSelfBindingApproval`, `setTokenSelfBindingApprovalBatch`, `isTokenSelfBindingApproved`). (rc3, rc6)
- **Rule-set cap:** `maxRules()`, `setMaxRules(uint256)` and the `SetMaxRules` event, emitted at deployment too. (rc3, rc5)
- **ERC-165 advertisement** of `IRuleEngine`, `IERC1404`, `IERC1404Extend`, `IERC3643Compliance` and its extension, `IERC7551Compliance` (subset), plus ERC-173 / `Ownable2Step` or `IAccessControl(Enumerable)` per variant. The IDs are computed from the interfaces and pinned by tests. (rc1–rc6)
- **Spender-aware path** (`transferred(spender, …)`, `canTransferFrom`, `detectTransferRestrictionFrom`), first added in v2.1.0 (partial support), and forwarded to every rule as part of CMTAT's `IRuleEngine`.

### Security

- Fixes and mitigations for the Nethermind AuditAgent scan findings 1–7: multi-tenant binding warning, `IAccessControl` no longer advertised by `RuleEngineOwnable`, missing interface IDs, the rule-count cap, rule accounts excluded from privileges, the restriction-code uniqueness convention, and the empty `setRules` documented. (rc2, rc3)
- Token self-binding requires explicit per-token approval, so an arbitrary contract cannot bind itself. (rc3)
- The trusted ERC-2771 forwarder can no longer act as a token: the bound-token gate and the token self-binding check compare `msg.sender`, while administration stays gasless. (rc7)
- Documented trust model: rules and every contract they call are trusted, and `transferred*` hooks must not make state-changing external calls. (rc7)

### Dependencies

- CMTAT: supports **≥ v3.0.0**, target **v3.3.0-rc4** (tested also against v3.0.0 via `lib/CMTATv3.0.0`). v2.1.0 targeted CMTAT v3.0.0-rc5.
- OpenZeppelin Contracts / Contracts Upgradeable **v5.7.0**.
- Solidity **0.8.37**, EVM **Osaka** (Fusaka upgrade).
- ERC-3643 reference implementation (tests only): T-REX **4.2.0-beta1**.

### Testing

- Test suites for all six deployable variants, CMTAT integration (current and v3.0.0), an ERC-3643 mock-token integration, and a real T-REX 4.2.0-beta1 suite in the `erc3643` Foundry profile. Also a Hardhat smoke test and tests pinning the deployment scripts and every ERC-165 interface ID.

### Documentation

- Full reference in `doc/README.md`, and integration guides `doc/technical/RuleEngine-with-CMTAT.md`, `RuleEngine-with-ERC3643.md` and `TokenBinding-module.md`.
- Static-analysis (Slither, Aderyn) and automated-review reports per release candidate, indexed in `doc/security/audits/AUDIT_OVERVIEW.md`.
- PlantUML flow and access-control diagrams, sol2uml and Surya diagrams.

### v3.0.0-rc7 - 2026-10-14

Commit: 

### Summary

Security hardening of the ERC-2771 token-identity checks, and ERC-2771 becomes opt-in: each access-control model is split into a contract without ERC-2771 (`RuleEngine`, `RuleEngineOwnable`, `RuleEngineOwnable2Step`) and a `*2771` contract with the trusted forwarder (`RuleEngine2771`, `RuleEngineOwnable2771`, `RuleEngineOwnable2Step2771`). The trusted forwarder can no longer pass as a token: the bound-token gate and the token self-binding check now compare `msg.sender`. The CMTAT submodule moves to v3.3.0-rc4 and the ERC-3643 submodule to T-REX 4.2.0-beta1, which is now tested end-to-end in a dedicated Foundry profile. The CMTAT / Rules documentation is corrected and completed. `version()` now carries the release-candidate suffix.

### Breaking change

- **ERC-2771 is now opt-in: `RuleEngine`, `RuleEngineOwnable` and `RuleEngineOwnable2Step` no longer support it, and their constructors drop the forwarder.** They are now `constructor(address admin, address tokenContract)` and `constructor(address owner_, address tokenContract)`, have no `isTrustedForwarder` / `trustedForwarder`, and treat every caller as the raw `msg.sender`. The versions with a trusted forwarder are the new **`RuleEngine2771`**, **`RuleEngineOwnable2771`** and **`RuleEngineOwnable2Step2771`**, whose constructors `(admin|owner_, forwarderIrrevocable, tokenContract)` and behaviour are those of the rc6 contracts without the suffix. Migration: a deployment that passed `address(0)` as forwarder drops the middle argument; one that passed a forwarder deploys the `*2771` contract. Deployment scripts in other repositories (for example CMTA/Rules) that call the 3-argument constructors must be updated.
- **Token callbacks and token self-binding are no longer relayable through the ERC-2771 forwarder.** `transferred`, `created` and `destroyed` (`onlyBoundToken`), and a token's own `bindToken` / `unbindToken(this)`, now identify the token by `msg.sender` instead of `_msgSender()`. A call that the trusted forwarder relays with a token address appended is rejected (`TokenBinding_UnauthorizedCaller`, or the binding-manager check for the self-binding path). Real tokens are unaffected, because they always call the engine directly. Only a setup that relayed token callbacks through the forwarder breaks, and no legitimate setup does. Administrative functions are unchanged and remain relayable.
- **`version()` return value format.** It now returns `"3.0.0-rc7"` instead of `"3.0.0"`. An integration that compares the string literally (deployment checks, indexers, upgrade scripts) must be updated, and must expect the suffix to change at each release candidate.
- **Deployable source paths.** The six deployables moved from `src/deployment/` to `src/deployment/accessControl/` (`RuleEngine`, `RuleEngine2771`) and `src/deployment/ownable/` (the four ownable contracts). A project that imports them, or a script that names the file (`forge create src/deployment/RuleEngine.sol:RuleEngine`), must update the path. Contract names, constructors and ABIs are unchanged.
- **No storage change.** The RuleEngine is not upgradeable and uses no ERC-7201 namespace.
- **No external engine interface change.** Function signatures, selectors, events, errors (except the removal of the unreachable `RuleEngine_RulesManagementModule_OperationNotSuccessful`) and advertised ERC-165 interface IDs are identical to rc6 (the engine advertises no `IRule` ID; the ID it *requires* of rules changes, see above), for all four variants (ERC-2771 has no ERC-165 id). Only who may call the token callbacks changes, and the constructors and ERC-2771 views of the three contracts without the `2771` suffix (see above). The CMTAT v3.3.0-rc4 update changes only NatSpec in `IRuleEngine`. Its engine-facing breaking changes (mint, burn and the minter `batchTransfer` routed to the 4-argument `transferred`, the reentrancy guard around `transferred`, the `^0.8.24` pragma of the engine interfaces) were already present in the v3.3.0-rc1 / rc3 targets of rc4–rc6.

### Security

- **The trusted ERC-2771 forwarder can no longer act as a token.** `TokenBindingModule._checkBoundToken` (the `onlyBoundToken` gate) and the token self-binding check in `TokenBindingExtendedModule._authorizeTokenBindingChange` compared `_msgSender()`, so a trusted forwarder could append a token's address and pass as that token. It could (a) call `transferred` / `created` / `destroyed` with no token movement, driving stateful rules, for example consuming a per-minter mint quota or a one-time transfer approval; and (b) call `unbindToken(token)` for a token approved for self-binding, after which every operation of that token reverted until it was re-bound. Both checks now compare the raw `msg.sender`; a token never calls through a forwarder. A signature-verifying forwarder could not produce these calls, because a token cannot sign, so the exposure was limited to a buggy, malicious or permissive forwarder. This aligns with CMTAT's `onlyTokenBridge` and with CMTAT's RuleEngine integration guide. The administrative checks keep `_msgSender()`, so gasless administration is unchanged.

### Changed

- `pragma solidity` raised from `^0.8.20` to **`^0.8.27`** in every `src/` and `script/` file. The code uses `require(cond, CustomError())`, which the legacy pipeline supports from solc 0.8.27 only, so it never compiled below that version (checked: 0.8.20, 0.8.24 and 0.8.26 fail, 0.8.27 builds). The pragma now states the real floor, and an integrator on an older compiler gets a clear version error. Found by the rc7 code-quality review (`F-1`) and the Aderyn `L-2` triage. `README.md`, `CLAUDE.md` / `AGENTS.md` and `RuleEngine-with-ERC3643.md` updated.
- `RuleEngineBase`: the three view loops (`detectTransferRestriction`, `detectTransferRestrictionFrom`, `messageForTransferRestriction`) iterate `_rules` directly (`_rules.length()`, `_rules.pos(i)`) instead of the public `rulesCount()` / `rule(i)`, which re-checked the bound on every iteration. Same form as the enforcement loops; no behaviour change. Measured −682 gas per detect call with 3 rules (−227 per rule); T-REX tokens pay it on every transfer and mint through `canTransfer`. rc7 code-quality review `A-3`.
- `RuleEngineBase._messageForTransferRestriction`: the rule is read once per iteration and reused for `canReturnTransferRestrictionCode` and `messageForTransferRestriction`, instead of being read again from storage after the first external call. No behaviour change; measured −375 gas per call with 3 rules. rc7 code-quality review `B-1`.
- `RulesManagementModule`: `addRule` / `setRules` and `removeRule` rely on the return value of the `EnumerableSet` mutation instead of a preceding `contains()` lookup, as the token binding already did. `_checkRule` now checks only the zero address; a duplicate still reverts with `RuleEngine_RulesManagementModule_RuleAlreadyExists` (after the ERC-165 check instead of before), and removing an absent rule still reverts with `RuleEngine_RulesManagementModule_RuleDoNotMatch`. The unreachable `RuleEngine_RulesManagementModule_OperationNotSuccessful` error is removed. Measured −271 gas on `addRule` and −268 on `removeRule`; branch coverage of `src/` reaches 100% (40/40). The redundant checks added no security (assessed in the review). rc7 code-quality review `B-2`.
- `RuleEngine` now holds the RBAC logic directly and `RuleEngine2771` extends it, the same pattern as the ownable `*2771` contracts; the intermediate abstract `RuleEngineAccessControlShared` (introduced earlier in rc7, never released) is removed. The deployables are grouped by access-control model in `src/deployment/accessControl/` and `src/deployment/ownable/`. No behaviour change: constructors, roles, ERC-165 answers and the 438 Foundry tests (and the 13 real ERC-3643 tests) are unchanged. `README.md`, `doc/README.md`, `CLAUDE.md` / `AGENTS.md`, `package.json`, `doc/TOOLCHAIN.md` and `doc/script/script_sol2uml.sh` updated. rc7 code-quality review `D-2`.
- CI (`.github/workflows/ci.yml`) also runs `FOUNDRY_PROFILE=erc3643 forge test`, so the 13 tests against the real T-REX 4.2.0-beta1 token are no longer skipped. rc7 code-quality review `K-4`.
- A rule used directly as a CMTAT token's rule engine (no RuleEngine) is now tested and documented: `test/RuleStandalone/RuleStandaloneCMTAT.t.sol` (9 tests, one or more per reference rule, on a real CMTAT token; 438 -> 447 tests) and `RuleEngine-with-CMTAT.md` §4.8, which states what a rule must do for that role (restrict who calls `transferred` when it keeps state, keep `canTransfer*` consistent with `detectTransferRestriction*`). The four reference rules import `RULE_ENGINE_INTERFACE_ID` and `ERC1404EXTEND_INTERFACE_ID` from CMTAT instead of hardcoding them. rc7 code-quality review `I-2`.
- Error style: the 8 remaining `if (...) { revert X(); }` sites in `src/` (and 4 in the mock rules) use `require(cond, X())`, as the project convention asks. Same errors, same conditions; gas unchanged on the token path (`transferred`), +13 on `addRule` (the cap is cached in a local because `require` evaluates the error argument eagerly) and +5 on `setRules`. rc7 code-quality review `E-2`.
- `IRule` declares the engine's needs only (`src/interfaces/IRule.sol`: `IERC1404Extend`, `IERC3643IComplianceContract`, `IERC165`, plus the 4-argument `transferred` and `canReturnTransferRestrictionCode`) and `RuleInterfaceId.IRULE_INTERFACE_ID` is recomputed (`0xb1a69752`). The four reference rules also implement `IRuleEngineERC1404` to keep the standalone role, with `override(IRule, IRuleEngine)` on the 4-argument `transferred`; the test probes `RuleCodeProbe` and `SupplyCapProbeRule` drop `canTransfer` / `canTransferFrom` and are accepted on all six deployables. `IRule` no longer inherits CMTAT's `IRuleEngineERC1404`, so a new rule needs neither `canTransfer` nor `canTransferFrom`. **Not breaking for existing rules:** `RuleEngineBase._supportsRuleInterface` accepts the new ID or the legacy one (`RuleInterfaceId.IRULE_LEGACY_INTERFACE_ID`, `0x2497d6cb`, a superset of the new interface), after checking ERC-165 support once; a contract advertising neither, or answering `true` to every ID, is rejected. `addRule` with a current-ID rule costs 64 gas less than before. New tests: the new ID equals the old one XOR the two selectors and the legacy constant is pinned; on all six deployables, an engine-only rule is accepted, a rule advertising only the legacy ID is accepted, and a contract advertising no rule ID, claiming every ID, or without ERC-165 (an EOA) is rejected; removing the ERC-165 pre-check or the legacy fallback each fails 6 tests (447 -> 481 tests). rc7 code-quality review `I-1`.
- `bindTokens` / `unbindTokens` stay atomic by decision: one token already bound (or not bound) reverts the whole call, unlike the skip-if-already-done batch convention of `RuleAddressList`, because a binding change is security-relevant. Stated in the `ITokenBindingExtended` NatSpec and `TokenBinding-module.md` §4; the batch tests now check the rollback of the tokens processed before the failure, and a new test pins empty batches as no-ops, in the three access-control families (460 -> 463 tests). rc7 code-quality review `C-3`.
- Self-binding approval events: kept as they are, documented. The `ITokenBindingExtended` NatSpec no longer says `TokenSelfBindingApprovalBatchSet` lists the tokens whose permission *changed* (it is the input array, with no-ops and duplicates), and states that the batch emits no per-token `TokenSelfBindingApprovalSet`, so indexers must handle both events or read `isTokenSelfBindingApproved`; same warning in `TokenBinding-module.md` §4. `TokenBound` / `TokenUnbound` NatSpec states they stay non-indexed as declared by ERC-3643. rc7 code-quality review `C-2`.
- NatSpec and comments: `RulesManagementModule` gets a real `@title`; the two `_transferred` describe enforcement (they apply every rule and revert on the first rejection) instead of detection; `RuleEngineBase` loses the placeholder `// Apply  on RuleEngine` and its `detectTransferRestriction` doc is reworded; section headers read `PUBLIC/EXTERNAL FUNCTIONS` in the three binding modules; the empty `Events` header of `VersionModule` is removed; "restricion" typo fixed in `RuleEngineBase` and the mock rules. Comment-only. rc7 code-quality review `G-2`.
- `version()` now returns `"3.0.0-rc7"` instead of `"3.0.0"`, so the on-chain string matches the release tag (`VersionModule.VERSION`). The `version()` assertions of the RBAC and Ownable suites and of the Hardhat smoke test are updated, and `RuleEngineOwnable2Step` gains its own `testHasRightVersion` (348 -> 349 tests).

### Added

- Add `test/utils/ERC2771TokenGateTestBase.sol` and `test/RuleEngine*/ERC2771TokenGate.t.sol`: 7 tests × 3 deployable variants (349 -> 370 tests). Each simulates a forwarder relay (`vm.prank(forwarder)` with the claimed sender appended to the calldata) and checks four things: the forwarder cannot pass as a bound token on any of the four callbacks; a forged mint callback does not consume a `RuleMintAllowanceMock` quota, while a real one does; the forwarder cannot unbind a token approved for self-binding; and the bound token, an approved self-binding token and a relayed binding manager still work. Against the rc6 code, the three impersonation tests fail.
- Add the deployables **`RuleEngine2771`**, **`RuleEngineOwnable2771`** and **`RuleEngineOwnable2Step2771`** (`src/deployment/accessControl/` and `src/deployment/ownable/`), each adding an immutable ERC-2771 trusted forwarder to its access-control model. Every `*2771` contract extends its counterpart without the suffix (`RuleEngine2771 is ERC2771ModuleStandalone, RuleEngine`, and likewise for the two ownable contracts) and adds only `ERC2771ModuleStandalone` and the three `Context` overrides; the RBAC logic (constructor checks, initial `SetMaxRules`, `grantRole` rule guard, admin-has-all-roles `hasRole`, ERC-165, access-control hooks) is held by `RuleEngine` itself. `RuleEngineOwnableShared` drops ERC-2771 (constructor `(tokenContract)`). The coverage mocks become `RuleEngine2771Exposed`, `RuleEngineOwnable2771Exposed` and `RuleEngineOwnable2Step2771Exposed`. Tests: two new shared bases, `ERC2771VariantTestBase` (forwarder trusted, version, zero admin/owner, same ERC-165 answers as the counterpart without forwarder, `_msgData` stripping on a relayed call; run for the three `*2771` contracts) and `NoForwarderTestBase` (no `isTrustedForwarder` / `trustedForwarder`, an appended sender is ignored; run for the three others); new directories `test/RuleEngine2771/`, `test/RuleEngineOwnable2771/`, `test/RuleEngineOwnable2Step2771/` with the ERC-2771 token-gate suites moved there and the rule-aggregation suite; initial `SetMaxRules` checked for all six. Every 3-argument constructor call with a zero forwarder in the tests and scripts drops that argument; the Hardhat smoke test deploys `RuleEngine` and `RuleEngine2771` (395 -> 438 Foundry tests).
- Add `test/utils/RuleAggregationTestBase.sol` (7 tests × 3 deployable variants, in `test/RuleEngine*/RuleAggregation.t.sol`) and the test-only rule `test/utils/RuleCodeProbe.sol`, whose restriction codes, claimed code and message are set per test. They pin how the engine aggregates several rules: the first non-zero code in rule order (two fuzz properties, for the 3- and 4-argument views, with `canTransfer` / `canTransferFrom` derived from it), boundary codes 1 and 255, the message taken from the rule that claims the code, every rule run by each callback, and the zero address on the correct side in `created` / `destroyed`. Also add `testSetTokenSelfBindingApprovalEmitsEvent` (3 variants; the event was never asserted) and `testCannotBindTokensBatchWithDuplicateToken`, and make the two bare `vm.expectRevert()` of `ERC3643TokenIntegration.t.sol` name their error. Found by mutation testing in the rc7 code-quality review: 4 of 32 mutants of `src/` survived the suite, and all 33 (one added) are now killed (370 -> 395 tests).
- Add `test/ERC3643Real/ERC3643RealTokenRuleEngine.t.sol` (13 tests) against the **real** vendored ERC-3643 token (T-REX 4.2.0-beta1): self-binding through `init` / `setCompliance`, mint through `created`, burn through `destroyed`, `transfer` / `transferFrom` on the 3-argument `transferred` with no spender forwarded, `forcedTransfer` notifying compliance, unbound callers rejected, and the post-update notification order (a CMTAT-style supply cap counts a mint twice). Run with `FOUNDRY_PROFILE=erc3643 forge test`: a new `[profile.erc3643]` builds at solc 0.8.30 (the token pins `pragma solidity 0.8.30`) into `out-erc3643/`, with a context-scoped `@onchain-id` remapping to the stubs in `test/utils/onchainid/`; the default profile skips the directory. Test helpers: `IdentityRegistryStub`, `SupplyCapProbeRule`.

### Documentation

- `doc/README.md` "Like CMTAT": corrected the overload routing. The section said the 3-argument `transferred` is never called in CMTAT v3.3.0 flows and listed `transfer` with a spender; a direct `transfer` is in fact the one operation that uses the 3-argument overload. The table now gives the overload per operation, including `batchMint`, `batchBurn`, `burnFrom`, self-burn, cross-chain mint/burn and the minter `batchTransfer`, as documented in the CMTAT v3.3.0-rc4 `IRuleEngine` NatSpec; `doc/technical/RuleEngine-with-CMTAT.md` gains the minter `batchTransfer` row. Compatibility tables and the tested toolchain (OpenZeppelin v5.7.0, CMTAT v3.3.0-rc4) updated.
- CMTAT / Rules related documentation: complete CMTAT entry-point table (`batchMint`, `batchBurn`, `burnFrom`, cross-chain, minter `batchTransfer` with `spender == from`, `forcedTransfer` bypass); CMTAT v3.0.0–v3.2.0 3-argument mint/burn note; ERC-2771 forwarder trust stated for the bound-token gate (`doc/README.md` §Gasless, `RuleEngine-with-CMTAT.md` §4.7, `RuleEngine-with-ERC3643.md` §4.5, `TokenBinding-module.md` §4); rule-side `transferred*` reentrancy obligation (`RuleEngine-with-CMTAT.md` §4.6, `CLAUDE.md`); token-level ERC-1404 mint/burn pre-flight caveat; ERC-3643 post-update notification order (`RuleEngine-with-ERC3643.md` §4.9); rule lists synced with the Rules repository (`RuleSanctionsList` spelling, seven missing rules, `RuleConditionalTransferLightMultiToken` must not sit behind an engine); single-rule setup caveats; `ERC2771Context` / `forwarderIrrevocable` naming; `IRuleEngine.sol` link moved to CMTAT v3.3.0-rc4; two ERC-165 conventions explained; deployment checklist wiring steps; quick start uses non-recursive `git submodule update --init` without `npm install`; "CMTAT ≥ v3.0.0" headings and `setRuleEngine(IRuleEngine)` signature.
- `doc/README.md` §Compatibility: removed the RuleEngine v3.0.0-rc3 row, which linked to a CMTAT `v3.3.0` tag that does not exist yet and was out of order with the rc4 row.
- Add the v3.0.0-rc7 Slither (0.11.5) and Aderyn (0.6.5) reports with their assessment feedback in [doc/security/audits/tools/v3.0.0-rc7](./doc/security/audits/tools/v3.0.0-rc7), run on the final rc7 code (`3055fe2`: six deployables, after the code-quality review fixes), and refresh [AUDIT_OVERVIEW.md](./doc/security/audits/AUDIT_OVERVIEW.md) and the `doc/README.md` tables. Slither: 0 High / 0 Medium / 10 Low / 2 Informational, the same 12 results as rc6 (108 -> 111 contracts). Aderyn: 0 High / 8 Low, the same findings as rc6, 84 -> 90 instances from the two per-file detectors on the three new `*2771` files; nSLOC 683 -> 694. Re-run after the code-quality review fixes: same findings as the intermediate run (112 contracts / 92 instances), only the folded `RuleEngineAccessControlShared` file is gone. Nothing exploitable. The Aderyn `L-2` triage accepted the floating pragma as "the supported range", which was false, so the pragma was corrected (see Changed).
- Regenerate the Surya schema (`doc/schema/surya/`: call graph, inheritance graph and report for each of the 56 files under `src/`), adding `RuleEngine2771`, `RuleEngineOwnable2771` and `RuleEngineOwnable2Step2771`; regenerated again after the deployables moved and `RuleEngine` absorbed the RBAC logic, and once more on the final rc7 code (`3055fe2`, all 55 files; the `RuleEngineBase` inlined table gains `_supportsRuleInterface`). `doc/README.md`: the four inlined Surya tables (`RuleEngineBase`, `VersionModule`, the two binding modules, `ERC3643ComplianceModule`) are refreshed — `RuleEngineBase` listed a `hasRole` it does not have and the wrong `IRuleEngine` base, `VersionModule` the old `IERC3643Base` base; the deployable sections embed the current Surya inheritance graphs next to the older sol2uml diagrams; and the call graph shown is `RuleEngineBase`, where the logic lives, instead of the now-minimal `RuleEngine`.
- Regenerate the sol2uml class diagrams (`doc/schema/sol2uml/`, 16 -> 20 images) on the final rc7 code: the three deployables without a forwarder now show their real surface (no ERC-2771 members, 2-argument constructors), and `RuleEngine2771UML`, `RuleEngineOwnable2771UML`, `RuleEngineOwnable2Step2771UML` and `IRuleUML` (the narrowed interface) are added and embedded in `doc/README.md`, which drops the three "UML predates the split" notes. `doc/script/script_sol2uml.sh` now renders through Graphviz (`sol2uml -f dot`, then `dot -Tpng -Gdpi=96`) instead of sol2uml's headless Chrome, which cannot start where unprivileged user namespaces are disabled (Ubuntu 23.10+ AppArmor).
- Add the v3.0.0-rc7 code-quality review, including the test suite, in [CLAUDE_ANALYSIS.md](./doc/security/audits/tools/v3.0.0-rc7/CLAUDE_ANALYSIS.md), indexed in `AUDIT_OVERVIEW.md` and `doc/README.md`. Nothing in it is a vulnerability. It was run twice: at `4946c87`, then on the final rc7 code (six deployables, `^0.8.27`), re-verifying every finding and re-measuring every gas number. Fixed along the way: the false `^0.8.20` pragma (`F-1`), the stale "MetaTxModule" NatSpec (`G-2`, removed by the split) and a reuse blocker, `Error (3364)` for a host bringing its own `ERC2771Context`, which the ERC-2771 split removed (`J-2`, verified by compile probe). Implemented after it: the view-loop storage reads (`A-3`), the second rule lookup in `messageForTransferRestriction` (`B-1`) and the redundant `contains()` checks in `addRule` / `removeRule` (`B-2`, assessed as adding no security), see Changed. Open decisions it records: 9 remaining stale NatSpec sites; a `*2771` deployable accepting a zero forwarder; the two families implementing the ERC-2771 split differently; CI not running the `erc3643` profile. Coverage is 100% of lines and functions, 41/43 branches at review time (the 2 missing were dead code, removed by `B-2`: now 40/40); mutation testing: 50 mutants over both passes, 0 surviving.
- `doc/technical/RuleEngine-with-CMTAT.md` §4.7: no longer says that every deployable inherits `ERC2771Context` or that `address(0)` disables gasless administration; it names the three `*2771` deployables and points to the contracts without the suffix.
- Remove `doc/schema/cmtat_surya_inheritance_IRuleEngine.sol.png`, a 2025 Surya graph showing `IRuleEngine` extending `IERC1404Extend`, which has not been true since CMTAT v3.2.0. `doc/README.md` §Interface › CMTAT now gives the current inheritance in text (`IRuleEngine` extends `IERC7551Compliance`, `IERC3643IComplianceContract` and `IERC165`; `IRuleEngineERC1404` adds `IERC1404Extend`) and points to the sol2uml diagram of `IRuleEngine`.
- Remove `doc/other/CMTAT/` (`transferred.png`, `checkTransferred.png`): 2025 screenshots of CMTAT code in which `_transferred` still returned a `bool`. `doc/README.md` "Like CMTAT" now quotes the CMTAT v3.3.0-rc4 code of `_checkTransferred`, `_transferred` and `_callRuleEngineTransferred` as text, and its links point to the v3.3.0-rc4 tag. The `CMTATBaseRuleEngine` link was broken, because the file is now `3_CMTATBaseRuleEngine.sol`.
- Add the v3.0.0-rc6 specification PDFs under `doc/specification/previous_specification/rc6/` and the cover sources; add `doc/script/convert_links_for_pdf_root.sh`, which applies the PDF link conversion of `convert_links_for_pdf.sh` to the root `README.md`.

### Dependencies

- Set the Solidity compiler to [0.8.37](https://www.soliditylang.org/blog/2026/09/10/solidity-0.8.37-release-announcement/) in `foundry.toml` (default profile) and `hardhat.config.js`. Checked against the release announcement: none of its bug fixes applies to this codebase or its dependencies. They concern a memory `bytes` element `delete` (only storage-mapping `delete` is used), `--via-ir` spill slots, named-argument custom errors in `require` and constants on the IR pipeline (the project uses the legacy pipeline), and internal function pointers in packed storage (none are used). There is no `pragma experimental`, and Prague is not among the newly deprecated EVM versions. Compiler warnings are the same as with 0.8.36, and the deployed bytecode size of the three deployables is unchanged. The `erc3643` test profile stays on 0.8.30, which the vendored T-REX `Token.sol` pins exactly.
- Set the EVM version from Prague to **Osaka** (Fusaka upgrade, the default of solc 0.8.37) in `foundry.toml` (default profile) and `hardhat.config.js`. The deployed code of the three deployables is identical to the Prague build once the metadata, which records the EVM version, is stripped. It contains no `CLZ`, the only new opcode Osaka gives the compiler, so the contracts also run on chains that have not activated Fusaka. The `erc3643` test profile stays on Prague, because `osaka` is still experimental in solc 0.8.30.
- Update Foundry (forge-std) from v1.14.0 to [v1.17.0](https://github.com/foundry-rs/forge-std/releases/tag/v1.17.0). It is a drop-in update with no test change. It removes the 58 compiler warnings raised by the `error` parameter names in forge-std's `Vm.sol`.
- Update the ERC-3643 submodule (`lib/ERC-3643`) from 4.1.3 to [4.2.0-beta1](https://github.com/ERC-3643/ERC-3643/releases/tag/4.2.0-beta1) (`a708758`, the commit used by the Rules repository). Only the `erc3643` test profile compiles it.
- Update CMTAT submodule to [v3.3.0-rc4](https://github.com/CMTA/CMTAT/releases/tag/v3.3.0-rc4). No change to the interfaces used by the RuleEngine: rc4 only documents the `transferred` overload routing in the `IRuleEngine` NatSpec, replaces `EnumerableSet.at` by `EnumerableSet.pos` in `HolderListModule` (OpenZeppelin 5.7.0 deprecation, already the version of our submodule) and adds upgrade test mocks. Build and full test suite pass unchanged.

### v3.0.0-rc6

Commit: `ca75429c581a2eb9043e4719561e941d0b2e1206`

### Summary

Token binding is separated from the ERC-3643 compliance code: `TokenBindingModule` and
`TokenBindingExtendedModule` now hold the whole binding registry and depend only on OpenZeppelin, so they can be reused in another project, while the compliance modules become thin ERC-3643 adapters. 

The external API and the advertised ERC-165 interface IDs are unchanged; the only breaking change is the rename of the binding errors `RuleEngine_ERC3643Compliance_*` to `TokenBinding_*`, which changes their selectors.

### Changed

- **Token binding is now separated from the ERC-3643 compliance code**, so the registry can be reused in another project as-is. `TokenBindingModule` (+ `TokenBindingExtendedModule`) holds the whole binding logic — bound token set, `bindToken` / `unbindToken` / `isTokenBound`, the `onlyBoundToken` guard, batch binding, token self-binding and `getTokenBounds()` — and depends only on OpenZeppelin's `Context` and `EnumerableSet`. `ERC3643ComplianceModule` / `ERC3643ComplianceExtendedModule` become thin ERC-3643 adapters, keeping only `getTokenBound()` and the compliance-manager vocabulary (`_onlyTokenBindingManager()` is wired to `_onlyComplianceManager()`).
- The binding functions and events moved to the standard-agnostic `ITokenBinding` / `ITokenBindingExtended`, which `IERC3643Compliance` / `IERC3643ComplianceExtended` now extend. **The external API and the advertised ERC-165 interface IDs are unchanged**: same functions, same selectors, same events, same access control.
- **Renamed the binding errors** `RuleEngine_ERC3643Compliance_*` to `TokenBinding_*` (`TokenBinding_InvalidTokenAddress`, `TokenBinding_TokenAlreadyBound`, `TokenBinding_TokenNotBound`, `TokenBinding_UnauthorizedCaller`), so a reused module carries no RuleEngine or ERC-3643 wording. This changes the error selectors. `ERC3643ComplianceModuleInvariantStorage` is replaced by `TokenBindingModuleInvariantStorage`.
- `_authorizeComplianceBindingChange(address)` renamed to `_authorizeTokenBindingChange(address)` and is no longer abstract: `TokenBindingModule` defaults it to the binding manager check, and `TokenBindingExtendedModule` overrides it with the self-binding aware variant. The deployable contracts are unchanged — they still implement `_onlyComplianceManager()` only.
- `script/`: the two deployment scripts now import project files relatively (`../src/...`) instead of through the `src/` remapping, and `run()` carries NatSpec in both. `src/` and `script/` are clean against the project style checks (function order, modifier order, NatSpec, revert strings, imports, emoji); the test suite is deliberately left on the `src/` remapping and on Foundry test-naming conventions.
- **The ERC-165 interface IDs are now computed from the interfaces instead of hardcoded** (`CLAUDE_ANALYSIS.md` `F-2`): `RuleInterfaceId.IRULE_INTERFACE_ID`, the three `ComplianceInterfaceId` constants and `ERC1404InterfaceId.IERC1404_INTERFACE_ID` XOR each interface with its parents, since `type(I).interfaceId` counts only directly declared selectors. **Every value is unchanged** (`0x2497d6cb`, `0x3144991c`, `0x646ba2be`, `0x7157797f`, `0xab84a5c8`) and is now pinned by a test, so an upstream CMTAT interface change fails the suite instead of silently altering what `supportsInterface` advertises. `IERC3643ComplianceExtended` declares no function of its own, so `type(IERC3643ComplianceExtended).interfaceId` is `0x00000000`: a NatSpec warning now says so and names the constant to use. `OwnableInterfaceId` and `Ownable2StepInterfaceId` stay literal — neither has an interface declaration outside `src/mocks/`.
- Removed the unused `onlyComplianceManager` modifier from `ERC3643ComplianceModule`; the generic `onlyTokenBindingManager` modifier of `TokenBindingModule` guards the binding administration functions.

### Added

- Add `TokenBindingStandaloneMock`: a minimal engine embedding `TokenBindingModule` alone with `Ownable` access control, showing what another project has to provide to reuse the registry, and pinning that it works with no compliance code around it.
- Add `test/TokenBinding/TokenBindingStandalone.t.sol` (10 tests) covering the standalone registry: bind, unbind, events, manager-only administration, zero address, already-bound / not-bound, the `onlyBoundToken` guard, and that self-binding is rejected without `TokenBindingExtendedModule`.

### Documentation

- Add `testInterfaceIdConstantsMatchTheirWireValues` and `testMarkerInterfaceHasZeroNaiveIdAndIsNotUsedAsSuch` to `test/RuleEngine/IRuleInterfaceId.t.sol`, pinning the five advertised interface IDs to their wire values and the marker interface's naive ID to `0x00000000` (346 -> 348 tests).
- Add the v3.0.0-rc6 code-quality review in [doc/security/audits/tools/v3.0.0-rc6/CLAUDE_ANALYSIS.md](./doc/security/audits/tools/v3.0.0-rc6/CLAUDE_ANALYSIS.md): 14 findings, none a vulnerability, one fixed in this release. The reusability claim behind the token binding split is verified by two compile probes (a foreign ERC-2771 + RBAC host, and a CMTAT token embedding the registry) — both build, with no linearization conflict — and the ERC-3643 adapter indirection is measured at 35 gas per binding operation. `F-2` (hardcoded interface IDs) is fixed in this release; two items are left open for a decision: `C-2` (batch approval event, carried from rc5) and `I-2` (a rule advertises `RULE_ENGINE_INTERFACE_ID`, so it can be attached to a token as its engine with no RuleEngine in between, but no test or document covers that configuration). `I-1` (`IRule` requires `canTransfer` / `canTransferFrom`, which the engine never calls) stands, with the narrowed interface ID computed as `0xb1a69752`; an intermediate correction claiming the finding was void is kept in the report, marked superseded, with the reasoning error explained.
- Add the v3.0.0-rc6 Slither and Aderyn reports with their assessment feedback in [doc/security/audits/tools/v3.0.0-rc6](./doc/security/audits/tools/v3.0.0-rc6), each prefixed with a summary table of findings and dispositions, and refresh [AUDIT_OVERVIEW.md](./doc/security/audits/AUDIT_OVERVIEW.md). Slither: 0 High / 0 Medium / 10 Low / 2 Informational, unchanged from rc5. Aderyn: 0 High / 8 Low, 76 -> 84 instances, the growth coming entirely from the net four files added by the token binding split (the per-file pragma and PUSH0 detectors). Nothing to fix in either.
- Add [doc/technical/TokenBinding-module.md](./doc/technical/TokenBinding-module.md): the layering, the two hooks a deployment implements, how to reuse the module in another project, and the operational warnings of the registry.
- `doc/README.md` "ERC-165 Support by Deployment Version": add the missing `IERC3643ComplianceExtended` (`0x646ba2be`) row — all three variants advertise it and five tests assert it, but the table never listed it — and note that `IRule` (`0x2497d6cb`) is deliberately absent because the engine *requires* it of rules rather than implementing it, that the IDs are computed and pinned, and that `type(IERC3643ComplianceExtended).interfaceId` is `0x00000000` and must not be used.
- Update `README.md`, `doc/README.md`, `doc/technical/RuleEngine-with-ERC3643.md`, `CLAUDE.md` and `AGENTS.md` for the new layering.
- Replace the access-control schema of `doc/README.md` (a drawio export, `doc/security/accessControl/access-control-RuleEngine.png`) with a PlantUML diagram, [doc/schema/plantuml/ruleengine-access-control.puml](./doc/schema/plantuml/ruleengine-access-control.puml), following the convention of the other diagrams: a text source is versioned next to the rendered PNG. The new diagram is up to date with the current code — it shows `setMaxRules` under `DEFAULT_ADMIN_ROLE`, the extended binding functions, the token self-binding path and the `onlyBoundToken` data plane, and it names `TokenBindingModule` / `TokenBindingExtendedModule` rather than the compliance modules.
- Regenerate the contract UML diagrams with [sol2uml](https://github.com/naddison36/sol2uml) into `doc/schema/sol2uml/`, replacing the `doc/schema/vscode-uml/` images removed in `d6621e2` — the 14 references left in `doc/README.md` pointed at deleted files. Added [doc/script/script_sol2uml.sh](./doc/script/script_sol2uml.sh), which regenerates the whole set from relative source paths, so the diagrams are reproducible like the Surya ones. New diagrams for `TokenBindingModule`, `TokenBindingExtendedModule` and `ERC3643ComplianceExtendedModule` were added to their sections.
- `doc/README.md`: the eight `[...](../src/...)` links now use absolute GitHub URLs. `doc/script/convert_links_for_pdf.sh` only rewrites the `./` form and its base URL points at the `doc/` directory, so a `../` link cannot be rewritten and stayed dead in the generated specification PDF.
- `doc/README.md`: the "Role by modules" table now lists `bindToken` / `unbindToken` under `TokenBindingModule` and the batch and self-binding functions under `TokenBindingExtendedModule`, adds the missing `setMaxRules` row, and points `COMPLIANCE_MANAGER_ROLE` to `ERC3643ComplianceRolesStorage`, where it is actually declared.

### v3.0.0-rc5-2026-08-13

Commit: `ab9def2f19ae71af304127f42d20d9831cad1a2b`

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
