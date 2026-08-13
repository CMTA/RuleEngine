# Slither Report — Assessment Feedback

**Tool:** [Slither](https://github.com/crytic/slither) 0.11.5
**Report file:** `doc/security/audits/tools/v3.0.0-rc5/slither-report.md`
**Assessment date:** 2026-08-13
**Scope:** `src/`, **mocks excluded**, 103 contracts analysed, solc 0.8.36 / EVM Prague

```bash
slither . --checklist --filter-paths "openzeppelin-contracts|test|CMTAT|forge-std|mocks" \
  > doc/security/audits/tools/v3.0.0-rc5/slither-report.md
```

## Summary

| IDs | Detector | Tool Impact | Assessment | Decision |
|-----|----------|-------------|------------|----------|
| 0-9 | `calls-loop` | Low | Inherent to pluggable rule-engine dispatch; bounded by `maxRules` | Accepted by design |
| 10-11 | `unindexed-event-address` | Informational | The ERC-3643 reference declares these events unindexed — matching it is conformance | Accepted by design |

**0 High · 0 Medium · 10 Low · 2 Informational. Nothing to fix.**

## Scope verification

Confirmed before triage, because a `--filter-paths` entry that matches nothing fails open and silently pulls
the whole vendored tree into scope:

| Check | Result |
|---|---|
| `grep -c 'lib/\|node_modules/' slither-report.md` | **0** — no vendored dependency in scope |
| `grep -c 'src/mocks/' slither-report.md` | **0** — mocks correctly excluded |

The filter list names dependencies individually (`openzeppelin-contracts`, `CMTAT`, `forge-std`) rather than
filtering `lib` wholesale. That still resolves correctly here — each entry matches its `lib/<dep>` path as a
substring, and `lib/CMTATv3.0.0` and `lib/openzeppelin-contracts-upgradeable` are caught by the `CMTAT` and
`openzeppelin-contracts` entries respectively. `lib/ERC-3643`, added this release, matches no entry, but it is
imported by nothing under `src/` so the compiler never pulls it in — confirmed by the zero `lib/` count above.
Worth revisiting if an `src/` contract ever imports from it.

## Changes since v3.0.0-rc4

**No change in counts:** 10 `calls-loop` + 2 `unindexed-event-address`, identical to rc4.

This is the expected outcome. The rc5 changes that touched production code — collapsing the
`contains()`/`add()` double lookup, adding `virtual` to internal functions, emitting `SetMaxRules` at
construction, NatSpec, and the rename of the mock rules — do not affect either detector. The mock rename is
invisible here because mocks are excluded from scope.

One triage change, not a count change: the `unindexed-event-address` disposition moves from **Deferred** to
**Accepted by design** (see below).

## Detailed triage

### IDs 0-9: `calls-loop`

Ten instances across `RulesManagementModule._transferred` (both overloads),
`RuleEngineBase._detectTransferRestriction`, `_detectTransferRestrictionFrom` and
`_messageForTransferRestriction`.

The engine exists to call a configurable list of rule contracts, so an external call inside a loop is the
product, not a defect. The risk the detector points at — unbounded iteration — is bounded on-chain by
`maxRules` (default **10**, `DEFAULT_MAX_RULES`), and the cap is now emitted at deployment so it is visible
from the event log alone.

Rules are trusted business logic by convention: the engine refuses to grant a role to an address currently
configured as a rule, and the documentation states that rule contracts must not hold
`RULES_MANAGEMENT_ROLE`.

**Decision: accepted by design.** Documented in `doc/technical/RuleEngine-with-CMTAT.md` §4.1 and
`RuleEngine-with-ERC3643.md` §4.4, and recorded as `A-3` in `CLAUDE_ANALYSIS.md`.

### IDs 10-11: `unindexed-event-address`

`TokenBound(address token)` and `TokenUnbound(address token)` in `IERC3643Compliance.sol` (lines 18 and 24)
declare their address parameter without `indexed`.

rc4 deferred this as "valid optimization, but ABI-breaking to change now". That reasoning was incomplete. The
ERC-3643 reference implementation declares the same two events **unindexed**:

```solidity
// lib/ERC-3643/contracts/compliance/modular/IModularCompliance.sol:82,89
event TokenBound(address _token);
event TokenUnbound(address _token);
```

(identically in `compliance/legacy/ICompliance.sol:85,92`.)

So the current declaration is **conformance with the standard**, not an oversight. Adding `indexed` would move
the parameter from the data section into a topic, changing the event's topic layout and breaking any indexer
written against the ERC-3643 interface. The correct place to change this is the standard, not this
implementation.

Note the contrast with `TokenSelfBindingApprovalSet`, which *is* indexed: that event is specific to this
project's extended module and carries no conformance obligation, so indexing it was free.

**Decision: accepted by design (spec conformance).** Upgraded from rc4's "deferred", since the reason is now
positive rather than merely cautious.

## Conclusion

**No actionable security fixes are required from this Slither run.** Both detectors are architectural
by-design outcomes, and neither is exploitable: `calls-loop` describes the engine's core dispatch, bounded by
an on-chain cap, and `unindexed-event-address` reflects deliberate conformance with the ERC-3643 event
signatures.
