# RuleEngine — Code Quality Review (v3.0.0-rc7)

| | |
|---|---|
| **Scope** | `src/` (production contracts, mocks excluded except where named) and the **test suite** (`test/`) |
| **Commit** | `3b94564` — final rc7 code: six deployables, `pragma ^0.8.27` (second pass) |
| **First pass** | `4946c87` — rc7 with the ERC-2771 token-identity fix, before the deployable split |
| **Compiler** | solc 0.8.37, `evm_version = osaka`, optimizer on, 200 runs |
| **Date** | 2026-10-15 |
| **Produced with** | Claude Code |

## This is not a security audit

Nothing in this report is a vulnerability. No finding below lets an unauthorized party move value, bypass a
transfer restriction, or brick a contract. The one rc7 security change, the ERC-2771 token-identity fix, was
re-checked on the final code (`H-2`) and holds for all six deployables.

## Two passes

This report was produced twice during rc7, and both are kept so a reader can see what each changed:

- **First pass, `4946c87`.** Reviewed the rc6 -> rc7 changes, re-checked the carried findings, and added a full
  review of the **tests** (check K). It wrote 25 tests (370 -> 395) and recorded the open decisions.
- **Second pass, `3b94564` (this revision).** Between the passes, rc7 made ERC-2771 opt-in: each access-control
  model now has a deployable without a forwarder (`RuleEngine`, `RuleEngineOwnable`, `RuleEngineOwnable2Step`) and
  a `*2771` deployable with one, and the pragma moved to `^0.8.27` (`F-1`). Every finding was re-verified against
  the final code, every gas number re-measured, coverage re-run, the modularity probe re-run (`J-2`), and 17 new
  mutants applied to the code that moved or is new (`K-3`). Where a first-pass number changed, both are shown.

Method, so the reader can calibrate:

- **Gas numbers were measured**, on the real contracts, by toggling each change in place and re-running the same
  `gasleft()` harness (one test per path, so each measurement is its own transaction with cold storage). The
  harness was deleted afterwards and the source restored.
- **Compile claims are compile results**: `F-1` built the production contracts with solc 0.8.20, 0.8.24, 0.8.26
  and 0.8.27; `J-2` built a downstream host against the current and the pre-split code.
- **Mutation testing was run, not estimated**: 33 mutants in the first pass and 17 in the second, each applied
  to `src/`, the full suite run, the file restored.
- **Coverage comes from `forge coverage`**, not from the test count.

Test count: 370 at the first pass, 395 after it, **438** at the second pass (the split added the shared
ERC-2771 / no-forwarder suites; see the CHANGELOG). No benchmark or probe file is left behind.

## Disposition summary

| ID | Finding | Outcome |
|----|---------|---------|
| A-1 | Loop increment form and `unchecked` | ⬜ no finding — `++i` on 0.8.37, `unchecked` would buy nothing |
| A-2 | Unbounded iteration over caller-supplied arrays | ⬜ left as is — admin-gated, carried from rc5/rc6 |
| A-3 | View loops call the public `rule(i)`, re-checking the bound on every iteration | ✅ fixed after the second pass — −682 gas per detect call with 3 rules; paid on-chain by ERC-3643 tokens |
| B-1 | `messageForTransferRestriction` resolves `rule(i)` twice, across an external call | ✅ fixed after the second pass — −375 gas per call on top of `A-3` |
| B-2 | `contains()` before `add()` / `remove()` leaves two unreachable branches | ✅ fixed after the second pass — −271 / −268 gas, branch coverage 40/40; the old form added no security (assessed) |
| C-1 | Every event has exactly one emit site | ⬜ verified — 8/8, unchanged by the split |
| C-2 | Batch self-binding approval emits the input, not the effect | ⚠️ still open — carried from rc5 |
| C-3 | Empty batches succeed silently, while `setRules([])` reverts | ⚠️ revised — empty batches and `setRules([])` both follow a convention; the open point is `bindTokens` / `unbindTokens` reverting on an already-applied element |
| D-1 | ERC-2771 `Context` overrides repeated per deployable | ⬜ no finding — 3 copies, one per `*2771` contract (4 before the split), compiler-mandated |
| D-2 | The RBAC and ownable families implement the ERC-2771 split two different ways | ✅ fixed after the second pass — `RuleEngineAccessControlShared` folded into `RuleEngine`; deployables grouped in `accessControl/` and `ownable/` |
| E-1 | `virtual` on every internal function | ⬜ no finding — 0 missing, including the new contracts |
| E-2 | `if (...) revert X()` sites against the project's `require(cond, X())` convention | ⚠️ decide — 9 left (11 at the first pass) |
| F-1 | `pragma solidity ^0.8.20` was false: the code does not compile below 0.8.27 | ✅ fixed — `^0.8.27` everywhere (`3b94564`) |
| F-2 | Advertised ERC-165 ids unchanged by rc7, and identical between each pair | ⬜ verified — pinned by `IRuleInterfaceId.t.sol` and `ERC2771VariantTestBase` |
| G-1 | NatSpec length and documentation pointers | ⬜ no finding — median 5 lines, max 19, zero `.md` pointers |
| G-2 | Stale or wrong NatSpec in production contracts | ⚠️ partly fixed — the 12 "MetaTxModule" sites are gone, `_removeRule` fixed with `B-2`; 9 sites remain |
| G-3 | `ERC3643TokenMock` header and a test header describe the pre-rc7 ERC-3643 setup | ✅ test header fixed / ⚠️ mock header still open |
| G-4 | CHANGELOG rc7 said the `version()` string was "the only change under `src/`" | ✅ fixed |
| G-5 | `RuleEngine-with-CMTAT.md` §4.7 said every deployable inherits `ERC2771Context` | ✅ fixed — new in the second pass |
| H-1 | View approves a mint that enforcement rejects | ⬜ documented — carried, unchanged |
| H-2 | Sender resolution after the ERC-2771 fix and the split | ⬜ verified — two identity sites, both `msg.sender`; no-forwarder variants ignore any suffix |
| H-3 | A `*2771` deployable accepts `address(0)` as its forwarder | ⚠️ decide — new in the second pass |
| I-1 | `IRule` demands two functions the engine never calls | ⚠️ still open — carried from rc6, re-verified and restated in full; narrowed id `0xb1a69752` recomputed |
| I-2 | Standalone-rule configuration advertised but untested | ⚠️ still open — carried from rc6, restated; adds the unguarded `transferred` of the stateful mocks and the hardcoded `RULE_ENGINE_INTERFACE_ID` |
| I-3 | Engine should call `canTransfer` on rules? | ⬜ no — carried from rc6 |
| J-1 | Binding registry embeddable in a foreign host | Can ⬜ carried — inheritance of the registry unchanged |
| J-2 | ERC-2771 in the shared ownable layer blocked a host with its own forwarder | ✅ fixed by the split — verified by compile probe |
| K-1 | Two tests used a bare `vm.expectRevert()` | ✅ fixed — both name their error; 0 left |
| K-2 | Coverage | ⬜ 100% lines / statements / functions; branches 41/43 at the second pass (2 dead, `B-2`), **40/40** after `B-2` |
| K-3 | Mutation testing | ✅ first pass: 4 of 32 survived, all 33 killed after new tests; second pass: see `K-3` |
| K-4 | CI never runs the `erc3643` profile | ✅ fixed after the second pass — new CI step |
| K-5 | No fuzz and no invariant test | ✅ partly — 2 fuzz properties on all six deployables; invariant test proposed |
| K-6 | `TokenSelfBindingApprovalSet` was never asserted | ✅ fixed — asserted in the three access-control models |

