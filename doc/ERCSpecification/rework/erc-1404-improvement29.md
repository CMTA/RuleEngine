# ERC-1404 (rework) — Suggested Improvements

**Scope:** Review of the reworked ERC-1404 draft (`doc/ERCSpecification/rework/erc-1404.md`)
for normative gaps, from the perspective of an implementer building a
standalone rule engine against it.

**Summary:** The draft is in good shape — the OPTIONAL spender-aware extension,
the split ERC-165 identifiers, and the reporting/enforcement invariant are all
well argued. What follows targets the gaps rather than the parts that work.
Two of the seven items below are places where an implementation can be fully
conformant on paper and still surprise an integrator; those are ranked first.

Review date: 2026-07-29. Line numbers refer to `erc-1404.md` as of that date.
Implementation evidence is drawn from this repository (RuleEngine v3.0.0).

---

## 1. For a standalone compliance contract, the central MUST has no addressee

**Severity:** highest — this is a normative hole, not a wording issue.

Line 48 places the load-bearing requirement on *enforcement*:

> Enforcement MUST be consistent with `detectTransferRestriction` for the same
> state and inputs: a transfer MUST be rejected whenever
> `detectTransferRestriction` would return a non-zero code for that transfer […]

Line 117 then blesses contracts that implement the interface without being a
token, and narrows what the standard covers for them:

> Compliance-related contracts (for example, a rule engine or compliance module)
> MAY implement the ERC-1404 restriction interface without implementing any
> token interface at all. In such cases, this standard only defines the behavior
> of `detectTransferRestriction` and `messageForTransferRestriction`, and the
> contract is expected to be consulted by a token or other caller that performs
> the actual transfer.

A rule engine has no transfer path, so line 48 is vacuous for it. The token that
consults it is not bound by line 48 either, because the token is not the contract
implementing the interface. The clause that would close the gap — "the contract is
**expected** to be consulted by a token or other caller" — uses non-RFC-2119
language.

**Consequence:** as written, a token may call a compliance contract, receive a
non-zero code, ignore it, and no party is in violation of the standard.

**Suggested addition** (§Additional Specifications):

> Where the restriction interface is implemented by a contract that does not
> itself perform transfers, the enforcement-consistency requirement binds the
> token or caller that consults it: that caller MUST reject a transfer whenever
> the consulted contract returns a non-zero code for the same state and inputs,
> and MUST NOT reject it for restriction reasons when the consulted contract
> returns `0`.

This also gives line 250's "verify it under test" advice something to attach to
across a contract boundary, which it currently cannot reach.

---

## 2. Mint/burn — the zero-address encoding is load-bearing but never stated

**Severity:** high. Mint and burn are the operations permissioned-token issuers
care most about, and they receive one MAY sentence (line 113).

### 2a. The `address(0)` convention is unspecified

Line 113 permits mint/burn checks and permits `spender` to carry the initiating
operator, but never states how `from` and `to` encode a mint or a burn. In
practice every implementation uses `from == address(0)` for mint and
`to == address(0)` for burn — and **policies branch on it**:

```solidity
// src/mocks/rules/validation/RuleWhitelist.sol:86
// Mint (from == address(0)) and burn (to == address(0)) are exempt from spender check
if (from != address(0) && to != address(0) && !addressIsListed(spender)) {
    return CODE_ADDRESS_SPENDER_NOT_WHITELISTED;
}
```

A convention that policies branch on, and that two implementations could
reasonably disagree about, belongs in the specification.

The unstated convention also has a sharp edge. A whitelist policy evaluating
`detectTransferRestriction(address(0), to, value)` returns "sender not
whitelisted", because `address(0)` is not on the list. The workaround this
repository is forced into is to whitelist the zero address in order to permit
minting:

```solidity
// test/RuleWhitelist/CMTATIntegrationBase.sol:270-272
// Add address zero to the whitelist
vm.prank(DEFAULT_ADMIN_ADDRESS);
ruleWhitelist.addAddressToTheList(ZERO_ADDRESS);
```

One sentence in the spec would prevent this wart.

### 2b. No enforcement-consistency requirement for mint/burn

The MUST at line 88 is scoped to `transferFrom`. Nothing binds the mint/burn
case. An implementation may therefore report a mint restriction through
`detectTransferRestrictionFrom` and not enforce it, without violating the
standard — which defeats the core promise for precisely the operation issuers
most depend on.

### 2c. No guidance on which predictor matches which entry point

For a mint there are two plausible predictors:

| Predictor | Sees the operator? |
|---|---|
| `detectTransferRestriction(address(0), to, value)` | no |
| `detectTransferRestrictionFrom(spender, address(0), to, value)` | yes |

They legitimately disagree whenever the policy restricts the minter. This is not
hypothetical — the RuleEngine has two mint/burn enforcement paths, and only one
carries the operator:

