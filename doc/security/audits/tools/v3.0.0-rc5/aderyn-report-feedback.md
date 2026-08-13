# Aderyn Report — Assessment Feedback

**Tool:** [Aderyn](https://github.com/Cyfrin/aderyn) 0.6.5
**Report file:** `doc/security/audits/tools/v3.0.0-rc5/aderyn-report.md`
**Assessment date:** 2026-08-13
**Scope:** `src/`, **mocks excluded** (`-x mocks`), 24 files analysed, solc 0.8.36 / EVM Prague

```bash
aderyn -x mocks --output doc/security/audits/tools/v3.0.0-rc5/aderyn-report.md
```

## Summary

| ID | Finding | Tool Impact | Instances | Assessment | Decision |
|----|---------|-------------|-----------|------------|----------|
| L-1 | Centralization Risk | Low | 14 | The engine is by definition an admin-operated compliance controller | Accepted by design |
| L-2 | Unspecific Solidity Pragma | Low | 19 | `^0.8.20` is the supported range for integrators; the build pins 0.8.36 | Accepted by design |
| L-3 | PUSH0 Opcode | Low | 24 | EVM target is Prague, which includes PUSH0 | Accepted by design |
| L-4 | Modifier Invoked Only Once | Low | 1 | `onlyRulesLimitManager`, kept for symmetry with the hook pattern | Cosmetic, kept |
| L-5 | Empty Block | Low | 9 | The three access-control hooks × three variants; the modifier does the work | Accepted by design |
| L-6 | Loop Contains `require`/`revert` | Low | 4 | Admin batch operations where fail-fast is the wanted behaviour | Accepted by design |
| L-7 | Costly operations inside loop | Low | 4 | Admin-gated batch writes; inherent to a batch operation | Accepted by design |
| L-8 | Unchecked Return | Low | 1 | `_grantRole` cannot return `false` in a constructor | False positive |

**0 High · 8 Low (76 instances). Nothing to fix.**

## Scope verification

| Check | Result |
|---|---|
| `grep -c 'lib/\|node_modules/' aderyn-report.md` | **0** — no vendored dependency in scope |
| `grep -c 'src/mocks/' aderyn-report.md` | **0** — `-x mocks` applied correctly |
| `grep -c '/home/' aderyn-report.md` | **0** — no absolute paths committed |

The last check is worth keeping in the routine. Aderyn computes its source links relative to the `--output`
path, so writing the report anywhere outside the repository produces links like
`../../../../../home/<user>/…/src/…` — machine-specific paths baked into a committed document. The first
attempt at this run wrote to a scratch directory and produced exactly that in 76 links; it was re-run with the
output inside the repository, which yields the correct relative `../../../../../src/…` form used by rc4.

## Changes since v3.0.0-rc4

**No change:** the same 8 detectors with identical instance counts (14 / 19 / 24 / 1 / 9 / 4 / 1 — in report
order 14, 19, 24, 1, 9, 4, 4, 1).

Stability is expected. The rc5 production changes were the `contains()`/`add()` collapse, `virtual` on internal
functions, the `SetMaxRules` constructor emission, NatSpec additions and the mock-rule rename. None of those
create or remove an empty block, a loop, a pragma or a centralization vector, and the rename is out of scope
because mocks are excluded.

## Detailed triage

### L-1: Centralization Risk (14 instances)

Flags the `onlyRole` / `onlyOwner` privileged functions across the three deployable variants.

The RuleEngine is a compliance controller: an operator must be able to add and remove rules and bind tokens,
or the contract has no purpose. The project deliberately ships three access-control shapes — RBAC
(`RuleEngine`), single-owner (`RuleEngineOwnable`) and two-step handover (`RuleEngineOwnable2Step`) — so the
issuer can pick the centralization profile that matches its governance. ERC-3643 itself specifies ERC-173
ownership for the compliance contract.

**Decision: accepted by design.** This is a property of the product, not a defect.

### L-2: Unspecific Solidity Pragma (19 instances)

Every `src/` file declares `pragma solidity ^0.8.20;`.

The caret is intentional: these contracts are consumed as a library by integrators who compile against their
own toolchain, and pinning an exact version would force their whole project onto it. The *build* is
deterministic regardless — `foundry.toml` pins `solc = "0.8.36"`, so the artefacts this project ships are
produced by a single known compiler.

**Decision: accepted by design.**

### L-3: PUSH0 Opcode (24 instances)

`foundry.toml` sets `evm_version = 'prague'`. PUSH0 has been available since Shanghai, so its presence is
expected and correct for the declared target.

The finding is a genuine deployment-target consideration rather than a code defect: a chain that has not
adopted Shanghai cannot execute this bytecode. Any such deployment must recompile with a lower `evm_version`,
which is a build-configuration decision, not a source change.

**Decision: accepted by design**, with the deployment caveat recorded here.

### L-4: Modifier Invoked Only Once (1 instance)

`onlyRulesLimitManager` at `RulesManagementModule.sol:21` guards `setMaxRules` and nothing else.

Inlining it would break the project's documented pattern, in which every protected operation goes through a
virtual `_onlyX` hook wrapped in an `onlyX` modifier, so each deployable variant can override the
authorization independently. Collapsing the single-use case would make the rule-cap guard the odd one out.

**Decision: cosmetic, kept deliberately.**

### L-5: Empty Block (9 instances)

All nine are the same three functions across the three deployable contracts:

```solidity
function _onlyComplianceManager() internal virtual override onlyRole(COMPLIANCE_MANAGER_ROLE) {}
function _onlyRulesManager()      internal virtual override onlyRole(RULES_MANAGEMENT_ROLE) {}
function _onlyRulesLimitManager() internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {}
```

The body is empty because the modifier performs the check. This is the core access-control pattern described
in `CLAUDE.md`, and an empty body is the correct expression of it.

**Decision: accepted by design.**

### L-6: Loop Contains `require`/`revert` (4 instances)

`ERC3643ComplianceExtendedModule` lines 29, 36 and 55 (`bindTokens`, `unbindTokens`,
`setTokenSelfBindingApprovalBatch`) and `RulesManagementModule.setRules` line 62.

These are administrative batch operations. Reverting the whole batch on a bad element is the wanted semantics:
a partially-applied compliance change is worse than a rejected one.

**Decision: accepted by design.**

### L-7: Costly operations inside loop (4 instances)

The same four loops, flagged for storage writes inside the iteration. A batch operation cannot avoid writing
once per element. All four are gated on a privileged role, so the only party who can pass an oversized array
is the operator, and the only consequence is their own transaction running out of gas.

Recorded as `A-3` in `CLAUDE_ANALYSIS.md`, where the same conclusion was reached independently.

**Decision: accepted by design.**

### L-8: Unchecked Return (1 instance) — false positive

`RuleEngine.sol:46`:

```solidity
_grantRole(DEFAULT_ADMIN_ROLE, admin);
```

OpenZeppelin's `_grantRole` returns `true` when the role was newly granted and `false` when the account
already held it. This call is in the constructor, on a contract whose role storage is necessarily empty, so
the account cannot already hold the role and the return value is invariably `true`. Checking it would add a
branch that can never be taken.

**Decision: false positive.**

## Conclusion

**No actionable security fixes are required from this Aderyn run.** Seven findings are by-design consequences
of what the RuleEngine is — an admin-operated, rule-iterating compliance controller distributed as a library —
one is a deliberately kept cosmetic, and one (`L-8`) is a verified false positive. No finding is exploitable.
