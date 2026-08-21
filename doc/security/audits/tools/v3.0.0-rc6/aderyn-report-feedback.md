# Aderyn Report — Assessment Feedback

**Tool:** [Aderyn](https://github.com/Cyfrin/aderyn) 0.6.5
**Report file:** `doc/security/audits/tools/v3.0.0-rc6/aderyn-report.md`
**Assessment date:** 2026-08-20
**Scope:** `src/`, **mocks excluded** (`-x mocks`), 28 files analysed, 683 nSLOC, solc 0.8.36 / EVM Prague

```bash
aderyn -x mocks --output doc/security/audits/tools/v3.0.0-rc6/aderyn-report.md
```

## Summary

| ID | Finding | Tool Impact | Instances | Assessment | Decision |
|----|---------|-------------|-----------|------------|----------|
| L-1 | Centralization Risk | Low | 14 | The engine is by definition an admin-operated compliance controller | Accepted by design |
| L-2 | Unspecific Solidity Pragma | Low | 23 | `^0.8.20` is the supported range for integrators; the build pins 0.8.36 | Accepted by design |
| L-3 | PUSH0 Opcode | Low | 28 | EVM target is Prague, which includes PUSH0 | Accepted by design |
| L-4 | Modifier Invoked Only Once | Low | 1 | `onlyRulesLimitManager`, kept for symmetry with the hook pattern | Cosmetic, kept |
| L-5 | Empty Block | Low | 9 | The three access-control hooks × three variants; the modifier does the work | Accepted by design |
| L-6 | Loop Contains `require`/`revert` | Low | 4 | Admin batch operations where fail-fast is the wanted behaviour | Accepted by design |
| L-7 | Costly operations inside loop | Low | 4 | Admin-gated batch writes; inherent to a batch operation | Accepted by design |
| L-8 | Unchecked Return | Low | 1 | `_grantRole` cannot return `false` in a constructor | False positive |

**0 High · 8 Low (84 instances). Nothing to fix.**

## Scope verification

| Check | Result |
|---|---|
| `grep -c 'lib/' aderyn-report.md` | **0** — no vendored dependency in scope |
| `grep -c 'src/mocks/' aderyn-report.md` | **0** — `-x mocks` applied correctly |
| `grep -c '/home/' aderyn-report.md` | **0** — no absolute paths committed |

The last check caught a real mistake again. Aderyn computes its source links relative to the `--output` path, so a
run written outside the repository produces `../../../../../home/<user>/…/src/…` links — machine-specific paths
in a committed document. This run hit it exactly as rc5 did: the first attempt wrote to a scratch directory and
produced 84 such links, and it was re-run with the output inside the repository to get the correct relative
`../../../../../src/…` form.

## Changes since v3.0.0-rc5

**Same 8 findings; 76 -> 84 instances, entirely from the file count.**

| ID | rc5 | rc6 | Why |
|----|-----|-----|-----|
| L-2 Unspecific Solidity Pragma | 19 | **23** | one entry per file; 24 -> 28 files |
| L-3 PUSH0 Opcode | 24 | **28** | one entry per file; 24 -> 28 files |
| L-1, L-4, L-5, L-6, L-7, L-8 | 14/1/9/4/4/1 | **unchanged** | no new privileged function, hook, loop or ignored return |

The token binding split added `ITokenBinding`, `ITokenBindingExtended`, `TokenBindingModule`,
`TokenBindingExtendedModule` and `TokenBindingModuleInvariantStorage`, and removed
`ERC3643ComplianceModuleInvariantStorage`: net +4 files, which is exactly the +4 seen on both per-file
detectors. This is the expected signature of a file-count change rather than a code change — worth stating,
because a jump in a static-analysis total is otherwise a scope-regression suspect.

Two citations moved without changing count: L-6 and L-7 now point at `TokenBindingExtendedModule` lines 39, 46
and 65 (`bindTokens`, `unbindTokens`, `setTokenSelfBindingApprovalBatch`) instead of
`ERC3643ComplianceExtendedModule`. The loops are the same code in a new file.

Nothing new appeared from the refactor itself. In particular, removing the unused `onlyComplianceManager`
modifier did not add an L-4 instance elsewhere: `onlyTokenBindingManager` guards four functions, so it is not
"invoked only once".

## Detailed triage

### L-1: Centralization Risk (14 instances)

Flags the `onlyRole` / `onlyOwner` privileged functions across the three deployable variants.

The RuleEngine is a compliance controller: an operator must be able to add and remove rules and bind tokens, or
the contract has no purpose. The project deliberately ships three access-control shapes — RBAC (`RuleEngine`),
single-owner (`RuleEngineOwnable`) and two-step handover (`RuleEngineOwnable2Step`) — so the issuer can pick the
centralization profile that matches its governance. ERC-3643 itself specifies ERC-173 ownership for the
compliance contract.

**Decision: accepted by design.**

### L-2: Unspecific Solidity Pragma (23 instances)

Every `src/` file declares `pragma solidity ^0.8.20;`, including the five files added this release.

The caret is intentional: these contracts are consumed as a library by integrators compiling against their own
toolchain, and pinning an exact version would force their whole project onto it. The *build* is deterministic
regardless — `foundry.toml` pins `solc = "0.8.36"`.

This matters slightly more now that `TokenBindingModule` is explicitly offered for reuse in other projects: the
permissive pragma is what lets it compile inside a consumer's build.

**Decision: accepted by design.**

### L-3: PUSH0 Opcode (28 instances)

`foundry.toml` sets `evm_version = 'prague'`. PUSH0 has been available since Shanghai, so its presence is
expected for the declared target. A chain that has not adopted Shanghai must recompile with a lower
`evm_version` — a build-configuration decision, not a source change.

**Decision: accepted by design**, with the deployment caveat recorded here.

### L-4: Modifier Invoked Only Once (1 instance)

`onlyRulesLimitManager` at `RulesManagementModule.sol:21` guards `setMaxRules` and nothing else. Inlining it
would break the documented pattern in which every protected operation goes through a virtual `_onlyX` hook
wrapped in an `onlyX` modifier, so each deployable variant can override the authorization independently.

**Decision: cosmetic, kept deliberately.**

### L-5: Empty Block (9 instances)

All nine are the same three hooks across the three deployable contracts:

```solidity
function _onlyComplianceManager() internal virtual override onlyRole(COMPLIANCE_MANAGER_ROLE) {}
function _onlyRulesManager()      internal virtual override onlyRole(RULES_MANAGEMENT_ROLE) {}
function _onlyRulesLimitManager() internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {}
```

The body is empty because the modifier performs the check — the core access-control pattern described in
`CLAUDE.md`. The split added one more indirection (`ERC3643ComplianceModule._onlyTokenBindingManager()` calls
`_onlyComplianceManager()`), but that body is not empty, so the count is unchanged.

**Decision: accepted by design.**

### L-6: Loop Contains `require`/`revert` (4 instances)

`TokenBindingExtendedModule` lines 39, 46 and 65 (`bindTokens`, `unbindTokens`,
`setTokenSelfBindingApprovalBatch`) and `RulesManagementModule.setRules` line 62.

These are administrative batch operations. Reverting the whole batch on a bad element is the wanted semantics: a
partially-applied compliance change is worse than a rejected one.

**Decision: accepted by design.**

### L-7: Costly operations inside loop (4 instances)

The same four loops, flagged for storage writes inside the iteration. A batch operation cannot avoid writing
once per element. All four are gated on a privileged role, so the only party who can pass an oversized array is
the operator, and the only consequence is their own transaction running out of gas.

Recorded as `A-3` in the rc5 `CLAUDE_ANALYSIS.md`, where the same conclusion was reached independently.

**Decision: accepted by design.**

### L-8: Unchecked Return (1 instance) — false positive

`RuleEngine.sol:46`:

```solidity
_grantRole(DEFAULT_ADMIN_ROLE, admin);
```

OpenZeppelin's `_grantRole` returns `true` when the role was newly granted and `false` when the account already
held it. This call is in the constructor, on a contract whose role storage is necessarily empty, so the return
value is invariably `true`. Checking it would add a branch that can never be taken.

**Decision: false positive.**

## Conclusion

**No actionable security fixes are required from this Aderyn run.** Seven findings are by-design consequences of
what the RuleEngine is — an admin-operated, rule-iterating compliance controller distributed as a library — one
is a deliberately kept cosmetic, and one (`L-8`) is a verified false positive. No finding is exploitable, and
the token binding split introduced none.