**Counted: 33 rows — 14 fixed or partly fixed (✅, `G-3` and `K-5` counted here although part is open), 12
no-finding / verified / left as is (⬜), 7 open decisions or carried items (⚠️, `G-2` counted here).**

## Outstanding

| ID | Item | Why it is still open |
|----|------|----------------------|
| E-2 | Convert the 9 remaining `if/revert` sites | Style only; the `^0.8.27` floor allows either form |
| G-2 / G-3 | 9 comment fixes in `src/`, and the `ERC3643TokenMock` header | Comment-only, left for one `src/` commit |
| H-3 | Reject a zero forwarder in the `*2771` constructors | Changes the tests that use a zero forwarder; needs a new error |
| K-5 | Handler-based invariant test over the rule set and the binding set | Needs a design for the handler |
| C-2 / C-3 | Batch approval event shape; whether `bindTokens` / `unbindTokens` stay atomic or skip already-applied tokens | Event shape is API-visible to indexers; the binding batches deviate from the project's single-versus-batch revert convention, which is a product call |
| I-1 / I-2 | Narrow `IRule`; test or drop the standalone-rule claim (one question: is a rule only a plug-in, or also a minimal engine?) | Coordinated with CMTA/Rules |
| H-1 | View/enforcement divergence | Inherent to the ERC-1404 3-argument signature |

---

## A. Loops and iteration

### A-1. Increment form — no finding

Every loop uses `++i`, none uses `unchecked`. On solc 0.8.37 (and the `^0.8.27` floor) the overflow check on a
bounded loop counter is already elided (since 0.8.22).

### A-2. Unbounded iteration over caller-supplied arrays — left as is

`setRules`, `bindTokens`, `unbindTokens` and `setTokenSelfBindingApprovalBatch` are gated on a manager role, so
only the operator can pass an oversized array and only their own transaction runs out of gas. Carried from rc5
`A-3` / rc6 `A-2`.

### A-3. The view loops go through the public `rule(i)` getter — fixed

`RuleEngineBase.sol:169`, `:193` and `:217-218`:

```solidity
uint256 rulesLength = rulesCount();
for (uint256 i = 0; i < rulesLength; ++i) {
    uint8 restriction = IRule(rule(i)).detectTransferRestriction(from, to, value);
```

`rule(i)` is the public getter. It re-reads `_rules.length()` and checks `ruleId < length` on every iteration,
a check the loop bound already guarantees. The enforcement loops in `RulesManagementModule._transferred` use
`_rules.pos(i)` directly, so the two paths over the same set are written differently.

**Measured** (3 rules, toggled in place on the real `RuleEngine`):

| Path | First pass (`4946c87`) | Second pass (`3b94564`) |
|---|---|---|
| `detectTransferRestriction` | 24,619 -> 23,937 (**−682**) | 24,597 -> 23,949 (**−648**, −216 per rule) |
| `detectTransferRestrictionFrom` | 25,567 -> 24,885 (**−682**) | 25,545 -> 24,897 (**−648**) |

The baselines moved by about 20 gas between the passes because the plain `RuleEngine` lost the ERC-2771
functions, which changes the selector dispatch; the saving moved with them. Both measurements are kept rather
than overwritten.

**Why it is more than cosmetic:** a T-REX token calls `canTransfer` on-chain **before every transfer and mint**
(`test/ERC3643Real/` pins this with `expectCall`), so for an ERC-3643 deployment this is about 216 gas per rule on
every token operation, paid by users. CMTAT does not call the view on its transfer path.

**Fix:** `IRule(_rules.pos(i))` in the three view loops, and `using EnumerableSet for EnumerableSet.AddressSet;` in
`RuleEngineBase`. With this change the full suite passed, 438/438. **Verdict: implement.**

**Implemented after the second pass.** The three loops in `RuleEngineBase` (`_detectTransferRestriction`,
`_detectTransferRestrictionFrom`, `_messageForTransferRestriction`) now read `_rules.length()` once and call
`IRule(_rules.pos(i))`, the same form as the enforcement loops in `RulesManagementModule._transferred`. The bound
also moved from the public `rulesCount()` to `_rules.length()`, which the measurements above did not include.
Measured on the final edit with a throwaway probe (3 whitelist rules, all allowing, cold calls from a test; the
absolute numbers include cold-access costs and are not comparable with the table above, only the differences are):

| Path | Before | After | Difference |
|---|---|---|---|
| `detectTransferRestriction` | 40,269 | 39,587 | **−682** (−227 per rule) |
| `detectTransferRestrictionFrom` | 9,915 | 9,233 | **−682** |
| `messageForTransferRestriction` (code claimed by the first rule) | 5,262 | 4,794 | **−468** |

Full suite 438/438. The message loop still resolved the rule twice when a rule claimed the code; that is `B-1`,
implemented next.

## B. Storage reads

### B-1. `messageForTransferRestriction` resolves the rule twice — fixed

`RuleEngineBase.sol:217-218`:

```solidity
if (IRule(rule(i)).canReturnTransferRestrictionCode(restrictionCode)) {
    return IRule(rule(i)).messageForTransferRestriction(restrictionCode);
```

The second `rule(i)` re-reads the length and the set slot after an external call, which the optimizer cannot
forward across. Caching it (`IRule rule_ = IRule(_rules.pos(i));`) together with `A-3` measured **30,340 -> 29,077
(−1,263)** at the first pass and **30,318 -> 29,089 (−1,229)** at the second, with the claiming rule third of three.
View-only, so it only matters for an on-chain caller. **Verdict: implement with `A-3`**; it is the same edit.

**After `A-3`:** the two calls now read `IRule(_rules.pos(i))`, so what remains is one extra `pos(i)` storage read
after the external call.

**Implemented after `A-3`.** The loop body now reads:

```solidity
IRule rule_ = IRule(_rules.pos(i));
if (rule_.canReturnTransferRestrictionCode(restrictionCode)) {
    return rule_.messageForTransferRestriction(restrictionCode);
```

Measured with a throwaway probe (3 `RuleCodeProbe` rules claiming codes 50, 51 and 52; `A-3` already applied on
both sides):

| Claiming rule | Before | After | Difference |
|---|---|---|---|
| First of three | 18,362 | 17,987 | **−375** |
| Third of three | 18,992 | 18,631 | **−361** |

The saving does not grow with the position of the claiming rule: only the claiming iteration made the second
read. Full suite 438/438.

### B-2. A `contains()` check before the mutation leaves two branches no test can reach — fixed

`RulesManagementModule.sol:97` checks membership before `_removeRule` removes at `:194`; `_addRule` does the same
through `_checkRule` (`:255`, then `_rules.add` at `:181`). The second check is unreachable both times, and
`forge coverage` confirms these are **the only two uncovered branches in `src/`** (`K-2`).
`RuleEngine_RulesManagementModule_OperationNotSuccessful` is the only custom error no test can trigger.

The token binding already uses the return value (`require(_boundTokens.add(token), ...)`, the rc5 `B-1` fix).

**Fix:**

```solidity
// removeRule: drop the contains() line; in _removeRule:
require(_rules.remove(address(rule_)), RuleEngine_RulesManagementModule_RuleDoNotMatch());
// _checkRule: drop the duplicate check; in _addRule:
require(_rules.add(address(rule_)), RuleEngine_RulesManagementModule_RuleAlreadyExists());
```

