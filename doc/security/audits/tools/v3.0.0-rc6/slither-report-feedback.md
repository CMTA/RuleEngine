# Slither Report — Assessment Feedback

**Tool:** [Slither](https://github.com/crytic/slither) 0.11.5
**Report file:** `doc/security/audits/tools/v3.0.0-rc6/slither-report.md`
**Assessment date:** 2026-08-20
**Scope:** `src/`, **mocks excluded**, 108 contracts analysed, solc 0.8.36 / EVM Prague

```bash
slither . --checklist --filter-paths "openzeppelin-contracts|test|CMTAT|forge-std|mocks" \
  > doc/security/audits/tools/v3.0.0-rc6/slither-report.md
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

The filter lists dependency names (`openzeppelin-contracts`, `CMTAT`, `forge-std`) rather than filtering `lib`
wholesale. That still resolves correctly here — each entry matches its `lib/<dep>` path as a substring, and
`lib/CMTATv3.0.0` and `lib/openzeppelin-contracts-upgradeable` are caught by the `CMTAT` and
`openzeppelin-contracts` entries. `lib/ERC-3643` matches no entry, but nothing under `src/` imports it, so the
compiler never pulls it in — confirmed by the zero `lib/` count above. Worth revisiting if that ever changes.

## Changes since v3.0.0-rc5

**No change in counts:** 10 `calls-loop` + 2 `unindexed-event-address`, identical to rc5. Contracts analysed
went 103 -> 108 with the modules and interfaces added by the token binding split.

The split moved code without adding findings, and it moved two citations:

- `unindexed-event-address` now reports `ITokenBinding.TokenBound` / `TokenUnbound`
  (`src/interfaces/ITokenBinding.sol#L20,L26`) instead of `IERC3643Compliance`. The events were relocated to the
  standard-agnostic interface; their signature is unchanged, so the disposition below is unchanged with it.
- `calls-loop` still reports the same ten sites in `RulesManagementModule._transferred` (both overloads),
  `RuleEngineBase._detectTransferRestriction`, `_detectTransferRestrictionFrom` and
  `_messageForTransferRestriction`. None of these files changed behaviourally this release.

Note what did **not** appear: the new `TokenBindingModule` / `TokenBindingExtendedModule` produced no finding of
their own, and the error rename (`RuleEngine_ERC3643Compliance_*` -> `TokenBinding_*`) is invisible to Slither.

## Detailed triage

### IDs 0-9: `calls-loop`

Ten instances across `RulesManagementModule._transferred` (both overloads),
`RuleEngineBase._detectTransferRestriction`, `_detectTransferRestrictionFrom` and
`_messageForTransferRestriction`.

The engine exists to call a configurable list of rule contracts, so an external call inside a loop is the
product, not a defect. The risk the detector points at — unbounded iteration — is bounded on-chain by
`maxRules` (default **10**, `DEFAULT_MAX_RULES`), and the cap is emitted at deployment so it is visible from the
event log alone.

Rules are trusted business logic by convention: the engine refuses to grant a role to an address currently
configured as a rule, and the documentation states that rule contracts must not hold `RULES_MANAGEMENT_ROLE`.

**Decision: accepted by design.** Documented in `doc/technical/RuleEngine-with-CMTAT.md` §4.1 and
`RuleEngine-with-ERC3643.md` §4.4, and recorded as `A-3` in the rc5 `CLAUDE_ANALYSIS.md`.

### IDs 10-11: `unindexed-event-address`

`TokenBound(address token)` and `TokenUnbound(address token)`, now declared in `ITokenBinding.sol` (lines 20 and
26), pass their address parameter without `indexed`.

The ERC-3643 reference implementation declares the same two events **unindexed**:

```solidity
// lib/ERC-3643/contracts/compliance/modular/IModularCompliance.sol:82,89
event TokenBound(address _token);
event TokenUnbound(address _token);
```

(identically in `compliance/legacy/ICompliance.sol:85,92`.)

Adding `indexed` would move the parameter from the data section into a topic, changing the topic layout and
breaking any indexer written against the ERC-3643 interface. The correct place to change this is the standard.

The move to `ITokenBinding` does not weaken that argument: `IERC3643Compliance` inherits the interface, so an
ERC-3643 consumer still sees exactly the reference signature. The generic interface deliberately kept it rather
than "improving" it, precisely so a binding registry reused elsewhere emits the same event an ERC-3643 indexer
already understands.

Note the contrast with `TokenSelfBindingApprovalSet`, which *is* indexed: it is specific to this project's
extended module and carries no conformance obligation, so indexing it was free.

**Decision: accepted by design (spec conformance).**

## Conclusion

**No actionable security fixes are required from this Slither run.** Both detectors are architectural by-design
outcomes, and neither is exploitable: `calls-loop` describes the engine's core dispatch, bounded by an on-chain
cap, and `unindexed-event-address` reflects deliberate conformance with the ERC-3643 event signatures.
