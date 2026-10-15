# Using the RuleEngine with an ERC-3643 token

How to attach a RuleEngine to an [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643) (T-REX) token as its compliance contract, which entry points the token actually calls, how to configure the self-binding handshake, and the limitations to know about before deploying.

For the CMTAT equivalent, see [RuleEngine-with-CMTAT.md](./RuleEngine-with-CMTAT.md). The two standards drive
**disjoint entry points** on the engine, so a rule or an integration written against one does not
automatically hold for the other.

## 1. Flow

![RuleEngine flow with an ERC-3643 token](../schema/plantuml/ruleengine-flow-erc3643.png)

_Diagram source: [doc/schema/plantuml/ruleengine-flow-erc3643.puml](../schema/plantuml/ruleengine-flow-erc3643.puml)._

## 2. Which entry points an ERC-3643 token uses

In ERC-3643 the RuleEngine plays the role of the **compliance contract**. Taken from `Token.sol` in the reference implementation (submodule `lib/ERC-3643`, tag 4.2.0-beta1; unchanged from 4.1.3 for these calls), and pinned against the real token by `test/ERC3643Real/` (section 5):

| Token operation | Pre-check | State-changing callback |
|---|---|---|
| `transfer(to, amount)` | `canTransfer(msg.sender, to, amount)` | `transferred(msg.sender, to, amount)` |
| `transferFrom(from, to, amount)` | `canTransfer(from, to, amount)` | `transferred(from, to, amount)` |
| `forcedTransfer(from, to, amount)` | — | `transferred(from, to, amount)` |
| `mint(to, amount)` | `canTransfer(address(0), to, amount)` | `created(to, amount)` |
| `burn(from, amount)` | — | `destroyed(from, amount)` |
| `setCompliance(newCompliance)` | — | `unbindToken(this)` then `bindToken(this)` |

Two consequences follow:

- **ERC-3643 compliance callbacks carry no spender.** An ERC-3643 token therefore *never* reaches the
  4-argument `transferred(spender, from, to, value)` overload — that one is declared by CMTAT's `IRuleEngine`,
  not by ERC-3643. Everything goes through the 3-argument form.
- **Mint and burn use dedicated entry points**, `created` and `destroyed`, rather than `transferred`. Inside
  the engine both run the same 3-argument rule loop:
  `created(to, value)` → `_transferred(address(0), to, value)`, and
  `destroyed(from, value)` → `_transferred(from, address(0), value)`.

Note the mint pre-check passes `address(0)` as the origin. That single detail drives two of the limitations in
section 4.

## 3. Configuration

### 3.1 Deploy the RuleEngine

Same three variants as for CMTAT. ERC-3643's own specification points at ERC-173 for ownership:

> The standard relies on ERC-173 to define contract ownership, with the owner having the responsibility of setting the Compliance parameters and binding the Compliance to a Token contract.

so `RuleEngineOwnable` or `RuleEngineOwnable2Step` is the closest match to the spec, though `RuleEngine` (role-based) works identically and is preferable with multiple operators.

```solidity
RuleEngineOwnable engine = new RuleEngineOwnable(owner, forwarder, address(0));
```

### 3.2 Grant self-binding approval — required before `setCompliance`

`Token.setCompliance` makes the **token** call `bindToken` and `unbindToken` on the compliance contract, not
the operator:

```solidity
function setCompliance(address _compliance) public override onlyOwner {
    if (address(_tokenCompliance) != address(0)) {
        _tokenCompliance.unbindToken(address(this));
    }
    _tokenCompliance = IModularCompliance(_compliance);
    _tokenCompliance.bindToken(address(this));
    emit ComplianceAdded(_compliance);
}
```

To support that without letting arbitrary contracts bind themselves, the engine gates self-binding behind an explicit approval:

```solidity
engine.setTokenSelfBindingApproval(address(token), true);   // COMPLIANCE_MANAGER_ROLE, or owner
engine.isTokenSelfBindingApproved(address(token));          // -> true
```

**Recommended operational sequence:**

1. On the target engine, grant self-binding approval for the token.
2. Call `token.setCompliance(address(engine))`.
3. Optionally revoke the approval afterwards if no further migration is expected.

Without step 1, `setCompliance` reverts. This is exercised by
`testSetComplianceRevertsWithoutSelfBindingApproval`.

An operator can equally bind the token directly with `engine.bindToken(address(token))` and skip the approval entirely — self-binding approval exists specifically to support the T-REX `setCompliance` pattern.

### 3.3 Migrating between engines

`setCompliance` unbinds from the old compliance and binds to the new one in a single transaction. The **new** engine must have granted self-binding approval for the token before the call; the old one does not need it still granted for the unbind to succeed. 

Verified by `testSetComplianceUnbindsThePreviousEngine`.

### 3.4 Add rules

Identical to the CMTAT case:

```solidity
engine.addRule(IRule(address(rule)));
```