**Measured:** `removeRule` −268 and `addRule` −271 at the second pass (27,072 -> 26,804 and 68,856 -> 68,585),
the same savings as the first pass. Full suite 438/438 with the change. Adding a duplicate now performs the
ERC-165 call before reverting with the same `RuleAlreadyExists`; only the revert path is affected.
`OperationNotSuccessful` then becomes unused; removing it is an ABI change. **Verdict: implement**, with `A-3`.

**Does the current form add a check, or any security?** No. Assessed point by point against the code:

- **No-duplicate invariant.** It is held by the `EnumerableSet` itself together with the
  `require(_rules.add(...))` in `_addRule` (`:181`), which is present in both the current and the proposed form.
  The `_checkRule` duplicate test (`:255`) only runs first. If a subclass overrode `_checkRule` without calling
  the parent, the current code would still reject the duplicate (with `OperationNotSuccessful`), and so would the
  proposed code (with `RuleAlreadyExists`). The redundant test adds no layer.
- **Removal.** `_rules.remove` returns `false` exactly when `contains` would, and the function has no external
  call or other state change before it, so `require(_rules.remove(...), RuleDoNotMatch())` rejects the same calls
  with the same error. Same for an override of `removeRule` that skipped the `contains()`: today it is caught by
  `OperationNotSuccessful` in `_removeRule`, after the fix by `RuleDoNotMatch`.
- **Order against the external call.** This is the only real difference: today a duplicate is rejected before
  `ERC165Checker.supportsInterface`, after the fix it is rejected after it. That call is a `staticcall` limited
  to 30,000 gas (OpenZeppelin `ERC165Checker.sol:135`), so the rule cannot change state or re-enter, and the rule
  is already in the set, so it is already trusted. Checks-effects-interactions is not at stake: the call
  is a read, and the revert discards everything.
- **Access.** Both paths stay behind `onlyRulesManager`; nothing changes who can reach them.

What the current form does buy, none of it security: a duplicate `addRule` fails before the ERC-165 call (cheaper
revert path); and the error is always `RuleAlreadyExists` for a duplicate, even when a mutable rule that is
already in the set has since stopped advertising `IRule` (after the fix that case reports
`RuleInvalidInterface`, because `_checkRule` runs first). `_checkRule` also stays a complete, standalone
validation hook for a subclass that calls it on its own; no contract in this repository does. The case for the
change remains gas (−271 / −268 on the success paths) and coverage (the only two dead branches in `src/`).

**Implemented after the second pass.** `removeRule` no longer calls `contains()`; `_removeRule` reverts with
`RuleDoNotMatch` when `_rules.remove` returns `false`. `_checkRule` keeps only the zero-address check; `_addRule`
reverts with `RuleAlreadyExists` when `_rules.add` returns `false`, which also covers a duplicate inside one
`setRules` batch. `RuleEngine_RulesManagementModule_OperationNotSuccessful` is removed (one error less in the ABI;
the same was done for `RuleEngine_ERC3643Compliance_OperationNotSuccessful` in rc6). The stale `_removeRule`
NatSpec ("specified index", `G-2`) is rewritten in the same edit.

Measured with a throwaway probe (`RuleEngine`, `RuleCodeProbe` rules, 2 rules present):

| Call | Before | After | Difference |
|---|---|---|---|
| `addRule` (success) | 68,327 | 68,056 | **−271** |
| `removeRule` (success) | 16,560 | 16,292 | **−268** |
| `addRule` of a rule already present (revert) | 6,088 | 11,042 | +4,954, the ERC-165 `staticcall` now runs first |
| `removeRule` of a rule not present (revert) | 1,698 | 1,778 | +80 |

Full suite 438/438. Each new `require` was mutated (the return value ignored): dropping the `add` check fails 6
tests, dropping the `remove` check fails 3. Branch coverage of `src/` is now **100% (40/40)**.

## C. Events

### C-1. One emit site per event — verified

```
AddRule 1  RemoveRule 1  ClearRules 1  SetMaxRules 1
TokenBound 1  TokenUnbound 1  TokenSelfBindingApprovalSet 1  TokenSelfBindingApprovalBatchSet 1
```

Unchanged by the split: the constructors of `RuleEngineAccessControlShared` and `RuleEngineOwnableShared` call
`_setMaxRules` and `_bindToken`, so every deployable emits the initial `SetMaxRules`, pinned for all six by
`RuleEngineMaxRulesEvent.t.sol`. All eight events are asserted by a test (`K-6`).

### C-2. The batch approval event reports the input — still open

Carried verbatim from rc6 `C-2`.

### C-3. Empty batches are accepted, inconsistently with `setRules` — revised

`setRules([])` reverts (`RuleEngine_RulesManagementModule_ArrayIsEmpty`). `bindTokens([])`, `unbindTokens([])`
and `setTokenSelfBindingApprovalBatch([], b)` succeed as no-ops, and the last one emits
`TokenSelfBindingApprovalBatchSet([], b)`, an event that records nothing. Two conventions for the same input on
sibling admin functions. **Verdict: decide**; no test was written because the expected value is the question.

**Revised after the second pass, against the project's single-versus-batch convention.** The project already
separates a single call from a batch call by whether a no-op reverts, for gas reasons. The reference rule
`RuleAddressList` states it in its NatSpec (`RuleAddressList.sol:41-75`):

- **single call** (`addAddressToTheList`, `removeAddressFromTheList`): an element that is already in the target
  state reverts, "to save gas": the operator's mistake is reported and the transaction costs almost nothing;
- **batch call** (`addAddressesToTheList`, `removeAddressesFromTheList`): an element already in the target state
  is skipped and "the transaction remains valid (no revert)", so one stale entry does not throw away the gas of
  the whole batch.

Read against that convention, the original finding compared the wrong things:

- **Empty batches succeeding is consistent.** An empty batch is the extreme case of a batch where no element
  changes anything, and under the batch rule a no-op does not revert. Making `bindTokens([])` revert would be the
  inconsistency.
- **`setRules([])` reverting is not a batch rule, and is not about gas.** `setRules` replaces the whole set, so
  `[]` would mean "remove every rule" and leave a bound token with no enforcement. The revert is a safety guard
  that sends the operator to the explicit `clearRules()`; it was reviewed by Nethermind (best practice 7 in
  `doc/README.md`) and kept by design. The two behaviours do not conflict: they answer different questions.
- **The real deviation is elsewhere: `bindTokens` / `unbindTokens` follow the single-call rule inside a batch.**
  Each element goes through `_bindToken` / `_unbindToken`, which `require` the `EnumerableSet` mutation to succeed
  (`TokenBindingModule.sol:104` and `:115`). One token that is already bound (or not bound, for `unbindTokens`)
  reverts the whole batch, and all the gas spent on the earlier elements is lost
  (`testCannotBindTokensBatchWithDuplicateToken` pins this for a duplicate). This is the opposite of the
  `RuleAddressList` batch rule. The Slither `L-6` triage records it as deliberate ("atomic batch operations",
  `doc/README.md`), but the reason is not written next to the functions, and the two conventions sit in the same
  repository.
- **`setTokenSelfBindingApprovalBatch` is consistent.** Setting a flag to the value it already has is not an
  error in the single call either, so neither form reverts on a no-op. Only the empty event remains, and it
  belongs to `C-2` (the event reports the input, not the effect).

