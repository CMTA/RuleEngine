# RuleEngine — Code Quality Review (v3.0.0-rc7)

| | |
|---|---|
| **Scope** | `src/` (production contracts, mocks excluded except where named) and the **test suite** (`test/`) |
| **Base commit** | `4946c87` (rc7 with the ERC-2771 token-identity fix) |
| **Compiler** | solc 0.8.37, `evm_version = osaka`, optimizer on, 200 runs |
| **Date** | 2026-10-15 |
| **Produced with** | Claude Code |

## This is not a security audit

Nothing in this report is a vulnerability. No finding below lets an unauthorized party move value, bypass a
transfer restriction, or brick a contract. The one rc7 security change, the ERC-2771 token-identity fix, was
re-checked here (`H-2`) and holds.

This review covers the rc6 -> rc7 changes, re-checks the carried findings, and adds a full review of the
**tests** (check K): whether they assert what they claim, what they reach, and whether they can fail.

Method, so the reader can calibrate:

- **Gas numbers were measured**, on the real contracts, by toggling each change in place and re-running the same
  `gasleft()` harness (one test per path, so each measurement is its own transaction with cold storage). The
  harness was deleted afterwards and the source restored.
- **The pragma finding (`F-1`) is a compile result**: the production contracts were built with solc 0.8.20,
  0.8.24, 0.8.26 and 0.8.27.
- **Mutation testing was run, not estimated**: 33 mutants, each applied to `src/`, the full suite run, the file
  restored. The results are in `K-3`.
- **Coverage comes from `forge coverage`**, not from the test count.

Test count: 370 before, **395 after**. The 25 added tests are the ones written for check K (listed in
`K-6`). No benchmark or probe file is left behind; `git status` shows only the new tests.

## Disposition summary

| ID | Finding | Outcome |
|----|---------|---------|
| A-1 | Loop increment form and `unchecked` | ⬜ no finding — `++i` on 0.8.37, `unchecked` would buy nothing |
| A-2 | Unbounded iteration over caller-supplied arrays | ⬜ left as is — admin-gated, carried from rc5/rc6 |
| A-3 | View loops call the public `rule(i)`, re-checking the bound on every iteration | ⚠️ decide — measured −227 gas per rule per call; paid on-chain by ERC-3643 tokens |
| B-1 | `messageForTransferRestriction` resolves `rule(i)` twice, across an external call | ⚠️ decide — part of a measured −1,263 gas (3 rules) |
| B-2 | `contains()` before `add()` / `remove()` leaves two unreachable branches | ⚠️ decide — −271 / −268 gas, and removes the only uncovered branches |
| C-1 | Every event has exactly one emit site | ⬜ verified — 8/8, unchanged |
| C-2 | Batch self-binding approval emits the input, not the effect | ⚠️ still open — carried from rc5 |
| C-3 | Empty batches succeed silently (and the approval batch emits an empty event), while `setRules([])` reverts | ⚠️ decide |
| D-1 | Duplication across the three deployables | ⬜ no finding — compiler-mandated ERC-2771 trio only |
| E-1 | `virtual` on every internal function | ⬜ no finding — 0 missing |
| E-2 | 11 `if (...) revert X()` sites against the project's `require(cond, X())` convention | ⚠️ decide — together with `F-1` |
| F-1 | `pragma solidity ^0.8.20` is false: the code does not compile below **0.8.27** | ⚠️ decide — recommended fix: `^0.8.27`, plus 4 documents |
| F-2 | Advertised ERC-165 ids unchanged by rc7 | ⬜ verified — pinned by `IRuleInterfaceId.t.sol` |
| G-1 | NatSpec length and documentation pointers | ⬜ no finding — median 4 lines, max 19, zero `.md` pointers |
| G-2 | Stale or wrong NatSpec in production contracts (12 sites) | ⚠️ decide — comment-only |
| G-3 | `ERC3643TokenMock` header and a test header describe the pre-rc7 ERC-3643 setup | ✅ test header fixed / ⚠️ mock header to fix |
| G-4 | CHANGELOG rc7 said the `version()` string was "the only change under `src/`" | ✅ fixed |
| H-1 | View approves a mint that enforcement rejects | ⬜ documented — carried, unchanged |
| H-2 | Sender resolution after the ERC-2771 fix | ⬜ verified — exactly two identity sites, both `msg.sender` |
| I-1 | `IRule` demands two functions the engine never calls | ⚠️ still open — carried from rc6 |
| I-2 | Standalone-rule configuration advertised but untested | ⚠️ still open — carried from rc6 |
| I-3 | Engine should call `canTransfer` on rules? | ⬜ no — carried from rc6 |
| J-1 | Binding registry embeddable in a foreign host | ⬜ carried — inheritance unchanged in rc7; see `F-1` for the compiler floor |
| K-1 | Two tests used a bare `vm.expectRevert()` | ✅ fixed — both now name the error |
| K-2 | Coverage | ⬜ 100% lines / statements / functions; branches 39/41, the 2 missing are dead code (`B-2`) |
| K-3 | Mutation testing: 4 of 32 mutants survived | ✅ fixed — new tests kill all 33 (one mutant added) |
| K-4 | CI never runs the `erc3643` profile, so the real T-REX suite is outside CI | ⚠️ decide — one workflow step |
| K-5 | No fuzz and no invariant test in the suite | ✅ partly — 2 fuzz properties × 3 variants written; invariant test proposed |
| K-6 | `TokenSelfBindingApprovalSet` was never asserted | ✅ fixed — asserted in all three variants |

