# Audit and analysis overview

Index of every security and quality analysis performed on the RuleEngine, with the outcome of each.

This is an *overview of analyses*. For vulnerability reporting, see
[SECURITY.md](https://github.com/CMTA/CMTAT/blob/master/SECURITY.md) in the CMTAT main repository.

| | |
|---|---|
| **Current version** | v3.0.0-rc6 |
| **Compiler** | solc 0.8.36, EVM Prague, optimizer on (200 runs) |
| **Audited?** | **No.** v1.0.2 was audited by ABDK in March 2022; the 3.0.0 line has not been audited. |

## Scope

In scope: everything under `src/` except `src/mocks/`.

`src/mocks/` holds reference rules and test doubles — `RuleWhitelistMock`, `RuleMintAllowanceMock`,
`RuleConditionalTransferLightMock`, `RuleOperationRevertMock`, `ERC3643TokenMock` and their abstract bases.
They exist for tests, scripts and examples. Production rules are maintained separately in
[CMTA/Rules](https://github.com/CMTA/Rules). Static-analysis runs exclude them by default; findings that
concern a mock are labelled as such and do not apply to production deployments.

## Analyses

| Analysis | Version | Report | Assessment |
|---|---|---|---|
| Slither | v3.0.0-rc6 | [slither-report.md](./tools/v3.0.0-rc6/slither-report.md) | [feedback](./tools/v3.0.0-rc6/slither-report-feedback.md) |
| Aderyn | v3.0.0-rc6 | [aderyn-report.md](./tools/v3.0.0-rc6/aderyn-report.md) | [feedback](./tools/v3.0.0-rc6/aderyn-report-feedback.md) |
| Slither | v3.0.0-rc5 | [slither-report.md](./tools/v3.0.0-rc5/slither-report.md) | [feedback](./tools/v3.0.0-rc5/slither-report-feedback.md) |
| Aderyn | v3.0.0-rc5 | [aderyn-report.md](./tools/v3.0.0-rc5/aderyn-report.md) | [feedback](./tools/v3.0.0-rc5/aderyn-report-feedback.md) |
| Code-quality review | v3.0.0-rc5 | [CLAUDE_ANALYSIS.md](./tools/v3.0.0-rc5/CLAUDE_ANALYSIS.md) | — |
| Script review | v3.0.0-rc5 | [CLAUDE_ANALYSIS_SCRIPT.md](./tools/v3.0.0-rc5/CLAUDE_ANALYSIS_SCRIPT.md) | — |
| Slither | v3.0.0-rc4 | [slither-report.md](./tools/v3.0.0-rc4/slither-report.md) | [feedback](./tools/v3.0.0-rc4/slither-report-feedback.md) |
| Aderyn | v3.0.0-rc4 | [aderyn-report.md](./tools/v3.0.0-rc4/aderyn-report.md) | [feedback](./tools/v3.0.0-rc4/aderyn-report-feedback.md) |
| Nethermind AuditAgent | v3.0.0-rc1 | [report](./tools/nethermind-audit-agent/v3.0.0-rc1/audit_agent_report_1_v3.0.0-rc1.pdf) | [feedback](./tools/nethermind-audit-agent/v3.0.0-rc1/audit_agent_report_1_v3.0.0-rc1-feedback.md) |
| ABDK (external audit) | v1.0.1 -> v1.0.2 | [ABDK report (CMTAT repo)](https://github.com/CMTA/CMTAT/blob/master/doc/audits/ABDK_CMTA_CMTATRuleEngine_v_1_0/ABDK_CMTA_CMTATRuleEngine_v_1_0.pdf) | — |

## Static analysis results — v3.0.0-rc6

| Tool | High | Medium | Low | Info | Relevant to fix? |
|---|---|---|---|---|---|
| Slither 0.11.5 | 0 | 0 | 10 | 2 | **No** |
| Aderyn 0.6.5 | 0 | — | 8 (84 instances) | — | **No** |

Every finding is by design, cosmetic, or a verified false positive. Highlights:

- **`calls-loop` (Slither, 10)** — the engine iterating its rule set is the product. Bounded on-chain by
  `maxRules` (default 10).
- **`unindexed-event-address` (Slither, 2)** — `TokenBound` / `TokenUnbound`, now declared in `ITokenBinding`,
  match the ERC-3643 reference interface, which declares them unindexed. Conformance, not an oversight.
- **`L-8 Unchecked Return` (Aderyn, 1)** — `_grantRole` in a constructor cannot return `false`. False positive.

Slither: no change in counts from v3.0.0-rc5. Aderyn: same 8 findings, 76 -> 84 instances, entirely from the
file count — the token binding split added a net four files, and the two per-file detectors (`L-2` pragma,
`L-3` PUSH0) each moved by exactly four. No new finding came from the refactor.

## Substantive findings that were fixed

From the code-quality and script reviews of v3.0.0-rc5. None was exploitable; all were correctness, clarity or
usability defects.

| ID | Finding | Where |
|---|---|---|
| B-1 | `contains()` + `add()` double lookup on the bound-token set (269 gas, measured) | [CLAUDE_ANALYSIS.md](./tools/v3.0.0-rc5/CLAUDE_ANALYSIS.md) |
| C-1 | The initial `maxRules` was never emitted, so an event-only indexer could not reconstruct it | same |
| E-1 | `_bindToken` / `_unbindToken` were not `virtual`, unlike every sibling internal in the file | same |
| G-1 / H-1 | `canTransfer` fails open for spender-dependent rules; now documented at both rule and engine level | same |
| S-1 | `RuleEngineScript` never bound the token — every transfer in the resulting deployment reverted | [CLAUDE_ANALYSIS_SCRIPT.md](./tools/v3.0.0-rc5/CLAUDE_ANALYSIS_SCRIPT.md) |
| S-2 | Low-level `.call` to `CMTAT_ADDRESS` returned success against an EOA, silently misconfiguring | same |
| S-6..S-11 | Broken shebangs, undefined `$dir`, missing `mkdir -p`, no `set -euo pipefail` in the surya scripts | same |

Known limitations that were **documented rather than changed** are listed in the technical guides:
[RuleEngine-with-CMTAT.md](../../technical/RuleEngine-with-CMTAT.md) §4 and
[RuleEngine-with-ERC3643.md](../../technical/RuleEngine-with-ERC3643.md) §4.

## Reproducing the static analysis

```bash
# Slither — mocks excluded
slither . --checklist --filter-paths "openzeppelin-contracts|test|CMTAT|forge-std|mocks" \
  > doc/security/audits/tools/vX.Y.Z/slither-report.md

# Aderyn — mocks excluded. Keep --output inside the repository:
# Aderyn computes source links relative to it, so an external path bakes absolute paths into the report.
aderyn -x mocks --output doc/security/audits/tools/vX.Y.Z/aderyn-report.md
```

After either run, verify the scope actually held before trusting the counts:

```bash
grep -c 'lib/\|node_modules/' <report>   # expect 0 — a filter entry that matches nothing fails open
grep -c 'src/mocks/'          <report>   # expect 0 when mocks are excluded
```
