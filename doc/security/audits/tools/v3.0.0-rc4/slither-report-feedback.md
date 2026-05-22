# Slither Report — Assessment Feedback

**Tool:** [Slither](https://github.com/crytic/slither)  
**Report file:** `doc/security/audits/tools/v3.0.0-rc4/slither-report.md`  
**Assessment date:** 2026-05-22

## Summary

| IDs | Detector | Tool Impact | Assessment | Decision |
|-----|----------|-------------|------------|----------|
| 0-9 | `calls-loop` | Low | Inherent to pluggable rule-engine dispatch architecture | Accepted by design |
| 10-11 | `unindexed-event-address` | Informational | Valid optimization note, but ABI-breaking to change now | Deferred |

## Changes since v3.0.0-rc3

`unindexed-event-address` count reduced from 3 to 2. The `TokenSelfBindingApprovalSet(address,bool)` finding (previously ID-12) was resolved by adding `indexed` to the `token` parameter in `ERC3643ComplianceExtendedModule`. The two remaining findings (`TokenBound` and `TokenUnbound` in `IERC3643Compliance`) are deferred as before.

## Detailed triage

### IDs 0-9: `calls-loop`
The RuleEngine intentionally iterates `_rules` and performs external rule calls for transfer checks and transfer hooks. This is core product behavior.  
Risk is controlled through trusted-rule governance and documented operational limits on rule count. No direct security defect is introduced by this detector output.

### IDs 10-11: `unindexed-event-address`
`TokenBound(address)` and `TokenUnbound(address)` could add `indexed` for cheaper filtering, but doing so changes event signatures and breaks existing consumers. Keep deferring `TokenBound`/`TokenUnbound` to a planned major ERC-3643 interface revision.

## Conclusion
No actionable security fixes are required from this Slither run. Findings are architectural by-design or compatibility tradeoffs.