**Verdict: revised.** Keep empty batches as no-ops and keep `setRules([])` reverting; both are now pinned to a
reason. The open decision moves to the binding batches:

- **keep them atomic**, and state in the `bindTokens` / `unbindTokens` NatSpec and in
  `doc/technical/TokenBinding-module.md` that they deliberately depart from the batch rule: a binding change is
  security-relevant, and an operator who lists a token that is already bound has probably made a mistake that
  should stop the whole operation; or
- **skip already-applied tokens**, like `RuleAddressList`: emit `TokenBound` / `TokenUnbound` only for tokens
  that changed, keep the zero-address check as a revert, and update the test above.
  Not measured; the cost of an atomic batch that reverts is the gas spent up to the failing element.

Either way, a test for the empty batches can now be written, since the expected value (no-op, no revert) is no
longer the question. Not written in this pass.

## D. Duplication

### D-1. ERC-2771 overrides — no finding

The `_msgSender` / `_msgData` / `_contextSuffixLength` trio now appears once in each `*2771` contract: 3 copies,
down from 4 at the first pass (when `RuleEngine`, `RuleEngineOwnableShared` and both ownable deployables carried
it). It is compiler-mandated: each contract must name its bases in `override(...)`.

### D-2. The two families implement the same split two ways — fixed

| Family | Without forwarder | With forwarder |
|---|---|---|
| RBAC | `RuleEngine is RuleEngineAccessControlShared` (constructor only, 5 nSLOC) | `RuleEngine2771 is ERC2771ModuleStandalone, RuleEngineAccessControlShared` |
| Ownable | `RuleEngineOwnable is RuleEngineOwnableShared, Ownable` | `RuleEngineOwnable2771 is ERC2771ModuleStandalone, RuleEngineOwnable` |

The ownable `*2771` contracts extend their deployable counterpart, while `RuleEngine2771` extends the abstract base
`RuleEngine` is built on. Both are correct and compile to the same behaviour; the difference is only in how a
reader navigates. Making the RBAC family match the ownable one (`RuleEngine2771 is ERC2771ModuleStandalone,
RuleEngine`) would let `RuleEngineAccessControlShared` be folded into `RuleEngine`; the reverse is not possible for
the ownable family, where the deployables hold the `Ownable` / `Ownable2Step` choice. **Verdict: decide** — a
consistency improvement with no runtime effect; leaving it is defensible because `RuleEngineAccessControlShared`
mirrors `RuleEngineOwnableShared` by name.

**Which option is better, for duplication and readability.** Analysed after the second pass, on request.

*Duplication: almost no difference.*

- The three ERC-2771 overrides (`_msgSender`, `_msgData`, `_contextSuffixLength`) stay in each of the three
  `*2771` contracts whichever way the RBAC family is built, because the compiler requires them in every contract
  that combines `ERC2771Context` with `Context` (`D-1`).
- The fold deletes `RuleEngineAccessControlShared.sol` (116 lines including NatSpec), but its code moves into
  `RuleEngine`. The net saving is about 20 lines: the current 20-line `RuleEngine` wrapper and one duplicated
  constructor parameter list. The argument for the change is readability, not duplication.

*Readability: the fold is clearly better.*

1. **One rule for all six deployables.** Each `X2771` would be `X` plus `ERC2771ModuleStandalone` plus the three
   overrides. Today a reader has to learn two layouts: `RuleEngine2771` does not extend `RuleEngine`, while
   `RuleEngineOwnable2771` extends `RuleEngineOwnable`.
2. **The ownable shared base earns its place; the RBAC one does not.** `RuleEngineOwnableShared` holds code used
   by two different deployables, `RuleEngineOwnable` and `RuleEngineOwnable2Step`.
   `RuleEngineAccessControlShared` exists only so that `RuleEngine2771` can avoid inheriting `RuleEngine`. After
   the fold it would have a single child: a layer of indirection with nothing to share.
3. **`RuleEngine` becomes readable on its own.** Today the deployable people open first is a 20-line wrapper, and
   the roles, the `hasRole` override and `supportsInterface` live one file away.
4. **The inheritance chain gets one level shorter** for both RBAC contracts.

*What argues for leaving it as is:*

- **Naming symmetry.** `RuleEngineAccessControlShared` mirrors `RuleEngineOwnableShared`. That is the only real
  argument, and it is cosmetic: the two names would look parallel while doing different jobs.
- **Abstract bases versus deployables.** Some teams prefer that a deployable never inherits another deployable.
  The ownable family already does it, so that rule does not hold in this project anyway.

*Cost of the fold:*

- **Code:** `src/deployment/RuleEngine.sol`, `src/deployment/RuleEngine2771.sol`, and deleting
  `src/RuleEngineAccessControlShared.sol`. No test or script references the shared base, so
  `RuleEngine2771Exposed` and the test suites stay as they are.