Rules must implement `IRule` and advertise `RuleInterfaceId.IRULE_INTERFACE_ID` via ERC-165. They run in declaration order; the first to revert aborts the transaction.

### 3.5 Batch helpers

The extended compliance module adds operator-side batch operations:

```solidity
engine.bindTokens(tokens);                             // bind several tokens
engine.unbindTokens(tokens);
engine.setTokenSelfBindingApprovalBatch(tokens, true);
engine.getTokenBounds();                               // every bound token
```

### 3.6 Where binding is implemented

The binding registry itself is standard-agnostic and lives in `TokenBindingModule` /
`TokenBindingExtendedModule`; `ERC3643ComplianceModule` / `ERC3643ComplianceExtendedModule` are thin
ERC-3643 adapters over it, adding `getTokenBound()` and the compliance manager vocabulary. This matters
here only for reading the code and for reusing the registry elsewhere: the engine's external API is
unchanged. See [TokenBinding-module.md](./TokenBinding-module.md).

## 4. Warnings and limitations

### 4.1 The mint pre-check fails open for spender-dependent rules

`Token.mint` pre-checks with `canTransfer(address(0), _to, _amount)`. That signature carries **no spender**, so a rule keyed by spender — a per-minter allowance, for instance — cannot evaluate the mint and must answer "no restriction". 

The engine aggregates that answer, so the pre-check reports the mint as allowed even when a spender-aware rule would reject it.

The state-changing path is unaffected and still enforces correctly; the damage is to anything that trusts the pre-check. Pinned by `testMintPreCheckFailsOpenForSpenderKeyedRule`, and recorded as finding `H-1` in [CLAUDE_ANALYSIS.md](../security/audits/tools/v3.0.0-rc5/CLAUDE_ANALYSIS.md).

### 4.2 `address(0)` must be whitelisted for minting to work