**Counted: 29 rows — 6 fixed (✅, `G-3` counted here although its mock half is open), 12 no-finding / verified /
left as is (⬜), 11 open decisions or carried items (⚠️).**

## Outstanding

| ID | Item | Why it is still open |
|----|------|----------------------|
| F-1 / E-2 | Raise the pragma to `^0.8.27` and convert the 11 `if/revert` sites | Changes every `src/` file header and four documents; a release decision, not a review edit |
| A-3 / B-1 / B-2 | Iterate `_rules.pos(i)` in the views, cache the rule in the message loop, use the `add` / `remove` return value | Measured and suite-verified (370/370 with the change), but a `src/` change |
| G-2 / G-3 | Comment fixes in `src/` and in the `ERC3643TokenMock` header | Comment-only, left for the same `src/` commit |
| K-4 | Run `FOUNDRY_PROFILE=erc3643 forge test` in CI | Workflow change |
| K-5 | Handler-based invariant test over the rule set and the binding set | Needs a design for the handler; proposed below |
| C-2 / C-3 | Batch approval event shape; empty-batch semantics | Event shape is API-visible to indexers; empty-batch behaviour is a product call |
| I-1 / I-2 | Narrow `IRule`; test or drop the standalone-rule claim | Coordinated with CMTA/Rules (see rc6 report) |
| H-1 | View/enforcement divergence | Inherent to the ERC-1404 3-argument signature |

---

## A. Loops and iteration

### A-1. Increment form — no finding

Every loop uses `++i`, none uses `unchecked`. On solc 0.8.37 the overflow check on a bounded loop counter is
already elided (since 0.8.22).

### A-2. Unbounded iteration over caller-supplied arrays — left as is

`setRules`, `bindTokens`, `unbindTokens` and `setTokenSelfBindingApprovalBatch` are gated on a manager role, so
only the operator can pass an oversized array and only their own transaction runs out of gas. Carried from rc5
`A-3` / rc6 `A-2`.

### A-3. The view loops go through the public `rule(i)` getter — decide

`RuleEngineBase.sol:168-169`, `:192-193` and `:216-218`:

```solidity
uint256 rulesLength = rulesCount();
for (uint256 i = 0; i < rulesLength; ++i) {
    uint8 restriction = IRule(rule(i)).detectTransferRestriction(from, to, value);
```

`rule(i)` is the public getter. It re-reads `_rules.length()` and checks `ruleId < length` on every iteration,
a check the loop bound already guarantees. The enforcement loops in `RulesManagementModule._transferred` use
`_rules.pos(i)` directly, so the two paths over the same set are written differently.

**Measured** (3 rules, toggled in place on the real contracts):

| Path | Before | After (`_rules.pos(i)`) | Δ |
|---|---|---|---|
| `detectTransferRestriction` | 24,619 | 23,937 | **−682** (−227 per rule) |
| `detectTransferRestrictionFrom` | 25,567 | 24,885 | **−682** |

