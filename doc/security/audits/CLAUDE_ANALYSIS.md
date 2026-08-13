# RuleEngine — Code Quality Review

| | |
|---|---|
| **Scope** | `src/` (46 Solidity files) and `script/` (2 files) |
| **Base commit** | `50165c7` |
| **Compiler** | solc 0.8.36, `evm_version = prague`, optimizer on, 200 runs |
| **Date** | 2026-08-13 |
| **Produced with** | Claude Code |

## This is not a security audit

Nothing in this report is a vulnerability. No finding below lets an unauthorized party move value, bypass a
transfer restriction, or brick a contract. The one finding with real integration consequence (**H-1**) is a
divergence between a *view* and the *enforcement* path: the view is more permissive than reality, so an
integrator can be told a mint is allowed when it will revert. The enforcement path itself is correct and
still rejects — no restriction is bypassed.

Every gas number below was measured with a benchmark harness, not derived from opcode costs. Each variant was
placed in its own contract with a single identically-named function so selector-dispatch depth could not skew
the comparison, and every measurement was taken after an identical warm-up. All benchmark files were deleted
after measurement; the test count reconciles exactly (322 before → 325 after, the three added being the C-1
regression tests).

## Disposition summary

| ID | Finding | Outcome |
|----|---------|---------|
| A-1 | `addressIsListedBatch` takes `memory`, never called internally | ✅ fixed — `calldata`, 587 gas @ 10 addrs |
| A-2 | Loop increment form / `unchecked` | ⬜ left as is — already correct, see below |
| A-3 | Unbounded iteration over caller-supplied arrays | ⬜ left as is — admin-gated |
| B-1 | `contains()` then `add()`/`remove()` double lookup | ✅ fixed — 269 gas measured |
| B-2 | `_checkRule()` then `_rules.add()` double lookup | ⬜ left as is — diagnostic structure |
| C-1 | Initial `maxRules` never emitted | ✅ fixed — emitted at construction, 3 regression tests |
| C-2 | Batch self-binding approval emits input, not per-token effect | ⚠️ decide — API-visible, see below |
| D-1 | Ownable variants duplicate the ERC-2771 context trio | ⬜ left as is — compiler-mandated, proven |
| E-1 | `_bindToken` / `_unbindToken` not `virtual` | ✅ fixed |
| E-2 | `_supportsRuleEngineBaseInterface` not `virtual` | ✅ fixed |
| E-3 | 10 mock internals not `virtual` | ✅ fixed |
| F-1 | ERC-165 flattened interface-ID computation | ⬜ no finding — verified correct |
| G-1 | `canTransfer` docs omit the fail-open case | ✅ fixed — warning added |
| H-1 | View approves a mint that enforcement rejects | ✅ documented — behaviour left, see below |

**Counted: 14 rows — 7 fixed, 5 left as is, 1 no-finding, 1 open decision.**

## Outstanding

| ID | Item | Why it is still open |
|----|------|----------------------|
| C-2 | `setTokenSelfBindingApprovalBatch` emits only a batch event | Fixing it changes the emitted event stream, which is API-visible to indexers. Needs a product call, not a code call. |
| H-1 | The view/enforcement divergence itself | Inherent to the ERC-1404 3-argument signature, which carries no `spender`. Documented rather than "fixed" — see the finding for why a code fix would be worse. |

---

## A. Loops and iteration

### A-1. `addressIsListedBatch` takes `memory` but is never called internally — fixed

`RuleAddressList.sol`, `addressIsListedBatch`:

```solidity
function addressIsListedBatch(address[] memory _targetAddresses) public view returns (bool[] memory)
```

A repo-wide grep found no internal caller — the only callers are external (tests). `memory` therefore forces
a needless calldata→memory copy on every call.

**Measured**, two contracts each exposing a single `probe` function, 10 addresses, identical warm-up:

| Variant | Gas |
|---|---|
| `memory` | 35,421 |
| `calldata` | 34,834 |
| **Delta** | **587** (~59/address) |

**Verdict: implement.** Changed to `calldata` (and `virtual`, per E-3). Scales with array length, so the
saving grows for the batch sizes this function exists to serve.