| Token calls | Engine path | Rule hook | Matching predictor | Operator visible? |
|---|---|---|---|---|
| `transferred(spender, 0, to, value)` (CMTAT ≥ v3.3.0) | 4-arg `_transferred` | `rule.transferred(spender,…)` | `detectTransferRestrictionFrom` | yes |
| `created(to, value)` / `destroyed(from, value)` (ERC-3643) | 3-arg `_transferred` | `rule.transferred(from,to,value)` | `detectTransferRestriction` | no |

Each path is internally consistent, but they are not interchangeable: predicting
a `created()` mint with `detectTransferRestrictionFrom` over-reports a
restriction that path never enforces. The spec should state that the predictor
must match the entry point the token actually uses.

**Recommendation:** promote line 113 from a single bullet to a short subsection
covering the `address(0)` encoding, an enforcement-consistency requirement
parallel to line 88, and predictor/entry-point correspondence.

---

## 3. Nothing about aggregation, which is the dominant real architecture

Line 117 acknowledges that rule engines exist, then stops. The common deployed
shape is token → engine → N independently-authored rules, but the spec's model
implicitly assumes a single policy owns the whole restriction-code space. Three
consequences go unaddressed:

- **Code collision.** Line 123 advises allocating codes "carefully". This is not
  actionable when rules are pluggable and third-party-authored, all sharing the
  same 255 non-zero values.
- **Reverse lookup.** An aggregator's `messageForTransferRestriction` must map a
  code back to the rule that owns it. This repository does so with a
  `canReturnTransferRestrictionCode` probe and a first-claimant-wins scan
  (`src/RuleEngineBase.sol`) — a mechanism the standard neither provides nor
  acknowledges is necessary.
- **Ordering.** Which code surfaces when several rules reject? Line 156 concedes
  that evaluation order is implementation-defined within one policy; across
  policies, order should at least be REQUIRED to be deterministic, since a
  non-deterministic aggregator breaks the very reporting/enforcement equivalence
  the Security Considerations defend at length.

---

## 4. Unknown-code behavior is unspecified

Line 62 pins the reserved code `0`, and the Test Cases table (lines 174–175)
covers `0` and known codes. Nothing states what an *unknown* code must return.

Reverting there is a real hazard for a UI iterating codes, and implementations
diverge in practice. Within this single stack, CMTAT's `ValidationModuleERC1404`
returns `"UnknownCode"` while `RuleEngineBase` returns
`"Unknown restriction code"`.

**Suggested addition** (§`messageForTransferRestriction`):

> For a code the implementation does not recognize, this SHOULD return a
> deterministic, non-empty human-readable string and SHOULD NOT revert.

---

## 5. Move the "only `0` is reserved" statement into Specification

The statement that the standard reserves only code `0` and leaves all other
values issuer-defined currently appears only at line 222, inside the Reference
Implementation section:

> Note that codes `1` and `2` are specific to this implementation; ERC-1404 does
> not standardize restriction code values beyond reserving `0` as the "no
> restriction" sentinel.

In that location it reads as a note about the example rather than a normative
statement about the standard. It belongs in §Specification or §Additional
Specifications.

---

## 6. Test-case row for `detectTransferRestrictionFrom` needs the ordering caveat

Line 168 states:

| Scenario | Expected return |
|---|---|
| `from` or `to` violates the policy | The same non-zero code `detectTransferRestriction` returns for that condition |

This lacks the caveat that line 156 carries for the base method. Row 167 already
establishes that a spender-specific code may take precedence, so row 168 should
be scoped: *when no spender-specific restriction applies*. As written the two
rows can be read as contradictory when both a spender restriction and a
`from`/`to` violation apply simultaneously.

---

## 7. Editorial balance

The `spender == from` case is argued at length in three separate places —
Specification (lines 89–91), Rationale (lines 137–139), and Security
Considerations (line 254). It is the most re-litigated point in the document,
while mint/burn receives a single sentence and aggregation receives none.
Consolidating the first would make room for items 2 and 3.

---

## Summary

| # | Item | Type | Severity |
|---|---|---|---|
| 1 | Enforcement MUST has no addressee for standalone compliance contracts | Normative hole | High |
| 2 | Mint/burn: `address(0)` encoding, consistency requirement, predictor correspondence | Normative gap | High |
| 3 | No aggregation semantics (code collision, reverse lookup, ordering) | Normative gap | Medium |
| 4 | Unknown-code behavior of `messageForTransferRestriction` unspecified | Normative gap | Medium |
| 5 | "Only `0` is reserved" stated only in the Reference Implementation section | Placement | Low |
| 6 | Test-case row 168 missing the evaluation-order caveat | Consistency | Low |
| 7 | `spender == from` argued three times; mint/burn once, aggregation never | Editorial | Low |

**Priority:** items 1 and 2 are the ones worth acting on first — they are the two
places where an implementation can be fully conformant on paper and still
surprise an integrator.
