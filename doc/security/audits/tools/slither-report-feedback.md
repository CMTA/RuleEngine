# Slither Report — Assessment Feedback

**Tool:** [Slither](https://github.com/crytic/slither)  
**Report file:** `doc/security/audits/tools/slither-report.md`  
**Assessment date:** 2026-05-05

## Summary

| IDs | Detector | Tool Impact | Assessment | Decision |
|-----|----------|-------------|------------|----------|
| 0-9 | `calls-loop` | Low | Inherent to pluggable rule-engine dispatch architecture | Accepted by design |
| 10 | `dead-code` (`RuleEngineOwnable2Step._msgData`) | Informational | False positive in context; required override in ERC2771/context inheritance chain | Accepted / no action |
| 11 | `naming-convention` (CMTAT dependency enum) | Informational | External dependency style issue, not project code risk | Ignored |
| 12-13 | `unindexed-event-address` | Informational | Valid optimization note, but ABI-breaking to change now | Deferred |

## Detailed triage

### IDs 0-9: `calls-loop`
The RuleEngine intentionally iterates `_rules` and performs external rule calls for transfer checks and transfer hooks. This is core product behavior.  
Risk is controlled through trusted-rule governance and documented operational limits on rule count. No direct security defect is introduced by this detector output.

### ID 10: `dead-code` on `RuleEngineOwnable2Step._msgData`
This override is part of required multiple-inheritance context resolution (`RuleEngineOwnableShared` + `Context`) for ERC2771-compatible message handling. Static analysis can mark it as unused even though it is part of the contract’s context surface and override chain. Keep as-is.

### ID 11: `naming-convention` in `lib/CMTAT/.../draft-IERC1404.sol`
Finding targets vendored dependency naming style. This is not a vulnerability and should not be patched locally unless forking upstream conventions intentionally.

### IDs 12-13: `unindexed-event-address`
`TokenBound(address)` / `TokenUnbound(address)` could add `indexed` for cheaper filtering, but doing so changes event signature and breaks existing consumers. Given low event frequency and backward-compatibility requirements, defer to a planned major interface revision.

## Conclusion
No actionable security fixes are required from this Slither run. Findings are architectural by-design, dependency style-only, or compatibility tradeoffs.
