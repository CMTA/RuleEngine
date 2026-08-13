# ERC-1404 (rework) Conformance Analysis — RuleEngine

**Scope:** Does the RuleEngine implement the reworked ERC-1404 draft
(`doc/ERCSpecification/rework/erc-1404.md`) correctly?

**Verdict:** ✅ **Conformant.** The RuleEngine implements both mandatory
methods, the optional spender-aware extension, and both ERC-165 identifiers
exactly as specified. It is used in the "standalone compliance contract" mode
the reworked spec explicitly blesses. The one minor observation that was noted
on the `messageForTransferRestriction(0)` return value has since been fixed
(§7).

Analysis date: 2026-07-21. Files cited are at the paths shown.
Item 13 resolved on 2026-07-29.

---

## 1. What the reworked spec requires

The rework keeps the original two-method core and adds an OPTIONAL spender-aware
extension plus explicit ERC-165 identifiers:

| Requirement | Level | Source (spec §) |
|---|---|---|
| `detectTransferRestriction(address,address,uint256) → uint8` | MUST | Methods |
| `messageForTransferRestriction(uint8) → string` | MUST | Methods |
| `detectTransferRestrictionFrom(address,address,address,uint256) → uint8` | OPTIONAL (extension) | Extension |
| Enforcement consistent with `detectTransferRestriction` | MUST | Methods, Security |
| Extension consistent with `transferFrom` enforcement | MUST (if exposed) | Extension |
| `spender == from` evaluated through spender-aware path | SHOULD (if exposed) | Extension, Security |
| ERC-165 base id `0xab84a5c8` (2 mandatory methods) | MUST if ERC-165 | §Additional |
| ERC-165 extension id `0x78a8de7d` (all 3 methods) | MUST if extension + ERC-165 | Extension |
| A compliance contract MAY implement the restriction interface without being a token | Allowed | §Additional |
| Restriction checks on mint/burn | MAY | §Additional |
| `messageForTransferRestriction(0)` → deterministic "no restriction" string | Test case (SHOULD verify) | Test Cases |

---

## 2. Mandatory interface — ✅

Both mandatory methods are declared on `RuleEngineBase` and inherited by all
three deployable variants (`RuleEngine`, `RuleEngineOwnable`,
`RuleEngineOwnable2Step`).

`src/RuleEngineBase.sol:84` — `detectTransferRestriction(from, to, value)`
delegates to `_detectTransferRestriction`, which iterates the active rule set
and returns the first non-zero code, else `0` (`TRANSFER_OK`):

```solidity
function _detectTransferRestriction(address from, address to, uint256 value) internal view virtual returns (uint8) {
    for (uint256 i = 0; i < rulesCount(); ++i) {
        uint8 restriction = IRule(rule(i)).detectTransferRestriction(from, to, value);
        if (restriction > 0) return restriction;
    }
    return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
}
```

`src/RuleEngineBase.sol` — `messageForTransferRestriction(uint8)` returns
`"NoRestriction"` for the reserved code `0`, otherwise the message of the first
rule that claims the code (via `canReturnTransferRestrictionCode`), else
`"Unknown restriction code"`.

Signatures match the spec exactly (`address,address,uint256 → uint8` and
`uint8 → string memory`), both `view`. ✅

---

## 3. Standalone compliance-contract mode — ✅

The reworked spec added explicit language (§Additional Specifications, and
Security Considerations final bullet) that a **rule engine / compliance module
MAY implement the restriction interface without implementing any token
interface**. The RuleEngine is exactly this: it holds no balances and performs
no transfers; it is consulted by the bound CMTAT/ERC-3643 token. This is the
mode the rework was written to legitimize, so the RuleEngine matches the
spec's intent, not merely its letter. ✅

---

## 4. Enforcement consistency — ✅ (by construction, per-rule)

The spec's central MUST: a transfer MUST be rejected iff
`detectTransferRestriction` returns non-zero for the same state/inputs.

The RuleEngine does not re-implement policy — it aggregates rules. The reporting
path (`_detectTransferRestriction`) and the enforcement path (`_transferred`)
iterate **the same `_rules` set in the same order**:

- Reporting: `rule.detectTransferRestriction(from,to,value)` — `RuleEngineBase.sol:149`
- Enforcement: `rule.transferred(from,to,value)` — `RulesManagementModule.sol:203`

So the RuleEngine's aggregate behavior is consistent **iff each individual rule
keeps its own `transferred` consistent with its `detectTransferRestriction`**.
The reference rule does this correctly — `RuleWhitelist.transferred` literally
calls `detectTransferRestriction` and reverts on non-zero
(`src/mocks/rules/validation/RuleWhitelist.sol:93`):

