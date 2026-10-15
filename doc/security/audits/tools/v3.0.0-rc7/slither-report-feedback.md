# Slither Report — Assessment Feedback

**Tool:** [Slither](https://github.com/crytic/slither) 0.11.5 (run with `uvx --python 3.12 --from slither-analyzer==0.11.5`)
**Report file:** `doc/security/audits/tools/v3.0.0-rc7/slither-report.md`
**Assessment date:** 2026-10-15 (commit `4946c87`; re-run of the 2026-10-14 analysis at `a91ca9a`, output identical)
**Scope:** `src/`, **mocks excluded**, 108 contracts analysed, solc 0.8.37 / EVM Osaka

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

**None.** Same two detectors, same 10 + 2 instances, and a line-by-line comparison of the two reports finds every
citation (contract, function, `file:line`) identical.

That is the expected outcome, and it is worth recording why. Under `src/`, rc7 changes only:

- `VersionModule.VERSION` (`"3.0.0"` -> `"3.0.0-rc7"`), a string constant no detector looks at;
- a `forge fmt` re-wrap of the `RuleInterfaceId` and `ComplianceInterfaceId` constants (line breaks only);
- the ERC-2771 token-identity fix (`4946c87`): `TokenBindingModule._checkBoundToken` and the token self-binding
  check in `TokenBindingExtendedModule._authorizeTokenBindingChange` compare `msg.sender` instead of
  `_msgSender()`, plus NatSpec. Neither function contains a loop or an event, so no detector is concerned.

**Re-run:** the report was first generated at `a91ca9a` (2026-10-14), before the fix, then re-run at `4946c87`
(2026-10-15) with the same command. The two outputs are byte-identical.

The rest of rc7 is build and dependency changes: solc 0.8.36 -> **0.8.37**, EVM Prague -> **Osaka**, CMTAT
v3.3.0-rc4 (NatSpec-only change to `IRuleEngine`), forge-std v1.17.0, and T-REX 4.2.0-beta1 in `lib/ERC-3643`.
None of these produced a finding. `lib/ERC-3643` is still imported by nothing under `src/` (only by
`test/ERC3643Real/`, which the default Foundry profile skips), so the `lib/` count stays at 0.

**Tooling note:** the global Slither install (Python 3.10 site-packages) no longer starts after the system moved
to Python 3.14. The same version, 0.11.5, was run in an isolated `uvx` environment on Python 3.12, so the
results are comparable with rc6.

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