### A-2. Increment form and `unchecked` — no change, and deliberately so

All 12 loops in `src/` already use `++i`, and there is **no `unchecked` block anywhere in the codebase**.

On solc 0.8.36 this is correct and should stay. Since **0.8.22** the compiler elides the overflow check on a
bounded loop counter automatically, so wrapping `++i` in `unchecked` buys nothing on this pragma. A review
that recommended `unchecked { ++i }` here would be recommending noise.

**Verdict: leave.** Recorded explicitly so a future reviewer does not "fix" it.

### A-3. Unbounded iteration over caller-supplied arrays

`bindTokens`, `unbindTokens`, `setTokenSelfBindingApprovalBatch` (`ERC3643ComplianceExtendedModule.sol`),
`addAddressesToTheList` / `removeAddressesFromTheList` (`RuleAddressListInternal.sol`) all iterate a
caller-supplied array with no length cap.

All are gated on a privileged role (`onlyComplianceManager`, `ADDRESS_LIST_ADD_ROLE`,
`ADDRESS_LIST_REMOVE_ROLE`). The only party who can pass an oversized array is the operator, and the only
consequence is their own transaction running out of gas — no griefing surface, no state corruption.

**Verdict: leave.** The rule set itself *is* capped (`maxRules`, default 10), which is where the bound
matters, because that loop runs on every transfer.

---

## B. Storage reads

### B-1. `contains()` immediately followed by `add()` / `remove()` — fixed

`ERC3643ComplianceModule.sol`, before:

```solidity
function _bindToken(address token) internal {
    require(token != address(0), RuleEngine_ERC3643Compliance_InvalidTokenAddress());
    require(!_boundTokens.contains(token), RuleEngine_ERC3643Compliance_TokenAlreadyBound());
    // Should never revert because we check if the token address is already set before
    require(_boundTokens.add(token), RuleEngine_ERC3643Compliance_OperationNotSuccessful());
    emit TokenBound(token);
}
```

`EnumerableSet.add` already performs the membership test internally and returns `false` when the value is
present, so `contains()` reads the same `_positions` slot twice. The source comment
("Should never revert because we check ... before") documents that the second `require` is unreachable.

Rewritten to use the mutation's return value **while keeping the meaningful diagnostic**:

```solidity
function _bindToken(address token) internal virtual {
    require(token != address(0), RuleEngine_ERC3643Compliance_InvalidTokenAddress());
    // add() returns false when the token is already bound, so a separate
    // contains() lookup is unnecessary.
    require(_boundTokens.add(token), RuleEngine_ERC3643Compliance_TokenAlreadyBound());
    emit TokenBound(token);
}
```

`_unbindToken` received the same treatment with `RuleEngine_ERC3643Compliance_TokenNotBound`.

**Measured**, two contracts each exposing a single `bind` function, identical warm-up:

| Variant | Gas |
|---|---|
| `contains()` + `add()` | 55,198 |
| `add()` only | 54,929 |
| **Delta** | **269** |

Note the size of that number. The `contains()` call was the **first** touch of the slot and therefore paid
the *cold* price; removing it makes `add()` the cold access. What is actually saved is the **warm** SLOAD
plus call overhead — ~269 gas, not the ~2,100 a naive cold-access assumption would predict.

`RuleEngine_ERC3643Compliance_OperationNotSuccessful` became unreachable and was removed. It was referenced
nowhere else in `src/` or `test/`; an error that can never be raised is worse than no error, though note this
is an ABI change for anyone decoding it.

**Verdict: implement.** Behaviour-preserving — the same two errors are raised in the same conditions.
Existing tests guard both paths (`TokenAlreadyBound` and `TokenNotBound` are asserted across all three
deployable variants in `ERC3643Compliance.t.sol`), and all 322 pre-existing tests still pass.

### B-2. `_checkRule()` then `_rules.add()` — left as is

`RulesManagementModule.sol` has the same shape in `addRule` / `setRules`: `_checkRule` performs a
`contains()`, then `add()` repeats it, guarded by a `require` documented as unreachable.