```solidity
function transferred(address from, address to, uint256 value) public {
    uint8 code = detectTransferRestriction(from, to, value);
    require(code == uint8(REJECTED_CODE_BASE.TRANSFER_OK), RuleWhitelist_InvalidTransfer(...));
}
```

This is the RECOMMENDED "invoke `detectTransferRestriction` inside the transfer
path" pattern, which the spec says guarantees consistency by construction. ✅

> **Note (design boundary, not a defect):** the RuleEngine cannot *force*
> third-party rules to stay consistent. The spec places the
> reporting/enforcement equivalence invariant on the implementation and
> recommends verifying it under test. The RuleEngine's aggregation preserves
> whatever consistency each rule provides; a buggy custom rule could break it.
> This is inherent to the pluggable-rule architecture and is the correct place
> to draw the line.

---

## 5. Optional spender-aware extension — ✅

The extension is fully implemented.

`src/RuleEngineBase.sol:97` — `detectTransferRestrictionFrom(spender,from,to,value)`
delegates to `_detectTransferRestrictionFrom`, aggregating
`rule.detectTransferRestrictionFrom(...)` with the same first-non-zero logic.
It **shares the restriction-code space** of the base method (same enum, same
`messageForTransferRestriction` lookup), as the spec requires.

Delegated-transfer enforcement uses the 4-arg
`_transferred(spender,from,to,value)` path
(`RulesManagementModule.sol:222`), which calls `rule.transferred(spender,...)`.
For the reference rule that path calls `detectTransferRestrictionFrom` and
reverts on non-zero (`RuleWhitelist.sol:98`), so the extension predictor and
`transferFrom` enforcement agree. ✅

### `spender == from` — SHOULD honored ✅

The spec's SHOULD: because `transferFrom` is a distinct delegated-transfer
entry point, `spender == from` should be evaluated through the spender-aware
path (not collapsed to the direct predictor) whenever the policy restricts
operator identity. The reference rule does **not** short-circuit; it always
checks the operator (`RuleWhitelist.sol:79`):

```solidity
function detectTransferRestrictionFrom(address spender, address from, address to, uint256 value) public view override returns (uint8) {
    // Mint / burn are exempt from the spender check
    if (from != address(0) && to != address(0) && !addressIsListed(spender)) {
        return CODE_ADDRESS_SPENDER_NOT_WHITELISTED;
    }
    return detectTransferRestriction(from, to, value);
}
```

The whitelist policy *does* restrict operator identity, so evaluating the
spender even when `spender == from` is exactly what the spec's Security
Considerations warn must not be skipped. It also correctly stays consistent:
if `spender == from` and `from` is whitelisted, the spender check passes and it
falls through to the base predictor — the two coincide, as the spec permits.
✅

### Mint / burn handling — ✅ (spec MAY)

The spec permits restriction checks on mint/burn and allows the `spender`
parameter to carry the operator. The RuleEngine routes mint/burn through
`created`/`destroyed` → the 3-arg `_transferred` (no spender)
(`RuleEngineBase.sol:66`), while the 4-arg `transferred` path (CMTAT v3.3.0)
carries the operator as `spender`. The reference rule exempts mint
(`from == 0`) and burn (`to == 0`) from the spender check, so those operations
are not blocked by an unlisted operator. This matches the spec's guidance that
rules checking `spender` "must skip or adapt that check for mint/burn." ✅

---

## 6. ERC-165 identifiers — ✅ (values verified)

Both identifiers are advertised. `RuleEngineBase._supportsRuleEngineBaseInterface`
(`src/RuleEngineBase.sol:206`) returns `true` for:

- `ERC1404InterfaceId.IERC1404_INTERFACE_ID = 0xab84a5c8` (`src/modules/library/ERC1404InterfaceId.sol:10`)
- `ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID = 0x78a8de7d` (CMTAT `library/ERC1404ExtendInterfaceId.sol`)

Each deployable variant chains this into its `supportsInterface`
(`RuleEngine.sol:82` via `AccessControlEnumerable`; ownable variants via
`RuleEngineOwnableShared.sol:29` and `RuleEngineOwnable2Step.sol:49`), and OZ's
ERC-165 base supplies `0x01ffc9a7`.

I recomputed both selectors with `cast` to confirm they match the spec's pinned
values:

```
detectTransferRestriction(address,address,uint256)          = 0xd4ce1415
messageForTransferRestriction(uint8)                        = 0x7f4ab1dd
detectTransferRestrictionFrom(address,address,address,uint256) = 0xd32c7bb5

base id      = detect ^ msg           = 0xab84a5c8   ✅ (matches spec)
extension id = detect ^ msg ^ detectFrom = 0x78a8de7d ✅ (matches spec)
```

