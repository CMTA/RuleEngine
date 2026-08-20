# RuleEngine — Code Quality Review (v3.0.0-rc6)

| | |
|---|---|
| **Scope** | `src/` (52 Solidity files) and `script/` (2 files) |
| **Base commit** | `dc7a4d3` + the rc6 working tree |
| **Compiler** | solc 0.8.36, `evm_version = prague`, optimizer on, 200 runs |
| **Date** | 2026-08-20 |
| **Produced with** | Claude Code |

## This is not a security audit

Nothing in this report is a vulnerability. No finding below lets an unauthorized party move value, bypass a
transfer restriction, or brick a contract. This review targets the rc6 change — the separation of token
binding from the ERC-3643 compliance code — and re-checks the findings carried over from rc5.

Every gas number was measured with a benchmark harness, not derived from opcode costs. Each variant sat in its
own contract with an identically-named function so selector-dispatch depth could not skew the comparison, and
both were measured after an identical warm-up. The modularity verdict is a **compile result**, not an opinion:
two probe contracts were written and built. All probe and benchmark files were deleted afterwards; the test
count reconciles exactly (346 before, 346 after — no fixture left behind).

## Disposition summary

| ID | Finding | Outcome |
|----|---------|---------|
| A-1 | Loop increment form and `unchecked` | ⬜ no finding — `++i` on 0.8.36, `unchecked` would buy nothing |
| A-2 | Unbounded iteration over caller-supplied arrays | ⬜ left as is — admin-gated, carried from rc5 `A-3` |
| B-1 | Repeated storage reads in the new binding modules | ⬜ no finding — mutation return values already used |
| C-1 | Every event has exactly one emit site | ⬜ no finding — verified structurally, 8/8 events |
| C-2 | Batch self-binding approval emits input, not per-token effect | ⚠️ still open — carried from rc5, unchanged by the split |
| D-1 | Duplication across the three deployables | ⬜ no finding — reduced by the split, remainder is compiler-mandated |
| E-1 | `virtual` on every internal function | ⬜ no finding — 0 non-`virtual` internals in `src/` |
| F-1 | Advertised ERC-165 ids unchanged by the split | ⬜ verified — `0x3144991c` / `0x646ba2be` both hold |
| F-2 | `type(IERC3643ComplianceExtended).interfaceId` is `0x00000000`, and the extended id is now derivable | ⚠️ decide — see below |
| G-1 | NatSpec length and doc pointers in contract comments | ⬜ no finding — median 4 lines, max 19, zero `.md` pointers |
| H-1 | View approves a mint that enforcement rejects | ⬜ documented — carried from rc5, unchanged |
| I-1 | `IRule` demands two functions the engine never calls | ⚠️ decide — least-privilege, affects every rule author |
| J-1 | Binding registry embeddable in a foreign host | ⬜ verified by compile probe — inconvenience only, no blocker |
| J-2 | ERC-3643 adapter indirection costs 35 gas per bind | ⬜ left as is — measured, negligible |

**Counted: 14 rows — 0 fixed, 3 left as is, 8 no-finding/verified, 3 open decisions.**

## Outstanding

