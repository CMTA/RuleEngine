# Slither report — v3.0.0-rc7

| | |
|---|---|
| **Tool** | Slither 0.11.5 (run with `uvx --python 3.12 --from slither-analyzer==0.11.5`) |
| **Scope** | `src/`, **mocks excluded** |
| **Compiler** | solc 0.8.37, EVM Osaka, `pragma solidity ^0.8.27` |
| **Contracts analysed** | 111 |
| **Date** | 2026-10-15 |
| **Commit** | `3055fe2` (final rc7 code, after the code-quality review fixes) |

```bash
slither . --checklist --filter-paths "openzeppelin-contracts|test|CMTAT|forge-std|mocks" \
  > doc/security/audits/tools/v3.0.0-rc7/slither-report.md
```

**Result: 0 High · 0 Medium · 10 Low · 2 Informational — nothing to fix.**

| Detector | Severity | Instances | Assessment |
|---|---|---|---|
| `calls-loop` | Low | 10 | **By design** — the engine iterates its rule set; bounded by `maxRules` (default 10) |
| `unindexed-event-address` | Informational | 2 | **By design (spec conformance)** — `TokenBound` / `TokenUnbound` keep the unindexed signature of ERC-3643 |

**Scope verified:** `grep -c 'lib/\|node_modules/'` = **0** and `grep -c 'src/mocks/'` = **0** in this report, so
no vendored dependency or mock contract entered the analysis.

**Delta from the previous rc7 run (`850976f` + pragma): none in findings.** Same two detectors, same 10 + 2
instances, in the same functions; only `file:line` positions moved. The contract count drops 112 -> 111 because
`RuleEngineAccessControlShared` was folded into `RuleEngine` (code-quality review `D-2`). The other changes made
since (`A-3`, `B-1`, `B-2`, `E-2`, `I-1`, `G-2`, deployables moved to `src/deployment/accessControl/` and
`src/deployment/ownable/`) touch the loops' bodies, the error style and comments, not the looped external calls
or the events. **Delta from v3.0.0-rc6: none in findings** (108 contracts then).

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
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L205-L210) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L208)
	Calls stack containing the loop:
		RuleEngineBase.created(address,uint256)

src/modules/RulesManagementModule.sol#L205-L210


 - [ ] ID-1
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L188-L202) has external calls inside a loop: [restriction = IRule(_rules.pos(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L196)
	Calls stack containing the loop:
		RuleEngineBase.canTransferFrom(address,address,address,uint256)
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L188-L202


 - [ ] ID-2
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L214-L226) has external calls inside a loop: [rule_.messageForTransferRestriction(restrictionCode)](src/RuleEngineBase.sol#L222)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L214-L226


 - [ ] ID-3
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L188-L202) has external calls inside a loop: [restriction = IRule(_rules.pos(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L196)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L188-L202


 - [ ] ID-4
[RulesManagementModule._transferred(address,address,address,uint256)](src/modules/RulesManagementModule.sol#L225-L230) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(spender,from,to,value)](src/modules/RulesManagementModule.sol#L228)
	Calls stack containing the loop:
		RuleEngineBase.transferred(address,address,address,uint256)

src/modules/RulesManagementModule.sol#L225-L230


 - [ ] ID-5
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L205-L210) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L208)
	Calls stack containing the loop:
		RuleEngineBase.transferred(address,address,uint256)

src/modules/RulesManagementModule.sol#L205-L210


 - [ ] ID-6
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L205-L210) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L208)
	Calls stack containing the loop:
		RuleEngineBase.destroyed(address,uint256)

src/modules/RulesManagementModule.sol#L205-L210


 - [ ] ID-7
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L169-L178) has external calls inside a loop: [restriction = IRule(_rules.pos(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L172)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L169-L178


 - [ ] ID-8
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L214-L226) has external calls inside a loop: [rule_.canReturnTransferRestrictionCode(restrictionCode)](src/RuleEngineBase.sol#L221)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L214-L226


 - [ ] ID-9
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L169-L178) has external calls inside a loop: [restriction = IRule(_rules.pos(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L172)
	Calls stack containing the loop:
		RuleEngineBase.canTransfer(address,address,uint256)
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L169-L178


## unindexed-event-address
Impact: Informational
Confidence: High
 - [ ] ID-10
Event [ITokenBinding.TokenBound(address)](src/interfaces/ITokenBinding.sol#L23) has address parameters but no indexed parameters

src/interfaces/ITokenBinding.sol#L23


 - [ ] ID-11
Event [ITokenBinding.TokenUnbound(address)](src/interfaces/ITokenBinding.sol#L31) has address parameters but no indexed parameters

src/interfaces/ITokenBinding.sol#L31