This satisfies the spec's requirements precisely:

- The base id is the XOR of the **two mandatory methods only** — the extension
  does not alter it (spec §Extension, "MUST NOT change the meaning of…"). ✅
- The extension id is the XOR of **all three selectors**, not just the added
  method — self-contained, so a single `supportsInterface(0x78a8de7d)` proves
  all three are present (spec §Extension rationale). ✅
- An extension-exposing implementation advertises **both** ids. ✅

---

## 7. Minor observation — ✅ resolved

**`messageForTransferRestriction(0)` used to return `"Unknown restriction code"`.**

The spec's Test Cases table lists `messageForTransferRestriction(0) →` "a
deterministic human-readable string indicating no restriction (e.g. `"No
restriction"`)". Previously, code `0` was `TRANSFER_OK` and no rule claimed it
(`RuleWhitelistCommon.canReturnTransferRestrictionCode` returns `false` for
`0`), so the aggregate lookup fell through to `"Unknown restriction code"`.

- **Severity:** cosmetic / informational only. The return was still
  deterministic and human-readable, and `0` never accompanies a rejected
  transfer, so no reporting/enforcement invariant was affected. The spec text is
  a SHOULD-verify test case using "e.g.", not a normative MUST on the exact
  string.
- **Impact:** a UI that special-cases the ERC-1404 sentinel `0` read
  `"Unknown restriction code"` for a perfectly valid transfer, which was
  slightly misleading.
- **Fix applied:** `RuleEngineBase._messageForTransferRestriction` now
  short-circuits `restrictionCode == REJECTED_CODE_BASE.TRANSFER_OK` and
  returns `TEXT_TRANSFER_OK` before iterating the rules. The string is
  `"NoRestriction"` — the same value CMTAT's `ValidationModuleERC1404` returns
  for code `0` — so a UI reading the token or the engine directly gets an
  identical answer. The spec only gives `"No restriction"` as an example, so
  either value satisfies the SHOULD; matching CMTAT was preferred for
  consistency across the stack.
- **Reference rules:** the same short-circuit was added to the reference rules
  that advertise the ERC-1404 identifiers (`RuleWhitelistCommon`,
  `RuleConditionalTransferLight`, `RuleMintAllowance`), so they answer code `0`
  the same way when queried directly. `RuleOperationRevert` is intentionally
  left unchanged — it is a deliberately non-conformant mock used to exercise
  the engine's revert paths.
- **Tests:** `messageForTransferRestriction(0)` is asserted for all three
  deployable variants (`RuleEngine`, `RuleEngineOwnable`,
  `RuleEngineOwnable2Step`), both with an active rule and with an empty rule
  set, plus at the rule level in `test/RuleWhitelist/RuleWhitelist.t.sol`.

---

## 8. Requirement-by-requirement summary

| # | Requirement | Level | Status |
|---|---|---|---|
| 1 | `detectTransferRestriction(address,address,uint256)` | MUST | ✅ |
| 2 | `messageForTransferRestriction(uint8)` | MUST | ✅ |
| 3 | Enforcement consistent with reporting | MUST | ✅ (per-rule, by construction) |
| 4 | `detectTransferRestrictionFrom` extension | OPTIONAL | ✅ implemented |
| 5 | Extension consistent with `transferFrom` enforcement | MUST (if exposed) | ✅ |
| 6 | `spender == from` via spender-aware path | SHOULD | ✅ (no collapse; operator checked) |
| 7 | Extension shares code space + message lookup | MUST (if exposed) | ✅ |
| 8 | ERC-165 base id `0xab84a5c8` | MUST if ERC-165 | ✅ (recomputed) |
| 9 | ERC-165 extension id `0x78a8de7d` | MUST if extension | ✅ (recomputed) |
| 10 | ERC-165 base id unchanged by extension | MUST | ✅ |
| 11 | Standalone compliance contract (no token iface) | Allowed | ✅ (intended mode) |
| 12 | Mint/burn restriction checks | MAY | ✅ (adapted for spender) |
| 13 | `messageForTransferRestriction(0)` → "no restriction" string | SHOULD-verify | ✅ returns `"NoRestriction"` |

**Conclusion:** The RuleEngine is a correct and complete implementation of the
reworked ERC-1404 draft, including the optional spender-aware extension and
both ERC-165 identifiers, operating in the standalone-compliance-contract mode
the rework explicitly permits. The only deviation — the cosmetic message
returned for code `0` — has been fixed; every row of the table above is now
satisfied.
