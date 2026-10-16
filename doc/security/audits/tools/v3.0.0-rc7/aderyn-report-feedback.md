# Aderyn Report — Assessment Feedback

**Tool:** [Aderyn](https://github.com/Cyfrin/aderyn) 0.6.5
**Report file:** `doc/security/audits/tools/v3.0.0-rc7/aderyn-report.md`
**Assessment date:** 2026-10-16 (commit `29556e5`: the final rc7 code, `src/` as of `c7a19c7`, after the rc7 security review fixes; earlier runs at `3055fe2`, `a91ca9a`, `4946c87` and `850976f` + pragma)
**Scope:** `src/`, **mocks excluded** (`-x mocks`), 31 files analysed, 716 nSLOC, solc 0.8.37 / EVM Osaka, `pragma ^0.8.27`

```bash
aderyn -x mocks --output doc/security/audits/tools/v3.0.0-rc7/aderyn-report.md
```

## Summary

| ID | Finding | Tool Impact | Instances | Assessment | Decision |
|----|---------|-------------|-----------|------------|----------|
| L-1 | Centralization Risk | Low | 14 | The engine is by definition an admin-operated compliance controller | Accepted by design |
| L-2 | Unspecific Solidity Pragma | Low | 26 | The floating range is kept for integrators, but it was wrong: raised from `^0.8.20` to the real floor `^0.8.27`; the build pins 0.8.37 | **Fixed (pragma corrected)**, floating kept by design |
| L-3 | PUSH0 Opcode | Low | 31 | EVM target is Osaka, which includes PUSH0 (since Shanghai) | Accepted by design |
| L-4 | Modifier Invoked Only Once | Low | 1 | `onlyRulesLimitManager`, kept for symmetry with the hook pattern | Cosmetic, kept |
| L-5 | Empty Block | Low | 10 | The three access-control hooks × three access-control models, where the modifier does the work, plus the empty default of the `_checkBindingTarget` hook (F-3) | Accepted by design |
| L-6 | Loop Contains `require`/`revert` | Low | 4 | Admin batch operations, atomic on purpose (code-quality review `C-3`) | Accepted by design |
| L-7 | Costly operations inside loop | Low | 4 | Admin-gated batch writes; inherent to a batch operation | Accepted by design |
| L-8 | Unchecked Return | Low | 1 | `_grantRole` cannot return `false` in a constructor | False positive |

**0 High · 8 Low (91 instances). Nothing exploitable; one change made (`L-2`: pragma corrected to `^0.8.27`).**

## Scope verification

| Check | Result |
|---|---|
| `grep -c 'lib/' aderyn-report.md` | **0** — no vendored dependency in scope |
| `grep -c 'src/mocks/' aderyn-report.md` | **0** — `-x mocks` applied correctly |
| `grep -c '/home/' aderyn-report.md` | **0** — no absolute paths committed |

The last check caught a real mistake again. Aderyn computes its source links relative to the `--output` path, so a
run written outside the repository produces `../../../../../home/<user>/…/src/…` links — machine-specific paths
in a committed document. It happened again in rc7: the first run wrote to a scratch directory and
produced 84 such links, so it was re-run with the output inside the repository to get the correct relative
`../../../../../src/…` form. Always write the report straight to its final path.

## Changes since v3.0.0-rc6

**Same 8 findings, 84 -> 91 instances** (92 at the intermediate rc7 run, before `D-2`; 90 at `3055fe2`, before the security review fixes).

| ID | rc6 | rc7, `850976f` + pragma | rc7, `3055fe2` | rc7 final, `29556e5` | Why |
|----|-----|-----|-----|-----|-----|
| L-1 | 14 | 14 | 14 | 14 | RBAC instances: `RuleEngine.sol` -> `RuleEngineAccessControlShared.sol` -> back to `RuleEngine.sol` (`D-2`) |
| L-2 | 23 | 27 | 26 | 26 | per-file detector: +4 files with the ERC-2771 split, −1 when the shared RBAC base was folded |
| L-3 | 28 | 32 | 31 | 31 | same as L-2 |
| L-4 | 1 | 1 | 1 | 1 | — |
| L-5 | 9 | 9 | 9 | **10** | RBAC hooks back in `RuleEngine.sol`; +1 `TokenBindingModule._checkBindingTarget` (F-3) |
| L-6 / L-7 | 4 / 4 | 4 / 4 | 4 / 4 | 4 / 4 | — |
| L-8 | 1 | 1 | 1 | 1 | `RuleEngine.sol:40` (was `RuleEngineAccessControlShared.sol:41`) |

**Changes after the intermediate rc7 run** (the code-quality review fixes, up to `3055fe2`):
`RuleEngineAccessControlShared` folded into `RuleEngine`, so `RuleEngine2771 is ERC2771ModuleStandalone, RuleEngine`
(`D-2`), and the six deployables moved to `src/deployment/accessControl/` and `src/deployment/ownable/`; view loops
read `_rules` directly (`A-3`, `B-1`); `addRule` / `removeRule` use the set's return value and the unreachable
`OperationNotSuccessful` error is gone (`B-2`); every conditional `revert` became a `require` (`E-2`); `IRule`
narrowed with the legacy ID still accepted (`I-1`); stale NatSpec fixed (`G-2`). None produced a new finding.
nSLOC 707 -> 694, per file: `RuleEngine` 5 -> 54 and `RuleEngineAccessControlShared` 54 -> 0 (the fold),
`RuleEngineBase` 145 -> 153 (`_supportsRuleInterface`, the `EnumerableSet` using-directive), `RulesManagementModule`
109 -> 96 (`B-2`, `E-2`), `IRule` 5 -> 8 (the narrowed interface declares its own `transferred`),
`RuleEngineOwnableShared` 23 -> 21, `TokenBindingModule` 51 -> 49, `RuleInterfaceId` 13 -> 12 and
`RulesManagementModuleInvariantStorage` 17 -> 16 (`E-2`, `B-2`, `I-1`).

**Changes after the `3055fe2` run** (the rc7 security review fixes, `efaf860` F-1, `9c43b01` F-2, `c7a19c7` F-3):
one new instance, `L-5` on `TokenBindingModule._checkBindingTarget` (see L-5 below). nSLOC 694 -> 716:
`TokenBindingExtendedModule` 48 -> 57 (`_unbindToken` override, `_setTokenSelfBindingApproval`), `RuleEngineBase`
153 -> 157 (`_checkBindingTarget` override, bound-token check in `_checkRule`), `RuleEngineOwnable2Step` 25 -> 29
(`acceptOwnership`), `ERC3643ComplianceExtendedModule` 18 -> 21 (disambiguating override), `TokenBindingModule`
49 -> 51 (the hook). No other finding moved.

**Where the change comes from.** rc7 made ERC-2771 opt-in: each access-control model now has a deployable
without a forwarder (`RuleEngine`, `RuleEngineOwnable`, `RuleEngineOwnable2Step`) and a `*2771` deployable with one,
and the RBAC logic moved to the abstract `RuleEngineAccessControlShared` (folded back into `RuleEngine` later, `D-2`). That added four files at the intermediate run. The three `*2771`
contracts contain only a constructor and the three `Context` overrides, so they appear in the two per-file
detectors and nowhere else: no centralization, empty-block or unchecked-return instance is duplicated, because the
hooks and the constructor are inherited, not re-declared.

**nSLOC 683 -> 707.** +17 in the three interface-ID libraries: the rc6 report was generated (`dc7a4d3`, 2026-08-20
16:09) about an hour before the rc6 commit that replaced those hardcoded constants with computed
`type(I).interfaceId` XOR expressions (`bdd59fd`, 17:22), so rc7 is the first run on their final form. +7 from the
deployable split.

**Runs:** `a91ca9a` (2026-10-14) and `4946c87` (2026-10-15) gave 84 instances on the pre-split code; `850976f` +
pragma gave 92 on the six-deployable code; `3055fe2` gave 90; this final run at `29556e5` gives 91. The ERC-2771 token-identity fix (`4946c87`) replaced
`_msgSender()` with `msg.sender` in place and produced no finding.

The build changes (solc 0.8.37, EVM Osaka, CMTAT v3.3.0-rc4, forge-std v1.17.0) produced nothing either.

## Detailed triage

### L-1: Centralization Risk (14 instances)

Flags the `onlyRole` / `onlyOwner` privileged functions: the RBAC ones in `RuleEngine` and the
ownable ones in `RuleEngineOwnable` / `RuleEngineOwnable2Step`. The `*2771` deployables inherit them and add none (`RuleEngine2771` extends `RuleEngine`).

The RuleEngine is a compliance controller: an operator must be able to add and remove rules and bind tokens, or
the contract has no purpose. The project deliberately ships three access-control shapes — RBAC (`RuleEngine`),
single-owner (`RuleEngineOwnable`) and two-step handover (`RuleEngineOwnable2Step`) — so the issuer can pick the
centralization profile that matches its governance. ERC-3643 itself specifies ERC-173 ownership for the
compliance contract.

**Decision: accepted by design.**

### L-2: Unspecific Solidity Pragma (26 instances) — pragma corrected

Every `src/` file declared `pragma solidity ^0.8.20;`, now **`^0.8.27`**.

The caret is intentional: these contracts are consumed as a library by integrators compiling against their own
toolchain, and pinning an exact version would force their whole project onto it. The *build* is deterministic
regardless — `foundry.toml` pins `solc = "0.8.37"`.

**But the range was wrong.** Up to this run, this triage accepted the caret because "`^0.8.20` is the supported
range". The rc7 code-quality review (`CLAUDE_ANALYSIS.md`, `F-1`) built the production contracts with older
compilers and showed it is not:

| solc | Result with `^0.8.20` |
|---|---|
| 0.8.20 | fails: CMTAT's interface-ID libraries require `^0.8.24` |
| 0.8.24 | fails: `Error (9322)`, no `require(bool, error)` overload |
| 0.8.26 | fails: "Require with a custom error is only available using the via-ir pipeline" |
| 0.8.27 | compiles |

The code uses `require(cond, CustomError())`, available on the legacy pipeline from 0.8.27 only, and so does
`TokenBindingModule`, which is offered for reuse in other projects. **Fix applied:** every file under `src/` and
`script/` now declares `^0.8.27`, the real floor. A consumer on 0.8.26 now gets a clear "no matching version" error
from the pragma instead of a compile error deep in a `require`. Checked: `forge build --use 0.8.27` succeeds, 0.8.26
is rejected by the pragma, and the full suite (default profile on 0.8.37, `erc3643` profile on 0.8.30, Hardhat)
passes. The count moved 23 -> 27 -> 26 with the files added and folded during rc7, unrelated to the fix.

**Decision: floating pragma accepted by design; its range corrected to `^0.8.27`.**

### L-3: PUSH0 Opcode (31 instances)

`foundry.toml` sets `evm_version = 'osaka'` (Prague up to rc6). PUSH0 has been available since Shanghai, so its presence is
expected for the declared target. A chain that has not adopted Shanghai must recompile with a lower
`evm_version` — a build-configuration decision, not a source change.

**Decision: accepted by design**, with the deployment caveat recorded here.

### L-4: Modifier Invoked Only Once (1 instance)

`onlyRulesLimitManager` at `RulesManagementModule.sol:23` guards `setMaxRules` and nothing else. Inlining it
would break the documented pattern in which every protected operation goes through a virtual `_onlyX` hook
wrapped in an `onlyX` modifier, so each deployable variant can override the authorization independently.

**Decision: cosmetic, kept deliberately.**

### L-5: Empty Block (10 instances)

Nine are the same three hooks, declared once per access-control model (`RuleEngine.sol:104/109/114`,
`RuleEngineOwnable.sol:35/40/45`, `RuleEngineOwnable2Step.sol:55/60/65`; the `*2771` deployables inherit them):

```solidity
function _onlyComplianceManager() internal virtual override onlyRole(COMPLIANCE_MANAGER_ROLE) {}
function _onlyRulesManager()      internal virtual override onlyRole(RULES_MANAGEMENT_ROLE) {}
function _onlyRulesLimitManager() internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {}
```

The body is empty because the modifier performs the check — the core access-control pattern described in
`CLAUDE.md`. The rc6 token binding split added one more indirection (`ERC3643ComplianceModule._onlyTokenBindingManager()` calls
`_onlyComplianceManager()`), but that body is not empty, so the count is unchanged.

The tenth, since the F-3 fix, is the default of the binding-target hook in the standalone registry
(`TokenBindingModule.sol:119`):

```solidity
function _checkBindingTarget(address token) internal view virtual {}
```

The registry is reusable outside the engine and has no notion of a rule, so by default it accepts any target.
`RuleEngineBase` overrides the hook to reject an address that is a current rule
(`RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges`). An empty default is the point of the hook.

**Decision: accepted by design.**

### L-6: Loop Contains `require`/`revert` (4 instances)

`TokenBindingExtendedModule` lines 39, 46 and 65 (`bindTokens`, `unbindTokens`,
`setTokenSelfBindingApprovalBatch`) and `RulesManagementModule.setRules` line 60.

These are administrative batch operations. Reverting the whole batch on a bad element is the wanted semantics: a
partially-applied compliance change is worse than a rejected one. For `bindTokens` / `unbindTokens` this is now a
recorded decision (code-quality review `C-3`): they stay atomic, unlike the skip-if-already-done convention of
the reference `RuleAddressList` batches, because a binding change is security-relevant; the NatSpec of both
functions and `TokenBinding-module.md` §4 say so, and tests pin the rollback.

**Decision: accepted by design.**

### L-7: Costly operations inside loop (4 instances)

The same four loops, flagged for storage writes inside the iteration. A batch operation cannot avoid writing
once per element. All four are gated on a privileged role, so the only party who can pass an oversized array is
the operator, and the only consequence is their own transaction running out of gas.

Recorded as `A-3` in the rc5 `CLAUDE_ANALYSIS.md`, where the same conclusion was reached independently.

**Decision: accepted by design.**

### L-8: Unchecked Return (1 instance) — false positive

`RuleEngine.sol:40` (in `RuleEngineAccessControlShared.sol` at the intermediate rc7 run, back in `RuleEngine` since `D-2`):

```solidity
_grantRole(DEFAULT_ADMIN_ROLE, admin);
```

OpenZeppelin's `_grantRole` returns `true` when the role was newly granted and `false` when the account already
held it. This call is in the constructor, on a contract whose role storage is necessarily empty, so the return
value is invariably `true`. Checking it would add a branch that can never be taken.

**Decision: false positive.**

## Conclusion

**No security fix is required from this Aderyn run.** Six findings are by-design consequences of what the
RuleEngine is — an admin-operated, rule-iterating compliance controller distributed as a library — one (`L-4`) is a
deliberately kept cosmetic, and one (`L-8`) is a verified false positive. No finding is exploitable, and rc7
introduced none. One improvement was made: `L-2`'s accepted range was false, so the pragma now states the real
floor, `^0.8.27`.