| ID | Item | Why it is still open |
|----|------|----------------------|
| C-2 | `setTokenSelfBindingApprovalBatch` emits only a batch event | Unchanged since rc5. Fixing it alters the emitted event stream, which is API-visible to indexers. Product call. |
| F-2 | The extended interface id is hand-maintained through a mock | The literal is correct today; changing how it is derived touches a constant that deployed contracts advertise. |
| I-1 | `IRule` requires `canTransfer` / `canTransferFrom` | Narrowing it is a breaking change for the separate [CMTA/Rules](https://github.com/CMTA/Rules) repository. |
| H-1 | The view/enforcement divergence | Inherent to the ERC-1404 3-argument signature. Documented rather than fixed — see the rc5 report. |

---

## A. Loops and iteration

### A-1. Increment form — no finding

Every loop in `src/` uses `++i` and none wraps the counter in `unchecked`. The project compiles with **0.8.36**,
where the overflow check on a bounded loop counter is elided by the compiler since 0.8.22. Recommending
`unchecked { ++i }` here would add noise for zero gas. Recorded so the next review does not re-raise it.

### A-2. Unbounded iteration over caller-supplied arrays — left as is

`bindTokens`, `unbindTokens`, `setTokenSelfBindingApprovalBatch` (now in `TokenBindingExtendedModule`) and
`setRules` iterate a caller-supplied array. All four are gated on the binding manager or rules manager, so the
only party who can pass an oversized array is the operator, and the only consequence is their own transaction
running out of gas. Same conclusion as rc5 `A-3`; the split moved three of the four loops without changing them.

## B. Storage reads

### B-1. The new binding modules — no finding

`_bindToken` and `_unbindToken` use the `EnumerableSet` mutation return value rather than a preceding
`contains()`, which is the rc5 `B-1` fix carried into the extracted module:

```solidity
require(_boundTokens.add(token), TokenBinding_TokenAlreadyBound());
```

`isTokenBound`, `getTokenBound` and `getTokenBounds` each touch the set once. No read is separated from another
by an external call, so there is nothing the optimizer is not already forwarding — hand-caching here would be a
pessimisation.

## C. Events

### C-1. One emit site per event — no finding, verified structurally

The rc5 `C-1` fix introduced `_setMaxRules` so that "every change to the cap emits `SetMaxRules`" holds
structurally rather than by convention. That property now holds for **every** event in `src/`:

```
TokenBound: 1   TokenUnbound: 1   TokenSelfBindingApprovalSet: 1   TokenSelfBindingApprovalBatchSet: 1
AddRule: 1      RemoveRule: 1     ClearRules: 1                    SetMaxRules: 1
```

Each event is emitted from exactly one place, and in each case that place is the internal writer the public
functions and the constructors both call. A new write path cannot silently skip the event, because there is no
second way to reach the storage. Worth stating as a positive result: this is the invariant the split had the
most opportunity to break, since it moved four of the eight events into a new file.

### C-2. Batch self-binding approval reports the input, not the effect — still open

`TokenBindingExtendedModule.setTokenSelfBindingApprovalBatch` writes each token then emits the whole input
array:

```solidity
for (uint256 i = 0; i < tokens.length; ++i) {
    address token = tokens[i];
    require(token != address(0), TokenBinding_InvalidTokenAddress());
    _tokenSelfBindingApproval[token] = approved;
}
emit TokenSelfBindingApprovalBatchSet(tokens, approved);
```

An indexer cannot tell which entries actually changed state, and the single-token setter emits a different event
(`TokenSelfBindingApprovalSet`, indexed) for the same state transition — so a consumer must handle two shapes.
This is rc5 `C-2` verbatim; the split relocated the function without altering it. Still a product call rather
than a code call: emitting per-token would change the event stream that indexers key on.

## D. Duplication

### D-1. Reduced by the split — no finding

The rc6 change removed the main duplication candidate rather than adding one: the binding registry existed once
before and exists once now, with the ERC-3643 layer holding only `getTokenBound()` and one hook. The remaining
duplication is the ERC-2771 context trio across the ownable variants (rc5 `D-1`), which is compiler-mandated:
each contract must name its own bases in the `override(...)` list.

## E. `virtual` convention

### E-1. Full coverage — no finding

`CLAUDE.md` requires every `internal` function to be `virtual` so inheriting contracts can override it. A scan
of `src/` (mocks excluded) returns **zero** internal functions missing the keyword, including the eleven added
by the new modules. The project's style checker reports `src/` and `script/` clean on all six of its checks.

## F. ERC / specification conformance

### F-1. The advertised interface ids survived the split — verified

The split moved `bindToken`, `unbindToken` and `isTokenBound` out of `IERC3643Compliance` into `ITokenBinding`,
which changes `type(IERC3643Compliance).interfaceId` (that expression never counted inherited selectors) while
leaving the union of selectors identical. The advertised constants are computed from flattened helper
interfaces, so they are unaffected — measured, not assumed:

| Expression | Value |
|---|---|
| `ComplianceInterfaceId.ERC3643_COMPLIANCE_INTERFACE_ID` | `0x3144991c` |
| `type(ICompliance).interfaceId` (flattened helper) | `0x3144991c` |
| `ComplianceInterfaceId.ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID` | `0x646ba2be` |
| `type(IERC3643ComplianceExtendedSubset).interfaceId` (flattened helper) | `0x646ba2be` |
| `type(IERC3643Compliance).interfaceId` (naive) | `0xb89d9289` — changed, and used by nothing |

An integrator's `supportsInterface` call therefore behaves exactly as in rc5. This is the check that would have
caught the split silently breaking ERC-165 detection, and it passes.

### F-2. The marker interface's naive id is zero, and the extended id is now derivable — decide

Two related observations from the same measurement:

**`type(IERC3643ComplianceExtended).interfaceId` is `0x00000000`.** The interface is a pure marker — it declares
no function of its own and only combines `IERC3643Compliance` and `ITokenBindingExtended` — so the XOR over its
*directly declared* selectors is over the empty set. Any integrator who reaches for that expression instead of
the advertised constant gets a meaningless id, and `supportsInterface(0x00000000)` returns false. It is a
footgun created by the split, not a defect in the engine, and it argues for a one-line NatSpec note on the
interface pointing at `ComplianceInterfaceId`.

**`type(ITokenBindingExtended).interfaceId` is `0x646ba2be` — exactly the advertised extended constant.** Because
`ITokenBindingExtended` declares precisely the six extended functions and inherits the rest, its naive id and the
flattened id coincide. The project can therefore replace the hand-maintained literal, and retire the
`IERC3643ComplianceExtendedSubset` mock that exists only to reproduce it:

```solidity
bytes4 public constant ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID = type(ITokenBindingExtended).interfaceId;
```

The value is identical, so no deployed behaviour changes, and the constant becomes derived from a real
`src/interfaces/` file rather than from a test double kept in sync by hand. **Verdict: decide.** It is a
maintainability improvement touching a constant that deployed contracts advertise, so it belongs to a release
where the interface ids are being reviewed anyway rather than to a patch.

## G. Code / documentation mismatch

### G-1. NatSpec proportion and doc pointers — no finding

Two mechanical checks, both clean:

- **Block length.** 153 NatSpec blocks in `src/` (mocks excluded): median **4** lines, 90th percentile **9**,
  maximum **19**. There is no block of 20 lines or more, so the long-tail pattern that makes contract headers
  unreadable is absent — including in the five files added this release.
- **Documentation pointers.** Zero occurrences of `.md`, `doc/technical` or `docs/` in `src/` comments. No
  NatSpec block delegates its substance to a file that a reader of the verified source on a block explorer
  cannot open, and no comment will be invalidated by a future docs reorganisation.

The rc6 documentation additions (`doc/technical/TokenBinding-module.md`, the reworked `doc/README.md` sections)
were checked against the code as they were written; the error rename is reflected everywhere, including
`script/RuleEngineScript.s.sol`, whose header cites `TokenBinding_UnauthorizedCaller`.

## H. Weird behaviour

### H-1. The view/enforcement divergence — carried forward, unchanged

`detectTransferRestriction` / `canTransfer` carry no `spender`, so a rule keyed by spender cannot evaluate the
operation and must answer "no restriction"; the engine aggregates that answer and can report a mint as allowed
that `transferred(spender, …)` reverts. Fully described in the rc5 report and pinned by a regression test. The
rc6 split touched neither path.

## I. Interface granularity

### I-1. `IRule` demands two functions the engine never calls — decide

`_checkRule` gates every rule on the flattened `IRULE_INTERFACE_ID` (`0x2497d6cb`). Flattened, `IRule` requires
eight functional selectors. The engine calls six of them:

| Selector | Called by the engine? | Call site |
|---|---|---|
| `transferred(address,address,uint256)` | yes | `RulesManagementModule.sol:214` |
| `transferred(address,address,address,uint256)` | yes | `RulesManagementModule.sol:233` |
| `detectTransferRestriction(address,address,uint256)` | yes | `RuleEngineBase.sol:169` |
| `detectTransferRestrictionFrom(address,address,address,uint256)` | yes | `RuleEngineBase.sol:193` |
| `canReturnTransferRestrictionCode(uint8)` | yes | `RuleEngineBase.sol:217` |
| `messageForTransferRestriction(uint8)` | yes | `RuleEngineBase.sol:218` |
| `canTransfer(address,address,uint256)` | **no** | — |
| `canTransferFrom(address,address,address,uint256)` | **no** | — |

`canTransfer` and `canTransferFrom` arrive through `IERC3643ComplianceRead` and `IERC7551Compliance`, inherited
via CMTAT's `IRuleEngineERC1404`. The engine never asks a rule either question: `RuleEngineBase.canTransfer`
computes the boolean itself from its own `detectTransferRestriction` loop.

Consequences, in the order they bite:

- **Every rule author implements two views that nothing calls.** All four reference rules in `src/mocks/rules/`
  do exactly that, and so must every rule in [CMTA/Rules](https://github.com/CMTA/Rules).
- **It is a least-privilege problem, not only an aesthetic one.** A rule that only needs to answer
  "is this restricted" must also expose the compliance-read surface to pass the gate.
- **It pushes implementers toward stubs.** A stub that returns a constant advertises a capability the rule does
  not have, which is worse than no check — an integrator reading the interface would reasonably call it.

The remedy is the standard one: declare the six selectors the engine actually consumes as the required
interface, and gate on that id. Three details decide whether it is worth doing:

- The two unused selectors come from **published standards** (ERC-3643, draft ERC-7551) reachable through
  CMTAT's interface. Narrowing means `IRule` stops inheriting `IRuleEngineERC1404` and declares its six
  selectors directly — this project's interface, not a standard, so it is legitimate to narrow.
- **`IRULE_INTERFACE_ID` changes**, and every existing rule must advertise the new id. Missing that step rejects
  rules that work today — a self-inflicted outage. The rules live in a separate repository, which is what makes
  this a coordinated release rather than a local edit.
- **ERC-165 expresses shape, never semantics.** A narrower id does not tell the engine an allow-list from a
  deny-list. That remains configuration discipline and must stay documented; the change must not be presented
  as closing that hole.

**Verdict: decide**, at a release where CMTA/Rules moves in step. Not a defect today — the current gate is
sound, merely broader than necessary.

## J. Modularity

The rc6 release claims the binding registry is reusable outside this project. That claim is testable, so it was
tested rather than asserted: two probe contracts were written, compiled, and deleted.

### J-1. The registry embeds in a foreign host — verified, inconvenience only

**Probe 1 — an unrelated host with its own ERC-2771 and RBAC:**

```solidity
contract ProbeERC2771 is ERC2771Context, AccessControl, TokenBindingExtendedModule {
    function _onlyTokenBindingManager() internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {}
    // + the three Context overrides ERC-2771 always forces
}
```

**Result: compiles.** The only work the integrator does is implement one hook and the `_msgSender` /
`_msgData` / `_contextSuffixLength` trio that any ERC-2771 host must write regardless of this module.

**Probe 2 — the harder case, a CMTAT token embedding the registry itself:**

```solidity
contract ProbeCMTAT is CMTATStandardStandalone, TokenBindingModule { … }
```

**Result: compiles**, after the same three overrides — reported by solc as `Error (6480)` ("derived contract
must override") until they are supplied. Critically, **no `Error (5005)`**: there is no linearization conflict
between the module's bases and a CMTAT token's, which is the failure class that no amount of override glue can
fix and that would make the reuse claim false.

The residual friction is that `TokenBindingModule` inherits OpenZeppelin's `Context` for `_msgSender()`. That is
the ecosystem convention — every OZ mixin does it — and removing it would mean inventing a project-specific
sender hook that integrators would have to wire anyway. **Verdict: leave as is**, with the two probes recorded
here as the evidence, and `TokenBindingStandaloneMock` + `test/TokenBinding/` standing as the compiling fixture
so the property cannot silently regress.

### J-2. The ERC-3643 adapter costs 35 gas per binding operation — left as is

`ERC3643ComplianceModule` overrides the generic `_onlyTokenBindingManager()` to call `_onlyComplianceManager()`,
adding one internal hop to every bind, unbind and approval call. Measured with two contracts, each exposing the
same `bindToken`, after an identical warm-up:

| Variant | `bindToken` |
|---|---|
| Direct — deployment implements the generic hook | **73 250** gas |
| Indirect — the shipped ERC-3643 adapter layer | **73 285** gas |

**35 gas**, on an administrative operation performed a handful of times in a deployment's life. That is the
price of keeping the ERC-3643 vocabulary at the ERC-3643 layer and the deployables' `_onlyComplianceManager`
API unchanged. Worth paying, and worth recording as a measurement rather than a guess.

## Method note

The rc5 report's warning about Aderyn writing absolute paths when run outside the repository proved its worth
again during this release: the first rc6 Aderyn run produced 84 links containing `/home/<user>/…` and had to be
redone. It is now a checklist item in the rc6 Aderyn feedback file.