- **Docs:** `README.md`, `doc/README.md`, `CLAUDE.md` / `AGENTS.md` (inheritance tree and the "override the hooks
  in ..." instructions), `CHANGELOG.md`, the Surya schema, and this entry.
- **Behaviour:** none. Constructors, ABI, ERC-165 answers and roles are unchanged; only the bytecode layout
  changes, and the contracts are not upgradeable. The ownable family already compiles with this exact pattern,
  so no linearization conflict is expected. **Assumed, not checked: the RBAC version has not been compiled.**

**Recommendation:** fold `RuleEngineAccessControlShared` into `RuleEngine` and declare
`RuleEngine2771 is ERC2771ModuleStandalone, RuleEngine`. Not implemented.

**Implemented after the analysis.** `src/RuleEngineAccessControlShared.sol` is deleted and its content (constructor
checks, initial `SetMaxRules`, `grantRole` rule guard, `hasRole`, `supportsInterface`, the three access-control
hooks) now lives in `RuleEngine`, which extends `RuleEngineBase`, `AccessControlEnumerable` and the two role
storages directly. `RuleEngine2771 is ERC2771ModuleStandalone, RuleEngine`, so all six deployables follow the same
rule. On request, the deployables are also grouped by access-control model:

```
src/deployment/
├── accessControl/   RuleEngine, RuleEngine2771
└── ownable/         RuleEngineOwnable, RuleEngineOwnable2771, RuleEngineOwnable2Step, RuleEngineOwnable2Step2771
```

The abstract bases (`RuleEngineBase`, `RuleEngineOwnableShared`) stay in `src/`, since they are not deployable.
Verified: `forge build` without conflict (the "not compiled" assumption above is now checked), full suite
438/438, `FOUNDRY_PROFILE=erc3643 forge test` 13/13. The ERC-165 answers are pinned by `testSupportsInterfaces` and,
for each pair, by `ERC2771VariantTestBase`. The ABIs were **not** diffed against the previous commit (the
temporary worktree was not permitted); since the moved code is unchanged, no difference is expected. Import paths
in the scripts, tests, mocks, `package.json`, `doc/TOOLCHAIN.md` and `doc/script/script_sol2uml.sh` are updated,
and the Surya schema is regenerated. The coverage table in `K-2` predates the fold and still lists
`RuleEngineAccessControlShared.sol`.

## E. `virtual` and style conventions

### E-1. `virtual` coverage — no finding

Zero `internal` functions in `src/` (mocks excluded) lack `virtual`, including the four contracts added by the
split.

### E-2. Error style split 9 / 10 against the project's own rule — decide

`CLAUDE.md`: "Use `require(condition, CustomError(...))`." `src/` now has **10** `require` and **9**
`if (...) { revert ... }`:

```
RulesManagementModule.sol:54, :57, :81, :165, :253, :256    TokenBindingModule.sol:150
RuleEngineBase.sol:231                                       RuleEngineOwnableShared.sol:49
```

The two `RuleEngine.sol` sites of the first pass became `require` when they moved to
`RuleEngineAccessControlShared`. Convention only, no runtime difference measured or claimed. With the pragma at
`^0.8.27` (`F-1`), `require` with a custom error is available to every supported compiler, so the conversion has
no remaining obstacle. **Verdict: decide.**

## F. Specification and compiler conformance

### F-1. The pragma promised a range the code could not compile in — fixed

Every `src/` file declared `^0.8.20`. Built with each compiler (`forge build --use <v> src/deployment`):

| solc | Result with `^0.8.20` |
|---|---|
| 0.8.20 | fails — CMTAT's `ERC1404ExtendInterfaceId.sol` requires `^0.8.24` |
| 0.8.24 | fails — `Error (9322)`: no `require(bool, error)` overload |
| 0.8.26 | fails — "Require with a custom error is only available using the via-ir pipeline" |
| **0.8.27** | **compiles** |

**Fixed in `3b94564`:** all 58 files under `src/` and `script/` declare `^0.8.27`. Re-checked: 0.8.27 builds, and
0.8.26 is now refused by the pragma itself ("no solc version exists that matches") instead of failing inside a
`require`. `README.md`, `CLAUDE.md` / `AGENTS.md`, `RuleEngine-with-ERC3643.md` and the Aderyn `L-2` feedback
were updated. Tests keep `^0.8.20`: they are not distributed, and the `erc3643` profile pins 0.8.30.

### F-2. Interface ids unchanged by rc7 — verified

`testInterfaceIdConstantsMatchTheirWireValues` pins all five values (`0x2497d6cb`, `0x3144991c`, `0x646ba2be`,
`0x7157797f`, `0xab84a5c8`). The split adds a second guarantee: `ERC2771VariantTestBase` asserts, over 13
interface ids, that each `*2771` contract answers `supportsInterface` exactly like its counterpart without a
forwarder (ERC-2771 has no ERC-165 id).

## G. Code / documentation mismatch

### G-1. NatSpec proportion and documentation pointers — no finding

158 NatSpec blocks in `src/` (mocks excluded): median **5** lines, 90th percentile **9**, maximum **19**
(`ERC3643ComplianceModule` header). Zero `.md` / `doc/` pointers in production comments.

### G-2. Stale or wrong NatSpec in production contracts — partly fixed

**Fixed by the split:** the 12 "This surcharge is not necessary if you do not use the MetaTxModule" comments
(there is no `MetaTxModule`, and the overrides are not optional) and the misplaced `ERC-2771` section header of
`RuleEngine.sol`. The `*2771` contracts carry accurate NatSpec on their overrides.

**Still open (10 sites at the second pass; 9 after `B-2` fixed `_removeRule`):**

| Site | Text | Problem |
|---|---|---|
| `RulesManagementModule.sol:186-188` (`_removeRule`) | "Revert if the rule found at the specified index does not match the rule in argument" | There is no index; describes a removed API — **fixed with `B-2`** |
| `RulesManagementModule.sol:201`, `:219` (`_transferred`) | "Go through all the rule to know if a restriction exists on the transfer" | These functions **enforce** (call `transferred`), they do not detect. The same sentence is correct on `detectTransferRestriction` (`RuleEngineBase.sol:87`) |
| `RulesManagementModule.sol:13` | `@title RuleEngine -  part` | Placeholder title |
| `RuleEngineBase.sol:59` | `// Apply  on RuleEngine` | Placeholder comment |
| `RuleEngineBase.sol:91` | "restricion" | Typo |
| `TokenBindingModule.sol:57`, `TokenBindingExtendedModule.sol:28`, `ERC3643ComplianceModule.sol:36` | `PUBLIC/public FUNCTIONS` | Should read `PUBLIC/EXTERNAL` like the other modules |
| `VersionModule.sol:20` | `/* ============ Events ============ */` | Empty section |

**Verdict: implement** (comment-only).

### G-3. The ERC-3643 mock still describes the pre-rc7 setup — mock header open

The test header was fixed at the first pass. `src/mocks/ERC3643TokenMock.sol:13-22` still says the reference is
"tag 4.1.3", that the real token "cannot be compiled into this test suite", that it pins 0.8.17 while "this
project compiles with 0.8.36", and that it depends on OpenZeppelin 4.8.x. All four claims are false since rc7:
T-REX 4.2.0-beta1 uses OpenZeppelin 5, pins 0.8.30, and **is** compiled by the `erc3643` profile.

### G-4. CHANGELOG rc7 claimed the version string was the only `src/` change — fixed

Removed at the first pass.

### G-5. `RuleEngine-with-CMTAT.md` §4.7 still described every deployable as ERC-2771 — fixed

Found in the second pass: §4.7 opened with "Every deployable inherits `ERC2771Context`" and told the reader to use
"`address(0)` if gasless administration is not needed". Both were true at the first pass and false after the
split. It now names the three `*2771` deployables and says to deploy the contract without the suffix when gasless
administration is not needed. The other forwarder passages (`doc/README.md`, `RuleEngine-with-ERC3643.md` §4.5,
`TokenBinding-module.md` §4) were checked and are consistent.

## H. Weird behaviour

### H-1. The view/enforcement divergence — carried, unchanged

See the rc5 report.

### H-2. Sender resolution after the ERC-2771 fix and the split — verified

| Site | Resolves | Purpose |
|---|---|---|
| `TokenBindingModule.sol:149` (`_checkBoundToken`) | `msg.sender` | token identity |
| `TokenBindingExtendedModule.sol:99` (self-binding) | `msg.sender` | token identity |
| `onlyRole` / `onlyOwner` | `_msgSender()` | operators |

In the three deployables without a forwarder, `_msgSender()` is OpenZeppelin `Context`, i.e. `msg.sender`; in the
three `*2771` contracts it unwraps the forwarder's suffix. `NoForwarderTestBase` checks, for the three
contracts without a forwarder, that a sender appended to the calldata is ignored and that `isTrustedForwarder` /
`trustedForwarder` do not exist. `ERC2771TokenGateTestBase` still runs on all three `*2771` contracts.

### H-3. A `*2771` deployable accepts `address(0)` as its forwarder — decide

`RuleEngine2771`, `RuleEngineOwnable2771` and `RuleEngineOwnable2Step2771` pass the forwarder straight to
`ERC2771ModuleStandalone` with no check. Before the split, a zero forwarder was the documented way to disable
ERC-2771. Now each access-control model has a dedicated contract without a forwarder, so a `*2771` deployed with
`address(0)` is always a misconfiguration: it carries the ERC-2771 surface and bytecode and relays nothing. Not
harmful (`isTrustedForwarder(address(0))` can never match a real caller).

If adopted, the check belongs in the three `*2771` constructors, **not** in `ERC2771ModuleStandalone`: the mock
rules (`RuleAddressList`) use the module with a zero forwarder. The suites deploy `*2771` contracts with
`address(0)` in the aggregation and max-rules tests, which would move to a dummy forwarder. **Verdict: decide.**

## I. Interface granularity

`I-1`, `I-2` and `I-3` are carried from the rc6 report. rc7 changed none of the interfaces, so the conclusions
stand; `I-1` and `I-2` are restated below in full and re-verified against the final rc7 code (after `A-3`, `B-1`,
`B-2` and `D-2`), so this report can be read without the rc6 one. `I-3` (the engine should not call a rule's
`canTransfer` instead of `detectTransferRestriction`) is unchanged: the restriction code is the stronger primitive,
the engine owes the token a code, and calling both would let a rule contradict itself.

### I-1. `IRule` demands two functions the engine never calls — still open

**What the gate requires.** `RuleEngineBase._checkRule` accepts a rule only if
`ERC165Checker.supportsInterface(rule, IRULE_INTERFACE_ID)` is true. `IRule` declares a single function of its
own (`canReturnTransferRestrictionCode`) and inherits everything else from CMTAT's `IRuleEngineERC1404`, so
`IRULE_INTERFACE_ID` (`RuleInterfaceId.sol:37`) is the XOR of the whole tree: `IRule`, `IRuleEngine`,
`IERC7551Compliance`, `IERC3643ComplianceRead`, `IERC3643IComplianceContract`, `IERC1404`, `IERC1404Extend` and
`IERC165`. Its value is `0x2497d6cb`, pinned by `test/RuleEngine/IRuleInterfaceId.t.sol:80`.

**What the engine uses.** Of the eight functional selectors in that tree, the engine calls six:

| Selector | Called by the engine? | Call site (final rc7 code) |
|---|---|---|
| `transferred(address,address,uint256)` | yes | `RulesManagementModule.sol:211` |
| `transferred(address,address,address,uint256)` | yes | `RulesManagementModule.sol:230` |
| `detectTransferRestriction(address,address,uint256)` | yes | `RuleEngineBase.sol:172` |
| `detectTransferRestrictionFrom(address,address,address,uint256)` | yes | `RuleEngineBase.sol:196` |
| `canReturnTransferRestrictionCode(uint8)` | yes | `RuleEngineBase.sol:221` |
| `messageForTransferRestriction(uint8)` | yes | `RuleEngineBase.sol:222` |
| `canTransfer(address,address,uint256)` (`0xe46638e6`) | **no** | — |
| `canTransferFrom(address,address,address,uint256)` (`0x7157797f`) | **no** | — |

The two unused ones arrive through `IERC3643ComplianceRead` and `IERC7551Compliance` (the selector of
`canTransferFrom` is also the whole `IERC7551Compliance` id, `0x7157797f`, since that interface declares only this
function). The engine never asks a rule either question: its own `canTransfer` / `canTransferFrom` are computed
from its `detectTransferRestriction*` loops (`== TRANSFER_OK`).

**Why it matters, in the order it bites:**

- **Every rule author writes two views nothing in the engine path calls.** All four reference rules in
  `src/mocks/rules/` implement them, and so must every rule in [CMTA/Rules](https://github.com/CMTA/Rules).
- **Least privilege.** A rule that only answers "is this restricted, and why" must also expose the
  compliance-read surface of ERC-3643 and ERC-7551 to pass the gate.
- **It invites stubs, and stubs can disagree.** Nothing forces a rule's `canTransfer` to match its
  `detectTransferRestriction`. A rule that returns `true` from a stubbed `canTransfer` passes the engine and
  behaves correctly behind it, but advertises an answer that an integrator calling the rule directly would
  trust (see `I-2` for when that happens).

**The fix.** Declare in `IRule` the six selectors the engine consumes, and gate on that id:

| Interface | Selectors | ID |
|---|---|---|
| Current `IRULE_INTERFACE_ID` | 8 functional + ERC-165 | `0x2497d6cb` |
| Narrowed `IRule` | 6 functional + ERC-165 | **`0xb1a69752`** |

Recomputed in this pass: `0x2497d6cb ^ 0xe46638e6 ^ 0x7157797f = 0xb1a69752` (selectors from `cast sig`), the
same value the rc6 report obtained by computing the candidate interface directly.

**Migration, which is what makes it a coordinated release rather than a local edit:**

1. `IRule` stops inheriting `IRuleEngineERC1404` and declares the six functions itself (`transferred` x2,
   `detectTransferRestriction`, `detectTransferRestrictionFrom`, `canReturnTransferRestrictionCode`,
   `messageForTransferRestriction`), plus `IERC165`. This is this project's interface, not a published standard,
   so narrowing it is legitimate; ERC-3643 and ERC-7551 themselves are untouched.
2. `IRULE_INTERFACE_ID` becomes `type(IRule).interfaceId ^ type(IERC165).interfaceId`, and
   `IRuleInterfaceId.t.sol` pins `0xb1a69752`.
3. **Every rule in CMTA/Rules must advertise the new id before an engine running the new code accepts it.**
   An engine on the new id rejects a rule that advertises only `0x2497d6cb` with `RuleEngine_RuleInvalidInterface`,
   which would block `addRule` / `setRules` for every existing rule. A transition is possible: rules advertise
   both ids for one release, so they work with old and new engines.
4. Rules that also want the standalone role (`I-2`) keep implementing `canTransfer` / `canTransferFrom` and keep
   advertising `RULE_ENGINE_INTERFACE_ID`. Narrowing the engine's gate takes nothing away from them.

**Limit.** ERC-165 expresses shape, never semantics: the narrowed id still cannot tell an allow-list from a
deny-list. That stays configuration discipline, and the change must not be presented as closing it.

**Verdict: decide**, at a release where CMTA/Rules moves in step. Not a defect: the current gate is sound,
only broader than the engine needs. Not worth doing alone if the answer to `I-2` is "rules are meant to be
usable standalone", since every rule would then implement the two functions anyway; it is then documentation
value only.

### I-2. Rules advertise the standalone engine role, but nothing tests or documents it — still open

**What is advertised.** All four reference rules answer `true` to `supportsInterface(RULE_ENGINE_INTERFACE_ID)`
(`RuleWhitelistMock.sol:62`, `RuleConditionalTransferLightMock.sol:130`, `RuleMintAllowanceMock.sol:125`,
`RuleOperationRevertMock.sol:64`). Because `IRule is IRuleEngineERC1404`, a rule also has the whole engine-facing
surface. So a single rule can be given to a CMTAT token **as its rule engine**, with no RuleEngine in between.

**Why nothing stops it.** CMTAT's `setRuleEngine(IRuleEngine)` (`ValidationModuleRuleEngine.sol:48`) checks only
that the value changes, then stores it (`ValidationModuleRuleEngineInternal._setRuleEngine`); it performs **no
ERC-165 check**. The token then calls the rule directly: `canTransfer` / `canTransferFrom` from
`_canTransferWithRuleEngine` / `_canTransferFrom` (`:129`, `:117`) and `transferred` from
`_callRuleEngineTransferred` (`:182`). This is the one configuration in which `canTransfer` and
`canTransferFrom` (`I-1`) are actually called on a rule.

**What is missing, checked in this pass:**

- **No test.** The three `setRuleEngine` calls in the suite (`test/RuleWhitelist/CMTATIntegrationBase.sol:47`,
  `test/RuleEngine/RulesManagementModuleTest/CMTATIntegrationBase.sol:41`,
  `RuleEngineOperationRevertBase.sol:32`) all pass a `RuleEngine`, never a rule.
- **No documentation.** Neither `README.md`, `doc/README.md`, `RuleEngine-with-CMTAT.md` nor
  `RuleEngine-with-ERC3643.md` describes a rule used without an engine.
- **The id is hardcoded.** Each mock declares its own `RULE_ENGINE_INTERFACE_ID = 0x20c49ce7` literal instead
  of importing `CMTAT/library/RuleEngineInterfaceId.sol`. The value matches CMTAT today, but it is the hardcoded
  pattern `F-2` removed elsewhere in rc6: a CMTAT interface change would leave the mocks advertising a stale id
  with no test failing.
- **Not checked:** whether the production rules in CMTA/Rules advertise `RULE_ENGINE_INTERFACE_ID`.

**What the missing test would have to establish**, because the standalone role differs from the engine role:

- **Who calls `transferred`.** Behind an engine, only a bound token reaches the engine, and the engine calls
  the rule. Standalone, the token calls the rule directly. The rule must accept that caller.
- **There is no `onlyBoundToken` in front of the rule.** The engine's bound-token gate does not exist
  standalone, and the stateful reference rules have no caller check of their own:
  `RuleConditionalTransferLightMock.transferred` (`:94`) and `RuleMintAllowanceMock.transferred` (`:98`) are
  `public` with no restriction. **Any account can call them directly** and consume a transfer approval or a
  minter's allowance, blocking the real operation. This is true **with or without an engine**, because a direct
  call to the rule never goes through the engine at all. These are reference mocks, not production rules
  (`CLAUDE.md`, invariant 8), so it is recorded here rather than as a security finding; the obligation for a
  production stateful rule is to restrict `transferred` to its engine (or, standalone, its token). Whether the
  CMTA/Rules rules do so was not checked.
- **Codes and messages reach the token.** The token's `detectTransferRestriction` /
  `messageForTransferRestriction` must return the rule's own code and message.
- **ERC-3643 is a different case.** An ERC-3643 token calls `created` / `destroyed` and binding functions that a
  rule does not implement, so a rule cannot stand in for the engine there. The standalone role is CMTAT-only.

**Options:**

1. **Support it deliberately:** one CMTAT integration test per reference rule (`setRuleEngine(rule)`, then a
   transfer, a refused transfer with its code and message, and for the stateful rules a mint or approved
   transfer), a paragraph in `RuleEngine-with-CMTAT.md` stating what a rule must do to be used standalone
   (caller restriction on `transferred`, `canTransfer` consistent with `detectTransferRestriction`), and the
   mocks importing `RuleEngineInterfaceId`.
2. **Withdraw it:** rules stop advertising `RULE_ENGINE_INTERFACE_ID`, and the docs state that a rule is used
   only behind a RuleEngine. This does not stop a determined integrator (`setRuleEngine` checks nothing), but
   the rule no longer claims the role. Combined with `I-1`, rules then also drop `canTransfer` /
   `canTransferFrom`.

**Verdict: decide**, together with `I-1`, since they are the same question seen from two sides: is a rule
only an engine plug-in, or also a minimal engine? Option 1 matches what the code advertises today and is the
smaller change in this repository; option 2 is the cleaner interface, and needs CMTA/Rules to move in step.

## J. Modularity

### J-1. Binding registry — carried

The registry's inheritance is unchanged, so the rc6 compile probes remain valid. With `F-1`, a host embedding it
needs solc 0.8.27 or later, which the pragma now says.

### J-2. ERC-2771 in the shared layer blocked a host with its own forwarder — fixed by the split

The skill this review follows lists "meta-transaction bases in the shared layer" as a reuse hazard: ERC-2771 is a
deployment decision, and a host usually has its own. Up to the split, `RuleEngineOwnableShared` inherited
`ERC2771ModuleStandalone`, so every ownable engine carried an `ERC2771Context` with its own constructor argument.

**Probe** (written in `src/`, built with only its imports, deleted afterwards): a host that brings OpenZeppelin's
`ERC2771Context` and embeds the ownable engine.

```solidity
contract ProbeHost is ERC2771Context, RuleEngineOwnable {
    constructor(address owner_, address fwd) ERC2771Context(fwd) RuleEngineOwnable(owner_, address(0)) {}
    // + the three Context overrides any ERC-2771 host writes
}
```

| Code | Result |
|---|---|
| Pre-split (`4946c87`, engine constructor `(owner, forwarder, token)`) | **`Error (3364)`: "Base constructor arguments given twice"**, plus override errors (`2353`, `4327`) |
| Final rc7 (`3b94564`) | **compiles** |

`Error (3364)` is the blocking class: no override or ordering fixes it, because `ERC2771Context` is constructed
by both the host and the engine. Before the split the host could only drop its own forwarder and accept the
engine's immutable one. Now it embeds `RuleEngineOwnable` (or `RuleEngine`) and supplies its own. **Fixed by the
split**, and kept as a regression guard in spirit by `NoForwarderTestBase`, which pins that the plain deployables
carry no ERC-2771 surface.

## K. Tests

### K-1. Correctness of the existing tests

- **Tautologies:** none. **Bare `vm.expectRevert()`:** 0 (2 fixed at the first pass).
- **A negative test for every guard.** Every custom error in `src/` is reached by an `expectRevert`, except
  `RuleEngine_RulesManagementModule_OperationNotSuccessful`, which was unreachable (`B-2`; removed since). The constructor guards
  of the new contracts are covered: zero admin (`RuleEngine_AdminWithAddressZeroNotAllowed`) and zero owner
  (`OwnableInvalidOwner`) for all six deployables, through the deployment suites and `ERC2771VariantTestBase`.
- **Through the public surface.** The shared suites assert observable behaviour (revert data, `isTokenBound`,
  `supportsInterface` compared between the two contracts of a pair) rather than recomputing internals.

### K-2. Coverage, measured

`forge coverage --no-match-coverage "(mocks|test|script)" --report summary`, second pass:

| Contract | Lines | Statements | Branches | Funcs |
|---|---|---|---|---|
| `RuleEngineBase.sol` | 100% (51/51) | 100% (62/62) | 100% (5/5) | 100% (14/14) |
| `RuleEngineAccessControlShared.sol` | 100% (18/18) | 100% (15/15) | 100% (7/7) | 100% (7/7) |
| `RuleEngineOwnableShared.sol` | 100% (10/10) | 100% (11/11) | 100% (2/2) | 100% (3/3) |
| `RuleEngine2771.sol` | 100% (6/6) | 100% (6/6) | — | 100% (3/3) |
| `RuleEngineOwnable.sol` | 100% (6/6) | 100% (2/2) | — | 100% (4/4) |
| `RuleEngineOwnable2771.sol` | 100% (6/6) | 100% (6/6) | — | 100% (3/3) |
| `RuleEngineOwnable2Step.sol` | 100% (9/9) | 100% (6/6) | — | 100% (5/5) |
| `RuleEngineOwnable2Step2771.sol` | 100% (6/6) | 100% (6/6) | — | 100% (3/3) |
| `ERC3643ComplianceModule.sol` | 100% (6/6) | 100% (6/6) | 100% (2/2) | 100% (2/2) |
| `ERC3643ComplianceExtendedModule.sol` | 100% (2/2) | 100% (1/1) | — | 100% (1/1) |
| `RulesManagementModule.sol` | 100% (64/64) | 100% (60/60) | **86.67% (13/15)** | 100% (19/19) |
| `TokenBindingModule.sol` | 100% (24/24) | 100% (16/16) | 100% (7/7) | 100% (9/9) |
| `TokenBindingExtendedModule.sol` | 100% (24/24) | 100% (25/25) | 100% (5/5) | 100% (7/7) |
| `VersionModule.sol` | 100% (2/2) | 100% (1/1) | — | 100% (1/1) |
| **Total** | **100% (234/234)** | **100% (223/223)** | **95.35% (41/43)** | **100% (81/81)** |

`RuleEngine.sol` has no row: its constructor only forwards to `RuleEngineAccessControlShared`, so it holds no
statement of its own. The two uncovered branches are the same as at the first pass, both **dead code** (`B-2`):
the false sides of `require(_rules.add(...), OperationNotSuccessful())` (`RulesManagementModule.sol:181`) and
`require(_rules.remove(...), OperationNotSuccessful())` (`:194`).

**After `B-2`:** both `require`s now carry the reachable error (`RuleAlreadyExists`, `RuleDoNotMatch`) and the
dead `contains()` checks are gone. Re-run: lines 232/232, statements 222/222, **branches 40/40**, functions 81/81.

### K-3. Mutation testing

**First pass (`4946c87`, 33 mutants).** 4 of 32 survived the suite as it stood: a rule returning code 1 ignored
(M01), the message taken from `rule(0)` (M03), `from` / `to` swapped in `created` (M05) and `destroyed` (M06). An
added mutant (M33, no `TokenSelfBindingApprovalSet`) also survived. The tests written for `K-6` killed all five.
M05 / M06 were also killed by the real T-REX suite, which CI does not run (`K-4`). Those 33 mutants target files
the split did not change, apart from code that moved, which the second pass re-targets.

**Second pass (`3b94564`, 17 mutants on the moved and new code).**

**All 17 killed.** Failing tests per mutant are counted once each:

| Mutant | Change | Failing tests |
|---|---|---|
| N01 | `RuleEngineAccessControlShared` constructor accepts a zero admin | 2 |
| N02 | RBAC constructor ignores `tokenContract` | 23 |
| N03 | RBAC `grantRole`: a rule may receive a role | 3 |
| N04 | RBAC `hasRole`: the admin loses its implicit roles | 18 |
| N05 | RBAC constructor emits no initial `SetMaxRules` | 2 |
| N06 | RBAC `_onlyRulesLimitManager` accepts `RULES_MANAGEMENT_ROLE` | 2 |
| N07 | `RuleEngine2771._msgSender` ignores the forwarder | 3 |
| N08 | `RuleEngineOwnable2771._msgSender` ignores the forwarder | 3 |
| N09 | `RuleEngineOwnable2Step2771._msgSender` ignores the forwarder | 3 |
| N10 | `RuleEngine2771._msgData` keeps the suffix | 1 |
| N11 | `RuleEngineOwnable2771._msgData` keeps the suffix | 1 |
| N12 | `RuleEngineOwnable2Step2771._contextSuffixLength` returns 0 | 4 |
| N13 | `RuleEngineOwnableShared` constructor ignores `tokenContract` | 7 |
| N14 | `RuleEngineOwnableShared` constructor emits no initial `SetMaxRules` | 4 |
| N15 | Ownable: a rule may become owner | 2 |
| N16 | Ownable ERC-165: drops ERC-173 | 3 |
| N17 | `RuleEngineOwnable2Step` ERC-165: drops the two-step id | 1 |

The thinnest margins are N10, N11 and N17, each caught by a single test (`testMsgDataStripsTheRelayedSender` per
`*2771` pair, and the `Ownable2Step` interface test). They are still real assertions on the exact property, so no
test was added. Across both passes, **50 mutants, 0 surviving** against the current suite.

### K-4. CI never runs the real ERC-3643 suite — fixed

`.github/workflows/ci.yml` runs `forge test -vvv` and `npx hardhat test`. `test/ERC3643Real/` is in the default
profile's `skip` list, so its 13 tests are never run by CI, although they caught M05 / M06 at the first pass.
**Fix:** a step running `FOUNDRY_PROFILE=erc3643 forge test`. **Verdict: implement.**

**Implemented after the second pass.** `.github/workflows/ci.yml` has a step "Run Forge tests against the real
ERC-3643 token" (`FOUNDRY_PROFILE=erc3643 forge test -vvv`) right after the default `forge test`. The vendored
token comes from the `lib/ERC-3643` submodule, which the existing `forge install` step initialises, and its
`@onchain-id` imports resolve to the stubs in `test/utils/onchainid/`, so no extra install is needed. Checked
locally: the workflow parses, and the command passes 13/13. **Not checked:** a run on GitHub Actions itself.

### K-5. Fuzz and invariant tests — fuzz written, invariant proposed

| Property | Kind | Where |
|---|---|---|
| `detectTransferRestriction` returns the first non-zero code in rule order, and `canTransfer == (code == 0)` | **fuzz** (`uint8 × uint8`, 256 runs) × 6 deployables | `RuleAggregationTestBase.testFuzz_DetectReturnsFirstNonZeroCode` |
| The 4-argument view uses the rules' 4-argument answers | **fuzz** × 6 | `testFuzz_DetectFromReturnsFirstNonZeroCode` |
| Codes 1 and 255 are reported | spot-checked | `testBoundaryCodesAreReported` |
| Each `*2771` contract advertises the same ERC-165 ids as its counterpart | spot-checked over 13 ids × 3 pairs | `ERC2771VariantTestBase` |
| The rule set never holds a duplicate or `address(0)`, and every member advertises `IRULE_INTERFACE_ID` | **proposed invariant** | not written |
| A token is bound iff `isTokenBound`, and `getTokenBounds()` has no duplicate | **proposed invariant** | not written |

`rulesCount() <= maxRules()` is deliberately **not** an invariant: lowering the cap below the current count is
allowed and tested.

### K-6. Tests written

| Pass | Test | Deployables | Covers |
|---|---|---|---|
| 1 | `RuleCodeProbe` + `RuleAggregationTestBase` (7 tests) | 6 (3 at the first pass) | M01, M03, M05, M06 |
| 1 | `testSetTokenSelfBindingApprovalEmitsEvent` | 3 access-control models | M33 |
| 1 | `testCannotBindTokensBatchWithDuplicateToken` | RBAC | duplicate-in-batch edge case |
| 1 | Bare `expectRevert()` made specific | — | `K-1` |
| split | `ERC2771VariantTestBase` (5 tests), `NoForwarderTestBase` (2 tests) | 3 + 3 | `H-2`, `F-2`, `J-2` |

### K.3 edge cases, by family

| Family | Status | Missing / written |
|---|---|---|
| Zero and identity | `address(0)` rule, token, admin/owner for all six deployables: tested. `created` / `destroyed` zero-address side: written | Zero **forwarder** on a `*2771`: accepted, see `H-3` |
| Boundaries | cap exact, cap + 1, lowered cap, `rule(i)` out of range, empty `setRules`, codes 1 and 255: tested | Empty `bindTokens` / `unbindTokens` / approval batch: no test; the expected value is now a no-op (`C-3`, revised) |
| Duplicates and order | duplicate in `setRules` and inside one bind batch, rule order for detect / message / enforcement: tested | — |
| State transitions | unbind then callback, re-bind, clear then add, ownership hand-over, approval revoked: tested | — |
| Authorization | unauthorized caller per protected function, rule as role holder or owner, relayed forwarder (`*2771`), appended sender ignored (no forwarder): tested | — |
| Reentrancy | the obligation is on the rule (`RuleEngine-with-CMTAT.md` §4.6); not tested at engine level | — |
| Events | all 8 asserted; initial `SetMaxRules` for all six deployables | — |
