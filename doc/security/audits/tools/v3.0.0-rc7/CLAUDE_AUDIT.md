# RuleEngine v3.0.0-rc7 — Claude Security Audit

| | |
|---|---|
| **Tool** | Claude (Anthropic), driven by a set of custom smart-contract security-audit skills |
| **Codebase** | CMTA RuleEngine, branch `dev`, commit `51d0337` (final rc7 code) |
| **Scope** | `src/` without `src/mocks/`: `RuleEngineBase`, the modules, the six deployables |
| **Severity** | Code4rena scale: High / Medium / Low / Informational |
| **Date** | 2026-10-15 |

**Method.** Threat model of the actors and entry points, enumeration of the privileged surface with Slither's
call-graph, inheritance and function-summary printers, targeted review of each threat, executable proofs of
concept in the project's own test suite, mutation checks of the new tests, and an adversarial pass by a separate
agent whose task was to dismiss or downgrade every finding. The specific internal skills used are intentionally
not enumerated here.

This is a security review, not a formal audit. It complements the rc7 code-quality review
([CLAUDE_ANALYSIS.md](./CLAUDE_ANALYSIS.md)) and the Slither and Aderyn reports in this directory.

## 1. Scope & Methodology

**In scope:** `src/RuleEngineBase.sol`, `src/RuleEngineOwnableShared.sol`, `src/modules/**`, `src/interfaces/**`,
and the six deployables in `src/deployment/accessControl/` and `src/deployment/ownable/`.