This is **not** the same case. `_checkRule` is `virtual` and `RuleEngineBase` overrides it to add the ERC-165
interface validation, so the check is an extension point, not just a lookup. Collapsing it into `add()`'s
return value would either lose the ERC-165 validation or force it to run after insertion.

**Verdict: leave.** The upper bound on the saving is the same ~269 gas measured in B-1, per rule added — paid
only on administrative calls, never on the transfer path. Not worth dismantling an override point for.

---

## C. Events

### C-1. The initial `maxRules` is never emitted — fixed

`RulesManagementModule.sol` initialises the cap inline:

```solidity
uint256 internal _maxRules = DEFAULT_MAX_RULES;   // 10
```

`SetMaxRules` is emitted **only** by `setMaxRules`. An indexer reconstructing engine configuration purely
from events therefore sees no value at all until an admin first changes the cap — it cannot distinguish
"cap is 10" from "cap unknown", and a freshly deployed engine emits nothing.

Fixed by emitting the initial value in both constructors (`RuleEngine`, and `RuleEngineOwnableShared` which
serves both ownable variants):

```solidity
// Emit the initial cap so the event log alone is enough to reconstruct maxRules.
emit SetMaxRules(_maxRules);
```

**Verdict: implement.** Three regression tests added in `RuleEngineMaxRulesEvent.t.sol`, one per deployable
variant. Per the method: the fix was reverted and all three tests were confirmed to **fail**
(`expected an emit, but no logs were emitted afterwards`) before being restored — they are guards, not
guesses.

### C-2. Batch self-binding approval reports its input, not its effect — open decision

`ERC3643ComplianceExtendedModule.sol`:

```solidity
function setTokenSelfBindingApproval(address token, bool approved) ... {
    ...
    emit TokenSelfBindingApprovalSet(token, approved);      // per token
}

function setTokenSelfBindingApprovalBatch(address[] calldata tokens, bool approved) ... {
    for (...) { _tokenSelfBindingApproval[token] = approved; }
    emit TokenSelfBindingApprovalBatchSet(tokens, approved); // echoes the input array
}
```

The same state change produces different events depending on which entrypoint the operator used. A consumer
subscribed to `TokenSelfBindingApprovalSet` — the obvious choice, since it is the per-token event — silently
misses every batch update.

The inconsistency is sharpest **inside this same contract**: `bindTokens` and `unbindTokens` *do* emit a
per-token event for each element (via `_bindToken` / `_unbindToken`). Batch binding is consistent; batch
approval is not.

The batch event also reports the input array rather than the effect: it does not distinguish tokens whose
approval actually changed from those already at the requested value.

**Verdict: decide.** Emitting `TokenSelfBindingApprovalSet` per token would make the event stream uniform and
match the sibling batch functions, at the cost of N events' gas. That is an API-visible change to the emitted
stream, so it is a product decision rather than a mechanical fix. Left unchanged pending that call.

---

## D. Duplication

### D-1. The ownable variants duplicate the ERC-2771 context trio — left as is, and here is the proof

`RuleEngineOwnable.sol` and `RuleEngineOwnable2Step.sol` contain byte-identical bodies for `_msgSender`,
`_msgData` and `_contextSuffixLength`, each a one-line delegation to `RuleEngineOwnableShared`. The three
access-control hooks (`_onlyRulesManager`, `_onlyRulesLimitManager`, `_onlyComplianceManager`) are likewise
identical (`onlyOwner {}`). That is 6 duplicated **code** lines per contract, excluding NatSpec.

The obvious proposal is to hoist the trio into `RuleEngineOwnableShared`, which already defines all three.
**Before proposing that, I tested whether the duplication was avoidable** by deleting the three overrides from
`RuleEngineOwnable` and compiling:

```
Error (6480): Derived contract must override function "_msgSender".
Two or more base classes define function with same name and parameter types.
  --> src/deployment/RuleEngineOwnable.sol:12:1
Note: Definition in "Context": lib/openzeppelin-contracts/contracts/utils/Context.sol:21:5
```

Identical errors for `_msgData` and `_contextSuffixLength`. Because `RuleEngineOwnable` inherits both
`RuleEngineOwnableShared` and `Ownable` (→ `Context`), and both branches supply these functions, C3
linearization requires the most-derived contract to disambiguate **explicitly**. The duplication is mandated
by the compiler, not an oversight.