**Why it is more than cosmetic:** a T-REX token calls `canTransfer` on-chain **before every transfer and mint**
(`test/ERC3643Real/` pins this with `expectCall`), so for an ERC-3643 deployment this is ~227 gas per rule on
every token operation, paid by users. CMTAT does not call the view on its transfer path, so CMTAT users only see
it in views.

**Fix:** `IRule(_rules.pos(i))` in the three view loops (and `using EnumerableSet for EnumerableSet.AddressSet;` in
`RuleEngineBase`). With this change the full suite passed, 370/370. **Verdict: implement.**

## B. Storage reads

### B-1. `messageForTransferRestriction` resolves the rule twice — decide

`RuleEngineBase.sol:217-218`:

```solidity
if (IRule(rule(i)).canReturnTransferRestrictionCode(restrictionCode)) {
    return IRule(rule(i)).messageForTransferRestriction(restrictionCode);
```

The second `rule(i)` re-reads the length and the set slot after an external call, which the optimizer cannot
forward across. Caching it in a local (`IRule rule_ = IRule(_rules.pos(i));`) together with `A-3` measured
**30,340 -> 29,077 (−1,263 gas)** with the claiming rule third of three. View-only, so it only matters for an
on-chain caller. **Verdict: implement with `A-3`**; it is the same edit.

### B-2. A `contains()` check before the mutation leaves two branches no test can reach — decide

`removeRule` checks membership and then `_removeRule` removes:

```solidity
require(_rules.contains(address(rule_)), RuleEngine_RulesManagementModule_RuleDoNotMatch());   // :97
...
require(_rules.remove(address(rule_)), RuleEngine_RulesManagementModule_OperationNotSuccessful()); // :194
```

`_addRule` does the same through `_checkRule` (`_rules.contains(rule_)` at `:255`, then `_rules.add` at `:181`).
In both cases the second check is unreachable: the comments say "should never revert". `forge coverage`
confirms it: these are **the only two uncovered branches in `src/`** (`K-2`), and
`RuleEngine_RulesManagementModule_OperationNotSuccessful` is the only custom error no test can trigger.

This is the same pattern the rc5 `B-1` fix removed from the token binding (`require(_boundTokens.add(token), ...)`),
which is still its documented style (`TokenBindingModule.sol:102-104`).

**Fix:** use the return value, keeping the specific error.

```solidity
// removeRule: drop the contains() line; in _removeRule:
require(_rules.remove(address(rule_)), RuleEngine_RulesManagementModule_RuleDoNotMatch());
// _checkRule: drop the duplicate check; in _addRule:
require(_rules.add(address(rule_)), RuleEngine_RulesManagementModule_RuleAlreadyExists());
```

**Measured:** `removeRule` 27,226 -> 26,958 (**−268**), `addRule` 69,010 -> 68,739 (**−271**). Full suite 370/370
with the change. One behavioural detail to state: adding a duplicate now performs the ERC-165 call before
reverting with `RuleAlreadyExists`. The error is the same and only the revert path is affected.
`RuleEngine_RulesManagementModule_OperationNotSuccessful` then becomes unused, and can be removed or kept as a
reserved error. Removing it is an ABI change. **Verdict: implement**, at the same release as `A-3`.

## C. Events

### C-1. One emit site per event — verified

```
AddRule 1  RemoveRule 1  ClearRules 1  SetMaxRules 1
TokenBound 1  TokenUnbound 1  TokenSelfBindingApprovalSet 1  TokenSelfBindingApprovalBatchSet 1
```

Unchanged from rc6. With `K-6`, every one of the eight is now also asserted by a test.

### C-2. The batch approval event reports the input — still open

Carried verbatim from rc6 `C-2`: `setTokenSelfBindingApprovalBatch` emits the whole input array, and the
single-token setter emits a different event for the same transition.

### C-3. Empty batches are accepted, inconsistently with `setRules` — decide