**Out of scope:** `src/mocks/` (reference rules and test doubles), the CMTAT and T-REX token contracts, the
production rules maintained in [CMTA/Rules](https://github.com/CMTA/Rules), deployment scripts.

**Trust model.** The admin or owner, the rules manager, the compliance manager, the rule contracts and the trusted
ERC-2771 forwarder (for administrative calls) are trusted. A bound token is an address the manager chose. Anyone
can call the views. The engine holds no funds; its assets are authority: which rules run, which tokens may drive
them, and the codes and messages the views report.

**Steps.**

1. Threat model: 27 threats in seven groups (access control, token binding, rule execution, interfaces,
   forwarder, token-side integration, upgradeability), each with an ID and an initial severity.
2. Privileged surface from the Slither printers: every state-changing external function of the six deployables
   and its guard.
3. Review of each threat against the code and the documentation.
4. Tests: 105 new tests integrated in the suite, following its convention (a shared base in `test/utils/`, a short
   file per deployable), run in a Docker container (Foundry 1.5.1).
5. Mutation check: three deliberately broken versions of the code, each caught by a new test.
6. Adversarial pass, then correction of the findings.

## 2. Executive Summary

**0 Critical, 0 High, 0 Medium, 0 Low, 3 Informational** (F-1, F-2, F-3), plus one item already open in the
code-quality review (F-5). F-1, F-2 and F-3 have since been fixed (section 6); F-5 remains open. The first pass rated F-1 and F-2 Low; the adversarial pass downgraded them, and
dismissed three other items as documented behaviour (F-4, F-6, F-7).

**Cleared hypotheses.** These would have been High or Medium had they held; each was probed and does not:

- **An admin entry point callable without its guard.** Eleven administrative functions, six deployables, a
  fuzzed caller (256 runs each): every one rejects every other caller with the exact error of its guard.
- **An unbound caller driving the rules.** `transferred` (3 and 4 arguments), `created` and `destroyed` reject
  every caller that is not a bound token, fuzzed on all six deployables.
- **The trusted forwarder posing as a token.** Fixed earlier in rc7: token identity is `msg.sender`; covered by the
  existing ERC-2771 token-gate suites.
- **A rule reconfiguring the engine from its callback.** A rule that calls `addRule` from `transferred` is rejected,
  because rule accounts hold no role or ownership; the token operation reverts.
- **The ERC-165 gate fooled.** A contract claiming every interface, or one without ERC-165, is rejected.
- **No low-level hazard in `src/`:** no `unchecked` block, assembly, signature check, `delegatecall`, low-level call
  or `tx.origin`. No proxy: constructors only.

## 3. Findings

| ID | Title | Severity | Status | Component | PoC |
|----|-------|----------|--------|-----------|-----|
| F-1 | Pending owner turned rule can accept ownership | Info (was Low) | Fixed | `RuleEngineOwnable2Step.sol:29-32`, inherited `acceptOwnership` | `testNomineeAddedAsRuleBeforeAcceptingBecomesOwner` |
| F-2 | Self-binding approval survives an administrative unbind | Info (was Low) | Fixed (option 1) | `TokenBindingModule.sol:81`, `TokenBindingExtendedModule.sol:52, 98` | `testApprovedTokenRebindsItselfAfterManagerUnbinds` |
| F-3 | Any address can be bound, including a rule or an EOA | Info | Fixed (rules) / documented (EOAs) | `TokenBindingModule.sol:100` | `testCannotBindACurrentRule`, `testCannotAddABoundTokenAsRule`, `testBoundEoaConsumesStatefulRuleState` |
| F-4 | Views revert when a rule's view reverts | — | Dismissed: documented | `RuleEngineBase.sol:172, 214` | `testViewsRevertWhenARuleViewReverts` |
| F-5 | `*2771` deployables accept `address(0)` as forwarder | Info | Duplicate of code-quality review `H-3` (open) | constructors of the three `*2771` | `testZeroForwarderIsAccepted` |
| F-6 | Renouncing administration freezes the configuration | — | Dismissed: OpenZeppelin default, documented | inherited `renounceOwnership` / `renounceRole` | `testRenouncingAdministrationFreezesConfiguration` |
| F-7 | ERC-3643 mint and burn carry no operator | — | Dismissed: ERC-3643 interface, documented | `RuleEngineBase.sol:79, 84` | `testErc3643CreatedDoesNotReachSpenderKeyedRule` |

### F-1 — Pending owner turned rule can accept ownership (Info, was Low)

The project keeps rule accounts away from privileges. In the ownable deployables the check is
`_checkOwnershipTransferTarget`, called from `transferOwnership`:

```solidity
function transferOwnership(address newOwner) public virtual override onlyOwner {
    RuleEngineOwnableShared._checkOwnershipTransferTarget(newOwner);
    Ownable2Step.transferOwnership(newOwner);   // only records the pending owner
}
```

With `Ownable2Step`, ownership moves in `acceptOwnership`, inherited from OpenZeppelin, which does not repeat the
check. An address nominated while it is not a rule, then added as a rule, can still accept: the engine is then owned
by one of its own rules. Affects `RuleEngineOwnable2Step` and `RuleEngineOwnable2Step2771`.

**Severity adjustment.** First rated Low. Downgraded to Info: it requires two actions by the trusted owner, which
the owner can undo, and the same end state is already possible through the documented one-directional gap
(`RuleEngine-with-CMTAT.md` §4.6: the check "does not stop an already privileged address from later being added as
a rule"). F-1 adds a path, not a new end state.

**Recommendation.** Override `acceptOwnership` to call `_checkOwnershipTransferTarget(msg.sender)` first. It is a
three-line change that closes the path.

**Fixed.** `RuleEngineOwnable2Step` now overrides `acceptOwnership` and runs the check on `_msgSender()` (the same
sender OpenZeppelin's implementation uses, so the `*2771` variant resolves it through the forwarder consistently)
before delegating to `Ownable2Step.acceptOwnership`. A pending owner that is a rule reverts with
`RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges`; once removed from the rule set it can accept.
The proof of concept was inverted into `testNomineeAddedAsRuleBeforeAcceptingCannotAccept`, and
`testNomineeCanAcceptOnceRemovedFromRules` covers the recovery path, on both `Ownable2Step` deployables.

### F-2 — Self-binding approval survives an administrative unbind (Info, was Low)

`unbindToken` removes a token from the bound set and leaves its self-binding approval as it was. A token approved
for self-binding can therefore bind itself again after the compliance manager unbound it, and resume driving the
rules. The PoC uses a plain address; on a real T-REX token the path is longer, because `setCompliance(engine)` first
calls `unbindToken(this)` on the current compliance contract and reverts once the token is unbound, so the token's
owner has to point it at another compliance contract and then back at the engine. Revoking the approval before the
unbind prevents the re-bind (`testRevokingApprovalPreventsRebind`), but `RuleEngine-with-ERC3643.md` presents
revocation as optional.

**Severity adjustment.** First rated Low. Downgraded to Info: the token's owner gains nothing it could not do
already (it can leave the engine through `setCompliance` at any time), and re-binding puts the token back under
the engine's rules. What remains is that the manager's unbind does not stand on its own, which the documentation
does not say.

**Recommendation.** Three options, from the most to the least intrusive. Option 1 is the recommended one.

*Option 1 — the manager's unbind also revokes the approval (code).* Clear the approval inside `_unbindToken` when
the caller is not the token itself. `_unbindToken` is the point both `unbindToken` and the batch `unbindTokens`
reach, so one change covers both entry points; checking the raw `msg.sender`, as the rest of the token-identity
logic does since rc7, keeps the token's own unbind (ERC-3643 `setCompliance` migrating away) untouched.

```solidity
// TokenBindingExtendedModule
function _unbindToken(address token) internal virtual override {
    TokenBindingModule._unbindToken(token);
    if (msg.sender != token && _tokenSelfBindingApproval[token]) {
        _setTokenSelfBindingApproval(token, false); // writes the flag and emits TokenSelfBindingApprovalSet
    }
}
```

What it involves:

- **A diamond override.** `_unbindToken` is defined in `TokenBindingModule` and would now be overridden in
  `TokenBindingExtendedModule`; `ERC3643ComplianceExtendedModule` inherits both paths, so it needs the same
  disambiguating `override(TokenBindingModule, TokenBindingExtendedModule)` it already has for
  `_authorizeTokenBindingChange`.
- **One write path for the approval.** Factor the existing setter body into `_setTokenSelfBindingApproval`, used by
  `setTokenSelfBindingApproval` and by the code above, so every change of the flag emits
  `TokenSelfBindingApprovalSet` and indexers reconstructing approvals stay correct.
- **Behaviour change.** A token unbound by the manager must be approved again before it can bind itself. Clearing the
  flag on a manager *bind* instead is not equivalent: it would take away the approval an ERC-3643 token needs to
  unbind itself later when migrating to another compliance contract.
- **Tests.** Invert `testApprovedTokenRebindsItselfAfterManagerUnbinds` into a regression test, add the same case for
  `unbindTokens`, assert the `TokenSelfBindingApprovalSet(token, false)` event, and keep a test that a token
  unbinding itself keeps its approval. Gas: one extra storage read on unbind, plus a write and an event only when an
  approval was set.

*Option 2 — make the approval single-use (code).* Clear the flag when the token binds itself. It closes the re-bind
as well, but also removes the token's ability to unbind itself later, which ERC-3643 `setCompliance` needs to move to
another compliance contract; the manager would have to approve again before every migration. Not recommended.

*Option 3 — documentation only.* Keep the behaviour and state, in the `unbindToken` NatSpec, in
`TokenBinding-module.md` §4 and in `RuleEngine-with-ERC3643.md` §3.2, that an approved token can bind itself again
until its approval is revoked, so revocation must come before the unbind when the intent is to remove the token.
The current mitigation test, `testRevokingApprovalPreventsRebind`, already shows the correct order.

**Fixed: option 1.** `TokenBindingExtendedModule` overrides `_unbindToken`: after removing the token, it revokes
the approval when the caller is not the token itself (raw `msg.sender`), through a new `_setTokenSelfBindingApproval`
that also backs `setTokenSelfBindingApproval` and emits `TokenSelfBindingApprovalSet`. `ERC3643ComplianceExtendedModule`
disambiguates the override. Tests, on all six deployables: the proof of concept became
`testManagerUnbindRevokesSelfBindingApproval` (asserts the event and that the token can no longer bind itself), plus
`testManagerBatchUnbindRevokesSelfBindingApproval`, `testTokenUnbindingItselfKeepsApproval` and
`testManagerUnbindOfUnapprovedTokenEmitsNoApprovalEvent`. Removing the revocation fails two tests; revoking also on
the token's own unbind fails one.

### F-3 — Any address can be bound, including a rule or an EOA (Info)

`_bindToken` checks only for `address(0)` and duplicates. An address can be a rule and a bound token at the same
time, and a bound **exterwnally** owned account can drive a stateful rule with no token involved: the PoC consumes a
minter's allowance. Binding is therefore a full trust decision of the manager. A code-size check would not be a
defence (it is bypassed during construction).

**Recommendation.** Two parts: a small code change for rule addresses, and documentation for everything else.

*Part 1 — keep rules and bound tokens disjoint (code, recommended).* Both sets live in the engine, so unlike roles
the check can run in both directions and cheaply:

- **Binding a rule is rejected.** Add a virtual hook to the generic registry, for example
  `_checkBindingTarget(address token) internal view virtual {}` called from `_bindToken`. `TokenBindingModule` must
  stay free of rule logic (it is reused outside this project), so the hook is empty there and `RuleEngineBase`
  overrides it with `require(!containsRule(IRule(token)), RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges())`.
  The override needs the usual disambiguation, because `RuleEngineBase` inherits the registry through both
  `TokenBindingExtendedModule` and `ERC3643ComplianceModule`.
- **Adding a bound token as a rule is rejected.** In `RuleEngineBase._checkRule`, add
  `require(!isTokenBound(rule_), ...)`, reusing the same error.
- **What it prevents.** An address cannot both drive the rules and be one, which removes a reentrancy path where a
  rule's `transferred` calls the engine's `transferred` again as a bound token. It covers the batch `bindTokens` and
  the self-binding path too, since all of them reach `_bindToken`.
- **Cost.** One `EnumerableSet.contains` read per bind and per rule addition, no new error, no ABI change.
- **Tests.** Invert `testRuleAddressCanBeBoundAsToken` into two regression tests (bind a rule; add a bound token as a
  rule), on all six deployables.

*Part 2 — document binding as a trust decision (docs).* An EOA, or any contract, can still be bound, and that cannot
be fixed in code:

- **A code-size check is not a defence.** `token.code.length > 0` is false for a contract during its own
  construction, and it would block binding a token before it is deployed at a counterfactual (CREATE2) address, which
  a deployment script may want to do. It is not recommended.
- **What to write.** In the `bindToken` / `bindTokens` NatSpec and `TokenBinding-module.md` §4: a bound address is
  trusted to report token operations; it can drive every stateful rule (consume approvals, allowances, counters)
  without moving any token; bind only the token contracts the engine is meant to serve.
- `testBoundEoaConsumesStatefulRuleState` stays as the illustration of why.

**Fixed: both parts.**

- **Part 1, code.** `TokenBindingModule._bindToken` calls a new empty hook, `_checkBindingTarget`, which
  `RuleEngineBase` overrides to reject a current rule; `RuleEngineBase._checkRule` rejects a bound token. Both revert
  with `RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges`, so the ABI is unchanged and the
  reusable registry stays free of rule logic.
- **Coverage of the paths.** Every binding path (`bindToken`, `bindTokens`, a rule binding itself with an
  approval) and every rule path (`addRule`, `setRules`) goes through one of the two checks.
- **Part 2, documentation.** The `bindToken` NatSpec, the registry's `_bindToken` NatSpec and
  `TokenBinding-module.md` §4 state that binding is a trust decision.
- **Tests, on all six deployables.** The proof of concept became `testCannotBindACurrentRule` and
  `testCannotAddABoundTokenAsRule`; `testRuleAndTokenRolesCanBeSwappedSequentially` covers the legitimate
  sequences; the invariant handler now also tries to bind rule addresses, with a new
  `invariant_RulesAndBoundTokensAreDisjoint`. Removing either check fails its regression test and the invariant.
  `testBoundEoaConsumesStatefulRuleState` stays as the documented illustration.

### F-4 — Views revert when a rule's view reverts (dismissed)

The views make plain external calls to every rule, so a rule whose view reverts makes
`detectTransferRestriction(From)`, `canTransfer(From)` and `messageForTransferRestriction` revert, while the
enforcement path may still accept the operation. Dismissed: the CMTAT guide already states that a reverting
contract "still blocks the operation and the token's views, so it is trusted for availability too". Wrapping the
calls in `try/catch` would hide a broken rule behind an arbitrary answer, so the current behaviour is preferable.

### F-5 — `*2771` deployables accept `address(0)` as forwarder (duplicate)

Already open as `H-3` in the rc7 code-quality review. With a zero forwarder the contract behaves as the variant
without forwarder; `testZeroForwarderIsAccepted` now pins that behaviour.

### F-6 — Renouncing administration freezes the configuration (dismissed)

After the owner renounces, or the last admin renounces `DEFAULT_ADMIN_ROLE`, nobody can change the rules or the
bindings, and bound tokens keep running under the last rule set. This is OpenZeppelin's default and is documented.

### F-7 — ERC-3643 mint and burn carry no operator (dismissed)

`created` and `destroyed` have no spender argument, so a spender-keyed rule such as a per-minter allowance is not
applied to a T-REX mint, whereas CMTAT's 4-argument path carries the minter. This follows from the ERC-3643
interface and is documented in `RuleEngine-with-ERC3643.md`.

## 4. Invariant Verification

| Invariant | Property | Holds? | Evidence |
|---|---|---|---|
| INV-1 | The rule set never holds `address(0)`, a duplicate, or a contract without a rule ID | Yes | `invariant_RuleSetIsWellFormed`, 6 deployables, 3 200 calls each (handler-based) |
| INV-2 | `rulesCount() == rules().length` and `rule(i) == rules()[i]` | Yes | same |
| INV-3 | `maxRules() > 0` | Yes | `invariant_MaxRulesMatchesModelAndIsNotZero`, 6 deployables |
| INV-4 | Only a bound token reaches the rules through the engine | Yes | `testFuzz_UnboundCallerCannotDriveRules`, 6 × 256 runs; mutation-checked |
| INV-5 | Token identity is `msg.sender`, never the forwarder's appended sender | Yes | ERC-2771 token-gate suites, 3 deployables |
| INV-6 | Every admin entry point rejects every other caller | Yes | `testFuzz_NonAuthorizedCallerCannotAdminister`, 11 functions, 6 × 256 runs; mutation-checked |
| INV-7 | `canTransfer == (detectTransferRestriction == 0)`, and the 4-argument equivalent | Yes | rule-aggregation fuzz, 6 deployables |
| INV-8 | An address in the rule set cannot be granted a role, become owner, or be bound as a token, and a bound token cannot become a rule | Yes | checked at grant, at nomination, at `Ownable2Step` acceptance (F-1) and at binding / rule addition (F-3); `RuleGuard.t.sol`, `invariant_RulesAndBoundTokensAreDisjoint` (6 deployables), mutation-checked |
| INV-9 | `getTokenBounds()` holds no duplicate and no `address(0)` | Yes | `invariant_BoundTokensMatchModel`, 6 deployables |

The handler-based invariants run in the default suite at 64 sequences of 50 calls; they also passed once at
Foundry's defaults (256 × 500, 128 000 calls each).

## 5. Access-Control Verification

| Entry point | RBAC (`RuleEngine`, `RuleEngine2771`) | Ownable (four deployables) | Verified |
|---|---|---|---|
| `addRule`, `removeRule`, `setRules`, `clearRules` | `RULES_MANAGEMENT_ROLE` | owner | fuzz × 6 |
| `setMaxRules` | `DEFAULT_ADMIN_ROLE` | owner | fuzz × 6, mutation-checked |
| `bindToken`, `unbindToken` | `COMPLIANCE_MANAGER_ROLE`, or an approved token for itself; a current rule cannot be bound | owner, or an approved token for itself; a current rule cannot be bound | fuzz × 6, existing self-binding tests |
| `bindTokens`, `unbindTokens`, `setTokenSelfBindingApproval(Batch)` | `COMPLIANCE_MANAGER_ROLE` | owner | fuzz × 6 |
| `transferred` (3/4), `created`, `destroyed` | bound token (`msg.sender`) | same | fuzz × 6, mutation-checked |
| `grantRole` | role admin; the target must not be a rule | — | existing tests |
| `transferOwnership`, `acceptOwnership` | — | owner; the target must not be a rule, at nomination and at acceptance | existing tests, `RuleGuard.t.sol` (F-1) |

**Centralization premise.** In the RBAC deployables the default admin holds every role through the `hasRole`
override, and in the ownable deployables the owner holds all powers. This is the model, not a finding: the admin
key is the trust anchor, and its custody (multisig, timelock) is a deployment decision.

**Negative results.** A rules manager cannot change the cap or the bindings; a compliance manager cannot change the
rules; a bound token can only call the callbacks and, when approved, bind or unbind itself; a rule account cannot
call any administrative function, even from inside its callback.

## 6. Remediation — What Was Implemented

Three findings were fixed after the review; F-5 (H-3) is open.

| Item | Status | What changed | Verified by |
|---|---|---|---|
| F-1 | Fixed | `RuleEngineOwnable2Step.acceptOwnership` re-checks that the caller is not a rule (inherited by `RuleEngineOwnable2Step2771`). Behaviour change: a nominee that became a rule can no longer accept until it is removed from the rule set | PoC inverted into a regression test, plus a recovery test, on both deployables; removing the check makes both fail |
| F-2 | Fixed | A manager's `unbindToken` / `unbindTokens` revokes the token's self-binding approval (`_unbindToken` override, single approval write path). Behaviour change: an ERC-3643 token unbound by the manager needs a new approval before it can bind itself; a token unbinding itself keeps its approval | PoC inverted into a regression test, plus batch, self-unbind and event tests on six deployables; mutation-checked |
| F-3 | Fixed (rules) / documented (EOAs) | `_checkBindingTarget` hook in `TokenBindingModule`, overridden in `RuleEngineBase` to reject a current rule; `_checkRule` rejects a bound token; NatSpec and `TokenBinding-module.md` document binding as a trust decision. Behaviour change: an address can no longer be both a rule and a bound token | PoC inverted into two regression tests, plus a sequencing test and a new handler invariant on six deployables; mutation-checked |
| F-5 / H-3 | Open | Behaviour unchanged; pinned on three deployables | `ERC2771VariantTestBase` |
| Access control, unbound callers | Verified | New fuzz tests on six deployables | mutation-checked |

**Tests added.** 105 tests: `test/utils/SecurityReviewTestBase.sol` (15 tests, run by `test/<Variant>/SecurityReview.t.sol`
for the six deployables), `invariant_RulesAndBoundTokensAreDisjoint` in `test/utils/RuleEngineInvariantTestBase.sol`
(six deployables), `test/utils/Ownable2StepRuleGuardTestBase.sol` (3 tests, run by `RuleGuard.t.sol` for the
two `Ownable2Step` deployables), `testZeroForwarderIsAccepted` in `test/utils/ERC2771VariantTestBase.sol` (three
`*2771` deployables), and two test-only rules, `RevertingViewRule` and `ReentrantAdminRule`. Suite: 610 tests, all
passing; the real T-REX suite: 13, all passing; coverage of `src/` at 100% of lines, statements,
branches (54/54) and functions.

Several new tests pin today's behaviour of an open item. When an item is fixed, its PoC is expected to fail and must
be inverted into a regression test, as was done for F-1, F-2 and F-3: applying each fix made its PoC fail, and the PoC
was then rewritten to assert the fixed behaviour.

## 7. Potential Improvements (open backlog)

These are hardening items, not vulnerabilities.

| # | Improvement | Addresses | Effort | Breaking? | Priority |
|---|---|---|---|---|---|
| 1 | Decide `H-3`: reject `address(0)` as forwarder in the three `*2771` constructors (not in `ERC2771ModuleStandalone`, which the mock rules use with zero) | F-5 | Small | Constructor rejects a value it accepts today | Low |

## 8. Scope & Duplicate Check

All items are in scope (`src/`).

- **Duplicates:** F-5 is `H-3` of the rc7 code-quality review. F-3's multi-tenant aspect (several tokens sharing
  one engine's rule state) is the rc1 Nethermind Audit Agent finding 1, already documented.
- **Documented behaviours:** F-4, F-6 and F-7.
- **New:** F-1, F-2 and F-3 do not appear in the earlier reviews, the Slither and Aderyn reports, or the Nethermind
  triage.
- **Static analysis:** Slither's `calls-loop` and `unindexed-event-address` results, by design, were not re-raised.

**Considered and dismissed:**

| Threat | Reason |
|---|---|
| Compromised admin, rules manager or forwarder | Trusted actors; keys are a deployment responsibility |
| Admin cannot be stripped of a single role | By design (`hasRole` override), documented |
| Several tokens on one engine share rule state | By design, documented |
| `getTokenBound()` returns an arbitrary token when several are bound | By design, documented |
| Batch binding reverts as a whole | By design (code-quality review C-3) |
| Reverting or gas-heavy rule blocks transfers | Rules are trusted; the cap bounds the loop |
| 3-argument views fail open for spender-dependent rules | Documented (rc5 code-quality review `H-1`) |
| Two rules sharing a restriction code | Documented; the first claimant's message is returned |
| Legacy `IRule` ID accepted | By design: it describes a superset of what the engine calls |
| Zero-value CMTAT `transferFrom` reaching the engine | A rule obligation, documented by CMTAT |
| Engine must revert on a rejected operation | Verified by the CMTAT and T-REX integration suites |
| Initializer front-running, storage collision | No proxy |