The access-control hooks cannot be hoisted either: `RuleEngineOwnableShared` does not inherit `Ownable`
(that is precisely the choice it defers to its children), so it cannot apply the `onlyOwner` modifier.

**Verdict: leave.** File restored to its original state; recorded here with the exact compiler error so this
is not re-opened.

---

## E. `virtual` / override convention

The project's own guide (`CLAUDE.md` / `AGENTS.md`, "Solidity Style") states: *"All `internal` functions must
be marked `virtual`, so inheriting contracts can override them."* This section is measured against that rule,
not an external preference.

**Cost check, measured rather than asserted:** a plain `internal` call and a `virtual internal` call were
benchmarked in separate contracts — 10,374 vs 10,363 gas. The 11-gas delta *favours* `virtual` and is within
noise, confirming that `virtual` on an internal function is resolved statically and is free.

### E-1. `_bindToken` / `_unbindToken` were not `virtual` — fixed

`ERC3643ComplianceModule.sol`. These are the core compliance state mutators — every bind and unbind, batch or
single, self-binding or manager-driven, funnels through them.

The evidence is the **inconsistency inside the same file**: every other internal there
(`_checkBoundToken`, `_authorizeComplianceBindingChange`, `_onlyComplianceManager`) is `virtual`. These two
were the outliers, so a deployment variant could override *authorization* for binding but not the binding
itself.

**Verdict: implement.** Highest-consequence item in this section.

### E-2. `_supportsRuleEngineBaseInterface` was not `virtual` — fixed

`RuleEngineBase.sol`. Same inconsistency argument: `_detectTransferRestriction`,
`_detectTransferRestrictionFrom`, `_messageForTransferRestriction` and `_checkRule` in that file are all
`virtual`; this shared ERC-165 helper was not. A variant wanting to extend the base interface set had to
override the public `supportsInterface` instead of the helper built for it.

**Verdict: implement.**

### E-3. Ten mock internals were not `virtual` — fixed

`RuleAddressListInternal.sol` (6: `_addAddressesToThelist`, `_removeAddressesFromThelist`,
`_addAddressToThelist`, `_removeAddressFromThelist`, `_numberListedAddress`, `_addressIsListed`) and
`RuleAddressList.sol` (the ERC-2771 context trio, which *is* `virtual` in the production engines — another
sibling inconsistency).

These are reference implementations that integrators copy, so the convention matters more here than the
consequence does.

**Verdict: implement.** After this pass, `grep` for `internal` functions lacking `virtual` across `src/`
returns nothing.

---

## F. ERC / specification conformance

### F-1. The flattened ERC-165 interface ID is computed correctly — no finding

The classic ERC-165 bug is assuming `type(IFoo).interfaceId` covers inherited selectors; it covers only those
declared directly on `IFoo`. `IRule` extends `IRuleEngineERC1404`, so the naive computation would be wrong.

The project already handles this correctly and deliberately: `IRuleInterfaceIdHelper.sol` defines a flattened
`IRuleAllFunctions` interface enumerating the whole hierarchy, `RuleInterfaceId.IRULE_INTERFACE_ID` is the
XOR over that flattened set, and `IRuleInterfaceId.t.sol` asserts the constant matches
(`testConstantMatchesAllFunctionsXOR`, plus a manual hand-XOR cross-check in `computeManualXOR`). All pass.

**Verdict: no change.** Recorded as verified rather than omitted, so the next reviewer does not re-derive it.

---

## G. Code / documentation mismatch

### G-1. `canTransfer` documentation omitted the fail-open case — fixed

`doc/README.md` documented `canTransfer` as:

> Returns true if the transfer is valid, and false otherwise.
> Does not check balances or access rights (Access Control).

The stated carve-outs are balances and access control. Nothing warned that a **spender-dependent rule cannot
be evaluated at all** on this signature — which is the case demonstrated in H-1, where `canTransfer` returns
`true` for a mint that reverts.