`setRules([])` reverts (`RuleEngine_RulesManagementModule_ArrayIsEmpty`). `bindTokens([])`, `unbindTokens([])`
and `setTokenSelfBindingApprovalBatch([], b)` succeed as no-ops, and the last one **emits
`TokenSelfBindingApprovalBatchSet([], b)`**, an event that records nothing. Not a defect: nothing changes state.
But it is two conventions for the same input on sibling admin functions, and an indexer receives an empty event.
**Verdict: decide** whether empty batches should revert. No test was written: the expected value is the question.

## D. Duplication

### D-1. No new duplication — no finding

rc7 adds no code that is duplicated. The `_msgSender` / `_msgData` / `_contextSuffixLength` trio repeated in
`RuleEngine`, `RuleEngineOwnableShared`, `RuleEngineOwnable` and `RuleEngineOwnable2Step` is compiler-mandated
(each contract must name its bases in `override(...)`), as recorded in rc5 `D-1`.

## E. `virtual` and style conventions

### E-1. `virtual` coverage — no finding

Zero `internal` functions in `src/` (mocks excluded) lack `virtual`.

### E-2. Error style is split 11 / 8 against the project's own rule — decide

`CLAUDE.md`: "Use `require(condition, CustomError(...))` for custom errors; avoid direct `revert CustomError(...)`."
`src/` has **8** `require(cond, Error())` and **11** `if (...) { revert Error(); }`:

```
RuleEngine.sol:41, :64          RulesManagementModule.sol:54, :57, :81, :165, :253, :256
TokenBindingModule.sol:150      RuleEngineBase.sol:231          RuleEngineOwnableShared.sol:52
```

Including `TokenBindingModule._checkBoundToken`, edited in rc7 and left in the old form. Convention only, no
runtime difference was measured or claimed. **Verdict: decide together with `F-1`**: converting all of them
commits the code to `require` with custom errors, which is what sets the 0.8.27 floor.

## F. Specification and compiler conformance

### F-1. `pragma solidity ^0.8.20` promises a range the code cannot compile in — decide

Every `src/` file declares `^0.8.20`, and `README.md:8` and `CLAUDE.md` / `AGENTS.md:12` say
"**Solidity:** ^0.8.20". Built with each compiler (`forge build --use <v> src/deployment`):

| solc | Result |
|---|---|
| 0.8.20 | fails — `lib/CMTAT/.../ERC1404ExtendInterfaceId.sol` requires `^0.8.24` |
| 0.8.24 | fails — `Error (9322)`: no `require(bool, error)` overload |
| 0.8.26 | fails — "Require with a custom error is only available using the via-ir pipeline" |
| **0.8.27** | **compiles** |

`require(cond, CustomError())` exists only from 0.8.26 (IR pipeline) and 0.8.27 (legacy pipeline), and the
project uses it in 8 places. The real floor of the production code is **0.8.27**.

**Consequences.** An integrator who takes the pragma at its word (`^0.8.20`) and compiles with 0.8.24–0.8.26 gets
a compile error, not wrong bytecode, so this is not a security issue. But two documented claims rest on the false
range:

- The rc7 Aderyn feedback (`L-2`) accepts the floating pragma because "`^0.8.20` is the supported range for
  integrators" and because it "lets [`TokenBindingModule`] compile inside a consumer's build". `TokenBindingModule`
  itself uses `require` with a custom error, so it does not compile below 0.8.27 either.
- `doc/technical/RuleEngine-with-ERC3643.md:198` says "the engine is `^0.8.20`".

