# Slither Report — Assessment Feedback

**Tool:** [Slither](https://github.com/crytic/slither)
**Report file:** `slither-report.md`
**Codebase version:** v3.0.0-rc2
**Assessment date:** 2026-03-17

> Slither was run with `--show-ignored-findings` suppressed; this checklist reflects only non-ignored findings.

---

## Summary

| ID | Detector | Impact | Confidence | Assessment |
|----|----------|--------|------------|------------|
| 0–9 | `calls-loop` | Low | Medium | Accepted by design — see below |
| 10–11 | `unindexed-event-address` | Informational | High | Accepted — interface-breaking to fix |

---

## calls-loop (ID-0 to ID-9) — Low / Medium confidence

### What Slither reports

Ten instances of external calls inside loops, covering every call path through the rule-dispatch layer:

| ID | Function | Called from |
|----|----------|-------------|
| 0 | `_transferred(from, to, value)` | `transferred(address,address,uint256)` |
| 1 | `_messageForTransferRestriction` — `canReturnTransferRestrictionCode` | `messageForTransferRestriction` |
| 2 | `_detectTransferRestrictionFrom` | `detectTransferRestrictionFrom` |
| 3 | `_transferred(spender, from, to, value)` | `transferred(address,address,address,uint256)` |
| 4 | `_messageForTransferRestriction` — `messageForTransferRestriction` | `messageForTransferRestriction` |
| 5 | `_transferred(from, to, value)` | `destroyed` |
| 6 | `_detectTransferRestrictionFrom` | `canTransferFrom` → `detectTransferRestrictionFrom` |
| 7 | `_detectTransferRestriction` | `detectTransferRestriction` |
| 8 | `_detectTransferRestriction` | `canTransfer` → `detectTransferRestriction` |
| 9 | `_transferred(from, to, value)` | `created` |

### Assessment

**Accepted by design. No action required.**

The 10 results are all expressions of the same fundamental architecture: the RuleEngine fans out each transfer event to every registered rule contract by iterating `_rules` and making an external call per rule. This is the entire purpose of the contract — there is no way to implement a pluggable rule engine without external calls in a loop.

The typical concern behind this detector is reentrancy risk or gas griefing from a malicious external callee. Both are addressed:

- **Reentrancy:** Rule contracts are trusted components added by a privileged operator. Granting management roles to rule contracts is explicitly warned against in NatSpec (see also Nethermind AuditAgent finding 5 remediation). A reentrancy guard on every transfer would add significant gas overhead for no benefit given the trust model.
- **Gas griefing / DoS:** Operators are responsible for keeping the rule set sized for the target chain gas limits. This is documented in NatSpec on `addRule`, `setRules`, and `_transferred`, and warned about in the README (see also Nethermind AuditAgent finding 3 remediation).

These findings are expected and the pattern is inherent to the design. No code change is needed.

---

## unindexed-event-address (ID-10 to ID-11) — Informational / High confidence

### What Slither reports

- `IERC3643Compliance.TokenBound(address token)` — `token` is not indexed.
- `IERC3643Compliance.TokenUnbound(address token)` — `token` is not indexed.

### Assessment

**Valid observation. Not fixed — interface-breaking change.**

Adding `indexed` to the `token` parameter would allow off-chain tooling to filter `TokenBound` / `TokenUnbound` events by token address efficiently using a Bloom filter (topic-based filtering). Without `indexed`, a listener must fetch and decode all events of that type and filter client-side.

However, adding `indexed` changes the event's ABI signature (the topic hash), which is a breaking change for any off-chain application already listening for these events.

Given that:
- These events are emitted infrequently (only during administrative `bindToken` / `unbindToken` calls), so the filtering cost is negligible in practice.
- Changing the event signature breaks existing integrations.

**Decision: accepted as-is.** If the interface is ever revised for another reason, the `indexed` keyword should be added at the same time.

---

## Overall conclusion

Both finding categories are **accepted by design** and require no code changes for v3.0.0-rc2. The `calls-loop` pattern is inherent to the RuleEngine architecture; the `unindexed-event-address` finding is noted and deferred to a future interface revision.