**This concerns `RuleWhitelistMock`, a reference rule in `src/mocks/`, not a production rule.** Production rules live in [CMTA/Rules](https://github.com/CMTA/Rules) and may handle the sentinel differently — check the
rule you actually deploy.

The behavior is described here because the mock is what the examples, scripts and tests in this repository use, and because integrators copy it.

`RuleWhitelistMock` treats the zero address as an ordinary participant:

```solidity
if (!addressIsListed(from)) { return CODE_ADDRESS_FROM_NOT_WHITELISTED; }
```

Because the mint pre-check passes `address(0)` as `from`, **an issuer who whitelists only real holders cannot mint at all** — every mint is refused with `CODE_ADDRESS_FROM_NOT_WHITELISTED`. Whitelist `address(0)` explicitly to permit issuance.

Pinned by `testMintIsBlockedWhenZeroAddressNotListed`, recorded as finding `F-2`.

### 4.3 One engine shared by several tokens is not neutral

The ERC-3643 callbacks **do not pass the token address to the rules**, so a stateful rule that keeps
per-address accounting mixes state across every bound token. 

- Only bind tokens that are equally trusted and governed together. 
- Unbinding does not retroactively separate state already accumulated in a rule.

This matters more here than for CMTAT, because `bindTokens` makes multi-token binding a one-call operation.

### 4.4 The rule set is iterated on every operation

O(number of rules) on every transfer, mint, burn and view call, capped by `maxRules` (default **10**). 

A gas-heavy rule affects every operation on every bound token.

### 4.5 Only bound tokens may call the callbacks

`transferred`, `created` and `destroyed` all revert with
`TokenBinding_UnauthorizedCaller` for any caller that is not a bound token. Verified by
`testUnboundCallerCannotCallTransferred` and `testUnboundCallerCannotCallCreatedOrDestroyed`.

The gate compares the raw `msg.sender`, not the ERC-2771 `_msgSender()`, and so does the token self-binding
check that `setCompliance` relies on. A trusted forwarder therefore cannot pass as a bound token, and it cannot
unbind a token approved for self-binding by claiming to be it. Both were possible up to v3.0.0-rc6. A T-REX token
calls `transferred` / `created` / `destroyed` and `bindToken` / `unbindToken(this)` directly, so it is unaffected.
See [RuleEngine-with-CMTAT.md §4.7](./RuleEngine-with-CMTAT.md#47-the-trusted-forwarder-cannot-act-as-a-token).

### 4.6 Restriction codes must be unique across the rule set

As with CMTAT: the engine returns the first non-zero code, so overlapping codes across rules produce inconsistent operator feedback unless they share the same message.

### 4.7 ERC-7551 support is a draft subset

`IERC7551Compliance` comes from `draft-IERC7551` and is not final. This project implements a subset focused on
`canTransferFrom`. Do not assume full ERC-7551 conformance.

### 4.8 The real T-REX token is tested in a separate Foundry profile

The vendored token (`lib/ERC-3643`, T-REX **4.2.0-beta1**) pins `pragma solidity 0.8.30` exactly, while this
project compiles with **0.8.37**, and it imports the `@onchain-id/solidity` npm package, which is not a
submodule. The suite that deploys it therefore runs in its own profile:

```bash
FOUNDRY_PROFILE=erc3643 forge test
```

- `[profile.erc3643]` in `foundry.toml` builds the whole project at solc 0.8.30 (the engine is `^0.8.20`,
  CMTAT and OpenZeppelin `^0.8.24` at most) into `out-erc3643/`, and runs only `test/ERC3643Real/`.
- The default profile lists `test/ERC3643Real/**` in `skip`, so a plain `forge test` is unaffected.
- `test/utils/onchainid/` holds minimal `IIdentity` / `IClaimIssuer` stubs, wired in by a **context-scoped**
  remapping (`lib/ERC-3643/:@onchain-id/solidity/contracts/=...`) that applies to the ERC-3643 sources only.
  It is declared in the profile, not in `remappings.txt`: `hardhat-foundry` reads `forge remappings` and
  rejects context-scoped lines.
- T-REX 4.2.0-beta1 uses OpenZeppelin 5, so no second OpenZeppelin major is needed (4.1.3 required 4.8.x).
- The identity registry is `IdentityRegistryStub`, which answers `isVerified` from a test flag, so every
  rejection observed comes from the engine.

`test/RuleEngine/ERC3643TokenIntegration.t.sol` keeps driving `ERC3643TokenMock` in the default profile, so the
compliance surface is also covered by the ordinary `forge test` and by coverage.

### 4.9 Compliance is notified after the state change

The reference `Token.sol` updates balances first and notifies compliance afterwards: `_transfer` then
`transferred`, `_mint` then `created`, `_burn` then `destroyed`. A rule that reads `totalSupply()` or
`balanceOf()` from inside the callback therefore sees the amount **already applied**, whereas CMTAT calls the
engine **before** the update. A supply or balance cap written for CMTAT (current value + amount ≤ cap) counts the
amount twice on an ERC-3643 token and rejects operations that should pass.

Use the ERC-3643 variants of such rules where the Rules repository provides them
(`RuleMaxTotalSupplyERC3643`, `RuleChainlinkPoRERC3643`), and check each rule's documentation for ERC-3643
support before binding an engine to a T-REX token. The pre-check `canTransfer` runs before the update, so it
does not show the problem. Pinned against the real token by `testComplianceIsNotifiedAfterTheMint`: a
CMTAT-style cap of 100 accepts the pre-check of a 100-token mint, then rejects it in `created`.

## 5. What is tested

| Area | File | Tests |
|---|---|---|
| Compliance module, RBAC variant | `RuleEngine/ERC3643Compliance.t.sol` | 30 |
| Compliance module, ownable variant | `RuleEngineOwnable/ERC3643Compliance.t.sol` | 29 |
| End-to-end with an ERC-3643 style token | `RuleEngine/ERC3643TokenIntegration.t.sol` | 11 |
| End-to-end with the real T-REX 4.2.0-beta1 token (`FOUNDRY_PROFILE=erc3643`) | `ERC3643Real/ERC3643RealTokenRuleEngine.t.sol` | 13 |

**83 ERC-3643-specific tests** (70 in the default profile, 13 in the `erc3643` profile). The `RuleEngineOwnable2Step` suite exercises the same compliance surface again
through its own variant.

The end-to-end suite covers, using a token that drives the engine exactly as `Token.sol` does:

- `setCompliance` binding the token, and unbinding a previous engine on migration
- `setCompliance` reverting without self-binding approval
- transfers accepted and rejected through the whitelist rule, via `transferred`
- mint through `created` and burn through `destroyed`
- `transferred` / `created` / `destroyed` rejecting unbound callers
- the two documented limitations above (`H-1` fail-open, `F-2` zero-address whitelist), pinned so a change in
  behaviour is noticed

The real-token suite (`test/ERC3643Real/`) checks the same surface against the genuine `Token`, plus what the
mock cannot show:

- `init` self-binding the token through `setCompliance`, and reverting without self-binding approval
- mint pre-checked with `canTransfer(address(0), ...)` then notified through `created`, forwarded to the rules
  as the 3-argument `transferred(address(0), to, value)`; burn through `destroyed`
- `transfer` and `transferFrom` both reaching the 3-argument `transferred` — the spender is never forwarded
- `forcedTransfer` notifying compliance, so a rule can block it (unlike CMTAT, whose `forcedTransfer` bypasses
  the engine)
- the post-update notification order of section 4.9

## 6. Related documents

- [RuleEngine-with-CMTAT.md](./RuleEngine-with-CMTAT.md) — the CMTAT counterpart
- [TokenBinding-module.md](./TokenBinding-module.md) — the standard-agnostic binding registry underneath
- [../README.md](../README.md) — full interface and API reference
- [CLAUDE_ANALYSIS.md](../security/audits/tools/v3.0.0-rc5/CLAUDE_ANALYSIS.md) — code-quality review, findings `H-1` and `F-2`
- Production rules: [github.com/CMTA/Rules](https://github.com/CMTA/Rules)
