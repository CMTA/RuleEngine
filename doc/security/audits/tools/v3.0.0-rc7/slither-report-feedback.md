# Slither Report — Assessment Feedback

**Tool:** [Slither](https://github.com/crytic/slither) 0.11.5 (run with `uvx --python 3.12 --from slither-analyzer==0.11.5`)
**Report file:** `doc/security/audits/tools/v3.0.0-rc7/slither-report.md`
**Assessment date:** 2026-10-16 (commit `29556e5`: the final rc7 code, `src/` as of `c7a19c7`, after the rc7 security review fixes; earlier runs at `3055fe2`, `a91ca9a`, `4946c87` and `850976f` + pragma gave the same findings)
**Scope:** `src/`, **mocks excluded**, 111 contracts analysed, solc 0.8.37 / EVM Osaka, `pragma ^0.8.27`

```bash
slither . --checklist --filter-paths "openzeppelin-contracts|test|CMTAT|forge-std|mocks" \
  > doc/security/audits/tools/v3.0.0-rc7/slither-report.md
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

## Changes since v3.0.0-rc6

**None in findings.** Same two detectors, same 10 + 2 instances, in the same functions: the two
`RulesManagementModule._transferred` overloads, the three `RuleEngineBase` view loops, and the two `ITokenBinding`
events.

That holds although rc7 changed `src/` substantially, and it is worth recording why:

- **ERC-2771 token-identity fix** (`4946c87`): `_checkBoundToken` and the token self-binding check compare
  `msg.sender`. Neither function contains a loop or an event.
- **ERC-2771 made opt-in, six deployables** (`a183425`, `850976f`): `RuleEngine`, `RuleEngineOwnable` and
  `RuleEngineOwnable2Step` lost the forwarder; `RuleEngine2771`, `RuleEngineOwnable2771` and
  `RuleEngineOwnable2Step2771` carry it; the RBAC logic moved to the abstract `RuleEngineAccessControlShared`. These
  are constructors, access-control hooks and `Context` overrides: no external call in a loop, no new event. The
  contract count rose 108 -> 112 (three deployables and the shared base) with no new result.
- **Pragma `^0.8.20` -> `^0.8.27`**, following the Aderyn `L-2` triage (see its feedback). No Slither detector
  depends on it; the output is identical before and after.
- `VERSION` string, `forge fmt` re-wrap of two interface-ID constants.

- **Code-quality review fixes, after the previous run** (up to `3055fe2`): `RuleEngineAccessControlShared` folded
  into `RuleEngine`, so `RuleEngine2771` extends `RuleEngine` (`D-2`; 112 -> 111 contracts); the deployables moved
  to `src/deployment/accessControl/` and `src/deployment/ownable/`; the view loops read `_rules` directly and
  cache the rule (`A-3`, `B-1`); `addRule` / `removeRule` rely on the set's return value (`B-2`); every
  conditional `revert` became a `require` (`E-2`); `IRule` was narrowed with the legacy ID still accepted
  (`I-1`); stale NatSpec fixed (`G-2`). The `calls-loop` instances are the same calls in the same five functions
  (`IRule(_rules.pos(i))` instead of `IRule(rule(i))` in the views); the events are unchanged, and their NatSpec
  now records why they stay unindexed.

- **rc7 security review fixes, after the `3055fe2` run** (`efaf860` F-1, `9c43b01` F-2, `c7a19c7` F-3):
  `RuleEngineOwnable2Step.acceptOwnership` re-checks the rule-account guard; an administrative unbind revokes the
  token's self-binding approval (`TokenBindingExtendedModule._unbindToken` override); rules and bound tokens are
  kept disjoint (`_checkBindingTarget` hook, bound-token check in `_checkRule`). Checks and one internal hook: no
  external call in a loop, no event. The report is byte-identical to the `3055fe2` one.

**Runs:** `a91ca9a` (2026-10-14), `4946c87`, `850976f` + pragma, `3055fe2` (2026-10-15), and this final run at `29556e5` (2026-10-16).
Same 12 findings each time; only `file:line` positions moved with the edited files.

The rest of rc7 is build and dependency changes: solc 0.8.36 -> **0.8.37**, EVM Prague -> **Osaka**, CMTAT
v3.3.0-rc4 (NatSpec-only change to `IRuleEngine`), forge-std v1.17.0, and T-REX 4.2.0-beta1 in `lib/ERC-3643`.
None of these produced a finding. `lib/ERC-3643` is still imported by nothing under `src/` (only by
`test/ERC3643Real/`, which the default Foundry profile skips), so the `lib/` count stays at 0.

**Tooling note:** the global Slither install (Python 3.10 site-packages) no longer starts after the system moved
to Python 3.14. The same version, 0.11.5, was run in an isolated `uvx` environment on Python 3.12, so the
results are comparable with rc6.

## Detailed triage

### IDs 0-9: `calls-loop`

Ten instances across `RulesManagementModule._transferred` (both overloads, `RulesManagementModule.sol:205-210`
and `:225-230`), `RuleEngineBase._detectTransferRestriction` (`RuleEngineBase.sol:169-178`),
`_detectTransferRestrictionFrom` (`:188-202`) and `_messageForTransferRestriction` (`:214-226`). Slither counts one
instance per call path that reaches the loop (for example `created`, `destroyed` and `transferred` all reach the
3-argument `_transferred`).

The engine exists to call a configurable list of rule contracts, so an external call inside a loop is the
product, not a defect. The risk the detector points at — unbounded iteration — is bounded on-chain by
`maxRules` (default **10**, `DEFAULT_MAX_RULES`), and the cap is emitted at deployment so it is visible from the
event log alone.

Rules are trusted business logic by convention: the engine refuses to grant a role to an address currently
configured as a rule, and the documentation states that rule contracts must not hold `RULES_MANAGEMENT_ROLE`.

**Decision: accepted by design.** Documented in `doc/technical/RuleEngine-with-CMTAT.md` §4.1 and
`RuleEngine-with-ERC3643.md` §4.4, and recorded as `A-3` in the rc5 `CLAUDE_ANALYSIS.md`.

### IDs 10-11: `unindexed-event-address`

`TokenBound(address token)` and `TokenUnbound(address token)`, declared in `ITokenBinding.sol` (lines 23 and
31), pass their address parameter without `indexed`.

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

Since the code-quality review (`C-2`), the NatSpec of both events in `ITokenBinding.sol` says they mirror the
ERC-3643 declaration and must stay non-indexed, so the decision is recorded next to the code.

**Decision: accepted by design (spec conformance).**

## Conclusion

**No actionable security fixes are required from this Slither run.** Both detectors are architectural by-design
outcomes, and neither is exploitable: `calls-loop` describes the engine's core dispatch, bounded by an on-chain
cap, and `unindexed-event-address` reflects deliberate conformance with the ERC-3643 event signatures.