**Verdict: implement.** A warning block was added to that section, and the same caveat was added to
`RuleMintAllowance.detectTransferRestriction`'s NatSpec using the project's plain-word `WARNING:` marker
(no emoji, per the project's Solidity comment convention).

---

## H. Weird behaviour — correct, but at odds with the purpose

### H-1. A view approves a mint the enforcement path rejects

This is the highest-value finding and the reason to read this report.

`RuleMintAllowance` keys its allowance by **spender** (the minter). The ERC-1404 3-argument
`detectTransferRestriction(from, to, value)` carries no spender, so the rule cannot evaluate a mint on that
path and answers "no restriction":

```solidity
function detectTransferRestriction(address, address, uint256) public pure override returns (uint8) {
    return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
}
```

**Traced, not assumed.** `RuleEngineBase._detectTransferRestriction` aggregates rule answers and returns the
first non-zero code; a rule answering `0` contributes nothing. `canTransfer` is built on the same aggregation.
So the hardcoded "everything is fine" propagates all the way to the two view functions an integrator actually
calls on the **engine**, not just on the rule.

Verified with a harness (since deleted), against a `RuleEngine` holding one `RuleMintAllowance` with a minter
allowance of 100, querying a mint of 500:

| Call | Result |
|---|---|
| `engine.detectTransferRestriction(address(0), to, 500)` | `0` — no restriction |
| `engine.canTransfer(address(0), to, 500)` | `true` — allowed |
| `engine.detectTransferRestrictionFrom(minter, address(0), to, 500)` | `81` — insufficient allowance |
| `engine.canTransferFrom(minter, address(0), to, 500)` | `false` — forbidden |
| `rule.transferred(minter, address(0), to, 500)` | **reverts** |

So the 3-argument view says yes, the 4-argument view says no, and reality says no. The system **fails open on
the view path while failing closed on the enforcement path** — the opposite of the direction a compliance
engine should lean.

**Why this is not a vulnerability:** enforcement is unaffected. The mint still reverts. The damage is to
integrators who pre-flight with `canTransfer` and get a wrong answer — a bad UX and a misleading API, not a
bypass.

**Why not "fix" it in code.** The rule cannot invent a spender it was not given. The alternatives are all
worse:

- Returning a restriction code unconditionally would break every legitimate non-mint transfer through this rule.
- Guessing `msg.sender` as the spender would be wrong in exactly the delegated case the field exists for.
- Removing the 3-argument implementation is not possible — `IRule` requires it.

The real constraint is the ERC-1404 signature, which predates the operator-aware model. The honest response is
to make the limitation loud.

**Verdict: document, keep the behaviour.** Warnings added at both levels — the rule's NatSpec (so anyone
copying this reference rule sees it) and `doc/README.md`'s `canTransfer` section (so integrators see it). The
guidance is explicit: to pre-check an operation that has an operator, use `canTransferFrom` /
`detectTransferRestrictionFrom`.

This finding applies to `src/mocks/`, which the project documents as reference implementations rather than
production rules. That limits the blast radius but arguably raises the documentation stakes: reference code is
what integrators copy.

---

## What was checked but not run

Stated explicitly, per the "distinguish checked from assumed" rule:

- **`script/`** was read and inventoried (2 files, both Foundry deployment scripts). It contains no loops, no
  storage patterns and no events of its own — the only `memory` usages are CMTAT constructor-attribute structs
  that must be `memory`. No findings, and nothing there needed benchmarking.
- **ERC-3643 / ERC-7551 semantic conformance beyond the interface-ID check (F-1)** was not exhaustively
  re-derived against the specification text. F-1 covers the interface-ID computation specifically. The
  project's own compatibility notes flag ERC-7551 as draft and deliberately implements a subset.
- **Storage-layout diffing** was not required: no finding in this pass moved or added a state variable. The
  `virtual` additions and the `require` collapse are code-only changes.

---

## Verification

- `forge build --force` — successful
- `forge test` — **325 passed, 0 failed** (322 pre-existing + 3 new C-1 regressions)
- `forge fmt` — applied
- Project style checker — 0 violations across all 46 files in `src/`
- All temporary benchmark files deleted; test count reconciles exactly
