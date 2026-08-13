# Slither report — v3.0.0-rc5

| | |
|---|---|
| **Tool** | Slither 0.11.5 |
| **Scope** | `src/`, **mocks excluded** |
| **Compiler** | solc 0.8.36, EVM Prague |
| **Contracts analysed** | 103 |
| **Date** | 2026-08-13 |

```bash
slither . --checklist --filter-paths "openzeppelin-contracts|test|CMTAT|forge-std|mocks" \
  > doc/security/audits/tools/v3.0.0-rc5/slither-report.md
```

**Result: 0 High · 0 Medium · 10 Low · 2 Informational — nothing to fix.**

| Detector | Severity | Instances | Assessment |
|---|---|---|---|
| `calls-loop` | Low | 10 | **By design** — the engine iterates its rule set; bounded by `maxRules` (default 10) |
| `unindexed-event-address` | Informational | 2 | **By design (spec conformance)** — the ERC-3643 reference declares these events unindexed |

**Scope verified:** `grep -c 'lib/\|node_modules/'` = **0** and `grep -c 'src/mocks/'` = **0** in this report, so
no vendored dependency or mock contract entered the analysis.

**Delta from v3.0.0-rc4: no change** — same two detectors, same 10 + 2 instances.

Triage and per-finding reasoning: [slither-report-feedback.md](./slither-report-feedback.md).
Overview of all analyses: [AUDIT_OVERVIEW.md](../../AUDIT_OVERVIEW.md).

---

**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [calls-loop](#calls-loop) (10 results) (Low)
 - [unindexed-event-address](#unindexed-event-address) (2 results) (Informational)
## calls-loop
Impact: Low
Confidence: Medium
 - [ ] ID-0
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L190-L195) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L193)
	Calls stack containing the loop:
		RuleEngineBase.destroyed(address,uint256)

src/modules/RulesManagementModule.sol#L190-L195


 - [ ] ID-1
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L211-L222) has external calls inside a loop: [IRule(rule(i)).canReturnTransferRestrictionCode(restrictionCode)](src/RuleEngineBase.sol#L217)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L211-L222


 - [ ] ID-2
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L166-L175) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L169)
	Calls stack containing the loop:
		RuleEngineBase.canTransfer(address,address,uint256)
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L166-L175


 - [ ] ID-3
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L211-L222) has external calls inside a loop: [IRule(rule(i)).messageForTransferRestriction(restrictionCode)](src/RuleEngineBase.sol#L218)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L211-L222


 - [ ] ID-4
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L190-L195) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L193)
	Calls stack containing the loop:
		RuleEngineBase.created(address,uint256)

src/modules/RulesManagementModule.sol#L190-L195


 - [ ] ID-5
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L185-L199) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L193)
	Calls stack containing the loop:
		RuleEngineBase.canTransferFrom(address,address,address,uint256)
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L185-L199


 - [ ] ID-6
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L185-L199) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L193)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L185-L199


 - [ ] ID-7
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L190-L195) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L193)
	Calls stack containing the loop:
		RuleEngineBase.transferred(address,address,uint256)

src/modules/RulesManagementModule.sol#L190-L195


 - [ ] ID-8
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L166-L175) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L169)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L166-L175


 - [ ] ID-9
[RulesManagementModule._transferred(address,address,address,uint256)](src/modules/RulesManagementModule.sol#L209-L214) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(spender,from,to,value)](src/modules/RulesManagementModule.sol#L212)
	Calls stack containing the loop:
		RuleEngineBase.transferred(address,address,address,uint256)

src/modules/RulesManagementModule.sol#L209-L214


## unindexed-event-address
Impact: Informational
Confidence: High
 - [ ] ID-10
Event [IERC3643Compliance.TokenBound(address)](src/interfaces/IERC3643Compliance.sol#L18) has address parameters but no indexed parameters

src/interfaces/IERC3643Compliance.sol#L18


 - [ ] ID-11
Event [IERC3643Compliance.TokenUnbound(address)](src/interfaces/IERC3643Compliance.sol#L24) has address parameters but no indexed parameters

src/interfaces/IERC3643Compliance.sol#L24


