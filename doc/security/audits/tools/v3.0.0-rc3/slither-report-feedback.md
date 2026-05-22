# Slither Report — Assessment Feedback

**Tool:** [Slither](https://github.com/crytic/slither)  
**Report file:** `doc/security/audits/tools/slither-report.md`  
**Assessment date:** 2026-05-06

## Summary

| IDs | Detector | Tool Impact | Assessment | Decision |
|-----|----------|-------------|------------|----------|
| 0-9 | `calls-loop` | Low | Inherent to pluggable rule-engine dispatch architecture | Accepted by design |
| 10-12 | `unindexed-event-address` | Informational | Valid optimization note, but ABI-breaking to change now | Deferred |

## Detailed triage

### IDs 0-9: `calls-loop`
The RuleEngine intentionally iterates `_rules` and performs external rule calls for transfer checks and transfer hooks. This is core product behavior.  
Risk is controlled through trusted-rule governance and documented operational limits on rule count. No direct security defect is introduced by this detector output.

### IDs 10-12: `unindexed-event-address`
`TokenBound(address)` and `TokenUnbound(address)` could add `indexed` for cheaper filtering, but doing so changes event signatures and breaks existing consumers. `TokenSelfBindingApprovalSet(address,bool)` has been updated to index `token` (extension interface, acceptable change in this release). Keep deferring `TokenBound`/`TokenUnbound` to a planned major ERC-3643 interface revision.

## Conclusion
No actionable security fixes are required from this Slither run. Findings are architectural by-design, dependency style-only, or compatibility tradeoffs.