**Fix:** `pragma solidity ^0.8.27;` in `src/`, and update `README.md`, `CLAUDE.md` / `AGENTS.md`,
`RuleEngine-with-ERC3643.md:198` and the Aderyn `L-2` text. The `erc3643` profile (0.8.30) is unaffected.
The alternative, converting the 8 `require` to `if/revert`, would only reach `^0.8.24` (CMTAT's floor) and goes
against the project's convention. **Verdict: implement `^0.8.27`.**

### F-2. Interface ids unchanged by rc7 — verified

rc7 touches the id libraries only through a `forge fmt` re-wrap. `testInterfaceIdConstantsMatchTheirWireValues`
pins all five values (`0x2497d6cb`, `0x3144991c`, `0x646ba2be`, `0x7157797f`, `0xab84a5c8`) and passes.

## G. Code / documentation mismatch

### G-1. NatSpec proportion and documentation pointers — no finding

153 NatSpec blocks in `src/` (mocks excluded): median **4** lines, 90th percentile **9**, maximum **19**
(`ERC3643ComplianceModule` header). The rc7 additions (`IMPORTANT:` notes of 5 and 6 lines on the two
token-identity checks) state a safety precondition and why it holds, which is what earns a comment its place.
Zero `.md` / `doc/` pointers in production comments.

### G-2. Stale or wrong NatSpec in production contracts — decide

| Site | Text | Problem |
|---|---|---|
| 12 sites: `RuleEngine.sol:125/133/141`, `RuleEngineOwnableShared.sol:61/69/77`, `RuleEngineOwnable.sol:50/58/66`, `RuleEngineOwnable2Step.sol:71/79/87` | "This surcharge is not necessary if you do not use the MetaTxModule" | No `MetaTxModule` exists (it is `ERC2771ModuleStandalone`), and the override is **not** optional: the contracts do not compile without it |
| `RulesManagementModule.sol:186-188` (`_removeRule`) | "Revert if the rule found at the specified index does not match the rule in argument" | There is no index; describes a removed API |
| `RulesManagementModule.sol:201`, `:219` (`_transferred`) | "Go through all the rule to know if a restriction exists on the transfer" | These functions **enforce** (call `transferred`), they do not detect |
| `RulesManagementModule.sol:13` | `@title RuleEngine -  part` | Placeholder title |
| `RuleEngineBase.sol:59` | `// Apply  on RuleEngine` | Placeholder comment |
| `RuleEngineBase.sol:91` | "restricion" | Typo |
| `RuleEngine.sol:106-108` | `ERC-2771` section header | Sits above the three access-control hooks |
| `TokenBindingModule.sol:57`, `TokenBindingExtendedModule.sol:28`, `ERC3643ComplianceModule.sol:36` | `PUBLIC/public FUNCTIONS` | Should read `PUBLIC/EXTERNAL` like the other modules |
| `VersionModule.sol` | `/* ==== Events ==== */` | Empty section |

The first row matters most: it sits on the functions whose sender resolution the rc7 fix is about, and it tells
a reader the ERC-2771 plumbing can be dropped. **Verdict: implement** (comment-only).

### G-3. The ERC-3643 mock and its test still describe the pre-rc7 setup — test fixed, mock open

rc7 moved `lib/ERC-3643` to T-REX 4.2.0-beta1 and added the real-token suite. Two headers were not updated:

- `test/RuleEngine/ERC3643TokenIntegration.t.sol` said the mock is modelled on "`lib/ERC-3643` (4.1.3)". **Fixed:**
  it now says the mock follows T-REX 4.1.3 and points to `test/ERC3643Real/` for the real 4.2.0-beta1 token.
- `src/mocks/ERC3643TokenMock.sol:13-22` says the reference is "tag 4.1.3", that the real token "cannot be
  compiled into this test suite", that it pins 0.8.17 while "this project compiles with 0.8.36", and that it
  depends on OpenZeppelin 4.8.x. All four claims are now false: 4.2.0-beta1 uses OpenZeppelin 5, pins 0.8.30,
  and **is** compiled, by the `erc3643` profile. **Open**, left for the `src/` comment commit (`G-2`).

### G-4. CHANGELOG rc7 claimed the version string was the only `src/` change — fixed

The rc7 "Breaking change" bullet on `version()` ended with "This is the only change under `src/` since rc6",
which `4946c87` made false. The sentence is removed.

## H. Weird behaviour

### H-1. The view/enforcement divergence — carried, unchanged

See the rc5 report. rc7 touched neither path.

### H-2. Sender resolution after the ERC-2771 fix — verified

Every sender check in `src/` (mocks excluded):

| Site | Resolves | Purpose |
|---|---|---|
| `TokenBindingModule.sol:149` (`_checkBoundToken`) | `msg.sender` | token identity |
| `TokenBindingExtendedModule.sol:99` (self-binding) | `msg.sender` | token identity |
| `onlyRole` (OZ `AccessControl`), `onlyOwner` (OZ `Ownable`) | `_msgSender()` | operators, relayable |

There is no third token-identity site, and no operator check reads `msg.sender`, so the split the fix
introduced is complete. It is pinned by `ERC2771TokenGateTestBase` (7 tests × 3 variants) and by mutation
`M19` (`&&` -> `||` in the self-binding condition), which the suite kills.

## I. Interface granularity

`I-1` (`IRule` requires `canTransfer` / `canTransferFrom`, narrowed id `0xb1a69752`), `I-2` (standalone-rule
configuration advertised but untested) and `I-3` (no, the engine should not call the rule's `canTransfer`) are
carried unchanged from the rc6 report, which holds the full analysis. rc7 changed none of the interfaces.

## J. Modularity

### J-1. Carried — inheritance unchanged

rc7 changed no inheritance edge, so the rc6 compile probes (an unrelated ERC-2771 + RBAC host, and a CMTAT
token embedding `TokenBindingModule`) remain valid and were not repeated. One addition from `F-1`: a host
embedding the module must compile with **0.8.27 or later**, not 0.8.20 as the pragma says.

## K. Tests

### K-1. Correctness of the existing tests

- **Tautologies:** none. No `assertTrue(true)`, no self-comparison, no swallowed revert.
- **Bare `vm.expectRevert()`: 2, both fixed.** `ERC3643TokenIntegration.t.sol`:
  - `testSetComplianceRevertsWithoutSelfBindingApproval` accepted any revert. It now expects
    `AccessControlUnauthorizedAccount(token2, COMPLIANCE_MANAGER_ROLE)`, the error the real-token suite also pins.
  - `testTransferToUnlistedAddressReverts` accepted any revert, including an insufficient balance from a broken
    `setUp`. It now expects `ERC3643TokenMock_ComplianceNotFollowed`.
- **A negative test for every guard.** Every custom error in `src/` is reached by at least one
  `expectRevert`, except `RuleEngine_RulesManagementModule_OperationNotSuccessful`, which is unreachable (`B-2`).
  Unauthorized-caller tests were spot-checked for the role-gated functions (rule management, `setMaxRules`,
  single and batch binding, both approval setters) in the RBAC and Ownable suites; mutants M25-M27 confirm the
  access-control paths are asserted.
- **Through the public surface.** The new aggregation tests use answers set on a probe rule (independently
  known values), not a re-implementation of the engine's loop.

### K-2. Coverage, measured

`forge coverage --no-match-coverage "(mocks|test|script)" --report summary`, before the new tests:

| Contract | Lines | Statements | Branches | Funcs |
|---|---|---|---|---|
| `RuleEngineBase.sol` | 100% (51/51) | 100% (62/62) | 100% (5/5) | 100% (14/14) |
| `RuleEngineOwnableShared.sol` | 100% (16/16) | 100% (17/17) | 100% (2/2) | 100% (6/6) |
| `RuleEngine.sol` | 100% (26/26) | 100% (23/23) | 100% (5/5) | 100% (10/10) |
| `RuleEngineOwnable.sol` | 100% (12/12) | 100% (8/8) | — | 100% (7/7) |
| `RuleEngineOwnable2Step.sol` | 100% (15/15) | 100% (12/12) | — | 100% (8/8) |
| `ERC3643ComplianceModule.sol` | 100% (6/6) | 100% (6/6) | 100% (2/2) | 100% (2/2) |
| `ERC3643ComplianceExtendedModule.sol` | 100% (2/2) | 100% (1/1) | — | 100% (1/1) |
| `RulesManagementModule.sol` | 100% (64/64) | 100% (60/60) | **86.67% (13/15)** | 100% (19/19) |
| `TokenBindingModule.sol` | 100% (24/24) | 100% (16/16) | 100% (7/7) | 100% (9/9) |
| `TokenBindingExtendedModule.sol` | 100% (24/24) | 100% (25/25) | 100% (5/5) | 100% (7/7) |
| `VersionModule.sol` | 100% (2/2) | 100% (1/1) | — | 100% (1/1) |
| **Total** | **100% (242/242)** | **100% (231/231)** | **95.12% (39/41)** | **100% (84/84)** |

The two uncovered branches, with a verdict:

| Branch | Verdict |
|---|---|
| `RulesManagementModule.sol:181` — `require(_rules.add(...), OperationNotSuccessful())` false side | **Dead code**: `_checkRule` already rejected a duplicate. A finding for the contract (`B-2`), not for the tests |
| `RulesManagementModule.sol:194` — `require(_rules.remove(...), OperationNotSuccessful())` false side | **Dead code**: `removeRule` already checked membership (`B-2`) |

The new tests do not change these numbers: line coverage was already full, and the two missing branches cannot
be reached. What the new tests add is shown by mutation (`K-3`), which coverage cannot show.

### K-3. Mutation testing — 4 of 32 survived; all 33 killed after the new tests

Each mutant was applied to `src/`, the full default suite run, and the file restored.

| Result | Mutants |
|---|---|
| **Killed by the existing suite (28)** | M02 code-0 early return · M04 4-arg `transferred` drops the spender · M07 ERC-165 drops IERC7551 · M08/M09 rule cap `>`/`>=` · M10 `setRules` without clear · M11 zero cap · M12/M13 enforcement loop skips rule 0 · M14 `rule(i)` bound · M15 empty `setRules` · M16 no `ClearRules` · M17 bind `address(0)` · M18 no `TokenUnbound` · M19 self-binding `&&`->`||` · M20 approval batch `address(0)` · M21/M22 batch bind/unbind skips first · M23 no batch event · M24 `getTokenBound` · M25 admin loses implicit roles · M26 rule receives a role · M27 rule becomes owner · M28/M29 no initial `SetMaxRules` · M30 constructor ignores token · M31 4-arg view asks the 3-arg path · M32 unbinding an unbound token succeeds |
| **Survived (4)** | **M01** `restriction > 0` -> `> 1` in `_detectTransferRestriction` · **M03** message taken from `rule(0)` instead of the claiming rule · **M05** `created` swaps `from`/`to` · **M06** `destroyed` swaps `from`/`to` |
| **Added (1)** | **M33** `setTokenSelfBindingApproval` emits nothing: also survived |

Why each survived:

- **M01:** no rule in the suite returns restriction code **1**. Every mock code is 8 or more, so a loop that
  ignores code 1 is indistinguishable.
- **M03:** no test has two rules where the claiming rule is not the first.
- **M05 / M06:** the default suite's whitelist lists both `address(0)` and the holder, so swapping them is
  invisible. The real-token suite pins the exact arguments with `expectCall` and **does** kill both (checked under
  `FOUNDRY_PROFILE=erc3643`: 2 and 1 failures), but that profile is not in CI (`K-4`).
- **M33:** the single-token approval event was never asserted (`K-6`).

After the new tests (`K-6`), the five were re-run: **all killed** (failing tests: M01 6, M03 3, M05 3, M06 3,
M33 3, that is, the new tests in each of the three variants). The surviving count is 0 of 33.

### K-4. CI never runs the real ERC-3643 suite — decide

`.github/workflows/ci.yml` runs `forge test -vvv` and `npx hardhat test`. `test/ERC3643Real/` is in the default
profile's `skip` list, so its 13 tests, the only ones against the genuine T-REX token, are never run by CI. `K-3`
shows this matters: two mutants were caught only there. **Fix:** a step running
`FOUNDRY_PROFILE=erc3643 forge test`. **Verdict: implement.**

### K-5. No fuzz or invariant tests — fuzz written, invariant proposed

The suite had **0** fuzz and **0** invariant tests. Now:

| Property | Kind | Where |
|---|---|---|
| `detectTransferRestriction` returns the first non-zero code in rule order, and `canTransfer == (code == 0)` | **fuzz** (`uint8 × uint8`, 256 runs) × 3 variants | `RuleAggregationTestBase.testFuzz_DetectReturnsFirstNonZeroCode` |
| The 4-argument view uses the rules' 4-argument answers, and `canTransferFrom == (code == 0)` | **fuzz** × 3 variants | `testFuzz_DetectFromReturnsFirstNonZeroCode` |
| Codes 1 and 255 are reported | spot-checked (deterministic, because fuzzing hits code 1 only ~1 run in 256) | `testBoundaryCodesAreReported` |
| The rule set never holds a duplicate or `address(0)`, and every member advertises `IRULE_INTERFACE_ID`, across any sequence of add/remove/set/clear | **proposed invariant** (handler over the four rule operations) | not written |
| A token is bound iff `isTokenBound`, and `getTokenBounds()` has no duplicate, across bind/unbind/batch | **proposed invariant** | not written |

`rulesCount() <= maxRules()` is deliberately **not** an invariant: lowering the cap below the current count is
allowed and tested (`testLoweredMaxRulesDoesNotRemoveExistingRulesButBlocksNewAdds`).

### K-6. Tests written

| Test | Variants | Kills / covers |
|---|---|---|
| `test/utils/RuleCodeProbe.sol` | — | Test-only rule whose codes, claimed code and message are set by the test; separate codes per path |
| `RuleAggregationTestBase` (7 tests: the 2 fuzz properties, boundary codes, message from the claiming rule, 3-arg and 4-arg rejection by the second rule, zero address on the right side in `created` / `destroyed`) | 3 (`test/RuleEngine*/RuleAggregation.t.sol`) | M01, M03, M05, M06 |
| `testSetTokenSelfBindingApprovalEmitsEvent` (approve and revoke, with `expectEmit`) | 3 | M33, event assertion gap |
| `testCannotBindTokensBatchWithDuplicateToken` (reverts on the second occurrence, batch rolls back) | RBAC | duplicate-in-batch edge case |
| Bare `expectRevert()` made specific | — | `K-1` |

**370 -> 395 tests** (21 aggregation + 3 event + 1 duplicate). All pass, as do the `erc3643` profile (13/13)
and the Hardhat smoke test; `forge fmt --check` is clean.

### K.3 edge cases, by family

| Family | Status | Missing / written |
|---|---|---|
| Zero and identity | `address(0)` rule, token, admin/owner: tested. `created` / `destroyed` zero-address side: **written** | `value == 0` and `from == to` are rule concerns, passed through unchanged; no engine test needed |
| Boundaries | cap exact, cap + 1, lowered cap, `rule(i)` out of range, empty `setRules`: tested. Restriction codes 1 and 255: **written** | Empty `bindTokens` / `unbindTokens` / approval batch: **not written, question** (`C-3`) |
| Duplicates and order | duplicate in `setRules`, already-bound / not-bound in batch: tested. Duplicate inside one batch: **written**. Rule order for detect / message / enforcement: **written** | — |
| State transitions | unbind then callback, re-bind, clear then add, ownership hand-over, approval revoked: tested | — |
| Authorization | unauthorized caller per protected function, rule as role holder or owner, relayed forwarder (rc7): tested | — |
| Reentrancy | not tested at engine level. The obligation is on the rule (`RuleEngine-with-CMTAT.md` §4.6); the engine keeps no state across the loop that a re-entering rule could corrupt without a privileged role | — |
| Events | 7 of 8 asserted before; `TokenSelfBindingApprovalSet`: **written**. All 8 now asserted | — |

## Changes after this review: the RBAC split

After this review, rc7 split the RBAC engine into `RuleEngine` (no ERC-2771, constructor `(admin, tokenContract)`)
and `RuleEngine2771` (immutable trusted forwarder, the rc6 `RuleEngine` behaviour), sharing the new abstract
`RuleEngineAccessControlShared`. Effect on the findings above:

- **`G-2`:** the three "surcharge … MetaTxModule" sites of `RuleEngine.sol` and its misplaced `ERC-2771` section
  header are gone. `RuleEngine2771` has accurate NatSpec on its ERC-2771 overrides. The other 9 sites (the ownable
  variants and `RuleEngineOwnableShared`) remain.
- **`E-2`:** the two `if/revert` sites of `RuleEngine.sol` (`:41`, `:64`) moved to `RuleEngineAccessControlShared`
  as `require(cond, Error())`, so 9 `if/revert` sites remain.
- **`H-2`:** unchanged. `RuleEngine` resolves every caller as `msg.sender` (OpenZeppelin `Context`); the two
  token-identity sites were already `msg.sender`.
- **Line numbers** cited above for `RuleEngine.sol` refer to commit `4946c87`.
- **Tests:** 395 -> 409 (see the rc7 CHANGELOG). Coverage stays at 100% of lines, statements and functions, with
  41/43 branches: the 2 missing are still the dead `OperationNotSuccessful` branches of `B-2`.
