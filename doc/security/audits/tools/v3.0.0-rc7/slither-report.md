# Slither report — v3.0.0-rc7

| | |
|---|---|
| **Tool** | Slither 0.11.5 (run with `uvx --python 3.12 --from slither-analyzer==0.11.5`) |
| **Scope** | `src/`, **mocks excluded** |
| **Compiler** | solc 0.8.37, EVM Osaka |
| **Contracts analysed** | 108 |
| **Date** | 2026-10-14 |
| **Commit** | `a91ca9a` |

```bash
slither . --checklist --filter-paths "openzeppelin-contracts|test|CMTAT|forge-std|mocks" \
  > doc/security/audits/tools/v3.0.0-rc7/slither-report.md
```

**Result: 0 High · 0 Medium · 10 Low · 2 Informational — nothing to fix.**

| Detector | Severity | Instances | Assessment |
|---|---|---|---|
| `calls-loop` | Low | 10 | **By design** — the engine iterates its rule set; bounded by `maxRules` (default 10) |
| `unindexed-event-address` | Informational | 2 | **By design (spec conformance)** — `TokenBound` / `TokenUnbound` keep the unindexed signature of the ERC-3643 reference |

**Scope verified:** `grep -c 'lib/\|node_modules/'` = **0** and `grep -c 'src/mocks/'` = **0** in this report, so
no vendored dependency or mock contract entered the analysis.

**Delta from v3.0.0-rc6: none.** Same two detectors, same 10 + 2 instances, and every citation (contract,
function, `file:line`) is identical to rc6. The only `src/` change since rc6 is the `VERSION` string and a
`forge fmt` re-wrap of two interface-ID constants. The build changes (solc 0.8.36 -> 0.8.37, EVM Prague -> Osaka,
CMTAT v3.3.0-rc4, forge-std v1.17.0) produced no finding.

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
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L211-L216) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L214)
	Calls stack containing the loop:
		RuleEngineBase.transferred(address,address,uint256)

src/modules/RulesManagementModule.sol#L211-L216


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
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L211-L216) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L214)
	Calls stack containing the loop:
		RuleEngineBase.destroyed(address,uint256)

src/modules/RulesManagementModule.sol#L211-L216


 - [ ] ID-4
[RulesManagementModule._transferred(address,address,address,uint256)](src/modules/RulesManagementModule.sol#L230-L235) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(spender,from,to,value)](src/modules/RulesManagementModule.sol#L233)
	Calls stack containing the loop:
		RuleEngineBase.transferred(address,address,address,uint256)

src/modules/RulesManagementModule.sol#L230-L235


 - [ ] ID-5
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L211-L222) has external calls inside a loop: [IRule(rule(i)).messageForTransferRestriction(restrictionCode)](src/RuleEngineBase.sol#L218)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L211-L222


 - [ ] ID-6
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L211-L216) has external calls inside a loop: [IRule(_rules.pos(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L214)
	Calls stack containing the loop:
		RuleEngineBase.created(address,uint256)

src/modules/RulesManagementModule.sol#L211-L216


 - [ ] ID-7
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L185-L199) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L193)
	Calls stack containing the loop:
		RuleEngineBase.canTransferFrom(address,address,address,uint256)
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L185-L199


 - [ ] ID-8
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L185-L199) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L193)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L185-L199


 - [ ] ID-9
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L166-L175) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L169)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L166-L175


## unindexed-event-address
Impact: Informational
Confidence: High
 - [ ] ID-10
Event [ITokenBinding.TokenBound(address)](src/interfaces/ITokenBinding.sol#L20) has address parameters but no indexed parameters

src/interfaces/ITokenBinding.sol#L20


 - [ ] ID-11
Event [ITokenBinding.TokenUnbound(address)](src/interfaces/ITokenBinding.sol#L26) has address parameters but no indexed parameters

src/interfaces/ITokenBinding.sol#L26


