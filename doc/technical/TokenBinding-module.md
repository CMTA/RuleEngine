# The token binding module

`TokenBindingModule` is the allowlist of token contracts allowed to call back into an engine. It is
deliberately kept **standard-agnostic**: it contains no rule, ERC-1404 or ERC-3643 logic, and depends
on nothing but OpenZeppelin. Any project that has to bind tokens — a compliance engine, a document
engine, a transfer engine — can embed it as-is; the RuleEngine is one consumer among possible others.

For how the RuleEngine uses it as an ERC-3643 compliance contract, see
[RuleEngine-with-ERC3643.md](./RuleEngine-with-ERC3643.md).

## 1. Layering

```
TokenBindingModule                  — registry: storage, bind/unbind/isTokenBound, onlyBoundToken
└── TokenBindingExtendedModule      — batch bind/unbind, token self-binding, getTokenBounds

ERC3643ComplianceModule             — ERC-3643 adapter: getTokenBound(), compliance manager naming
└── ERC3643ComplianceExtendedModule — ERC-3643 flavour of the extended registry
```

Everything ERC-3643 specific lives in the two right-hand contracts, and they are thin:

| Concern | Where |
|---|---|
| Bound token set, `bindToken` / `unbindToken` / `isTokenBound`, `TokenBound` / `TokenUnbound`, `onlyBoundToken` | `TokenBindingModule` |
| Batch binding, self-binding approval, `getTokenBounds()` | `TokenBindingExtendedModule` |
| `getTokenBound()` (single-token ERC-3643 view), compliance manager naming | `ERC3643ComplianceModule` |
| `transferred` / `created` / `destroyed` | `RuleEngineBase` (they depend on the rules, not on the binding) |

Interfaces follow the same split: [`ITokenBinding`](../../src/interfaces/ITokenBinding.sol) and
[`ITokenBindingExtended`](../../src/interfaces/ITokenBindingExtended.sol) are standard-agnostic;
[`IERC3643Compliance`](../../src/interfaces/IERC3643Compliance.sol) and
[`IERC3643ComplianceExtended`](../../src/interfaces/IERC3643ComplianceExtended.sol) extend them with the
ERC-3643 parts. The advertised ERC-165 interface IDs are unchanged by this split, since the function
sets are the same.

## 2. What the module provides

```solidity
function bindToken(address token) public virtual;          // authorized by _authorizeTokenBindingChange
function unbindToken(address token) public virtual;        // authorized by _authorizeTokenBindingChange
function isTokenBound(address token) public view virtual returns (bool);

modifier onlyBoundToken();                                 // guards the bound-token entry points
modifier onlyTokenBindingManager();                        // guards binding administration
```

Errors, in [`TokenBindingModuleInvariantStorage`](../../src/modules/library/TokenBindingModuleInvariantStorage.sol):
`TokenBinding_InvalidTokenAddress`, `TokenBinding_TokenAlreadyBound`, `TokenBinding_TokenNotBound`,
`TokenBinding_UnauthorizedCaller`.

Bound tokens are stored in an OpenZeppelin `EnumerableSet.AddressSet`, so add, remove and lookup are
O(1) and the set is enumerable. `_bindToken` and `_unbindToken` rely on the set mutation return value,
which keeps the `TokenAlreadyBound` / `TokenNotBound` diagnostics without a second lookup.

## 3. Reusing it in another project

Two hooks are left to the embedding contract:

| Hook | Purpose | Default |
|---|---|---|
| `_onlyTokenBindingManager()` | access control for binding administration | abstract, must be implemented |
| `_authorizeTokenBindingChange(address token)` | authorizes one bind/unbind | manager check |

A minimal deployment therefore only has to wire its access control model:

```solidity
contract MyEngine is TokenBindingModule, Ownable {
    constructor(address owner_) Ownable(owner_) {}

    // A bound-token entry point: only a bound token may call it.
    function notify() public onlyBoundToken { /* ... */ }

    function _onlyTokenBindingManager() internal virtual override onlyOwner {}
}
```

That is exactly [`TokenBindingStandaloneMock`](../../src/mocks/TokenBindingStandaloneMock.sol), the
reference implementation used by `test/TokenBinding/TokenBindingStandalone.t.sol` to pin that the
registry works with no compliance code around it. Like every contract under `src/mocks/`, it is a
reference for testing and examples, not a production contract.

Embedding `TokenBindingExtendedModule` instead adds batch operations and self-binding: a token whose
self-binding has been approved may call `bindToken(address(this))` itself, which is what ERC-3643
`setCompliance` needs. Self-binding is opt-in per token; without approval, only the binding manager can
bind. When both an extended module and another parent bring in the binding authorization hook — as in
`ERC3643ComplianceExtendedModule` — Solidity requires the most derived contract to resolve it
explicitly, which it does by delegating to `TokenBindingExtendedModule`.

To rename the manager in the vocabulary of your own domain, do what `ERC3643ComplianceModule` does:
declare your own abstract hook and wire the generic one to it.

```solidity
function _onlyTokenBindingManager() internal virtual override {
    _onlyComplianceManager();
}

function _onlyComplianceManager() internal virtual;
```

## 4. Operational warnings

These are properties of the registry itself, not of any standard built on it.

- **Multi-tenant binding shares state.** Every bound token drives the same downstream logic. For the
  RuleEngine, stateful rules keep per-address accounting that is shared across all bound tokens, and the
  ERC-3643 callbacks do not carry the calling token address to the rules, so binding tokens from
  different issuers silently cross-contaminates their accounting. Only bind tokens that are equally
  trusted and governed together.
- **Unbinding is administrative.** It stops future calls; it does not erase state already accumulated
  while the token was bound.
- **`address(0)` cannot be bound.** It could never call the engine, and binding it would only emit a
  `TokenBound` event that indexers would have to filter out.
- **Token identity uses `msg.sender`, administration uses `_msgSender()`.** `onlyBoundToken` and the token
  self-binding check compare the raw `msg.sender`. A token never calls through a forwarder, so in a host that
  inherits `ERC2771Context` the forwarder cannot pass as a bound or self-binding token. The manager path
  (`_onlyTokenBindingManager`) is left to the host and normally resolves through `_msgSender()`, so binding
  administration can stay gasless. Do not override `_checkBoundToken` back to `_msgSender()`.
- **Binding and unbinding are not idempotent.** Re-binding a bound token reverts with
  `TokenBinding_TokenAlreadyBound`, and unbinding an unbound one with `TokenBinding_TokenNotBound`, so a
  redundant administrative call is reported rather than silently accepted.
- **An administrative unbind revokes the self-binding approval.** When the binding manager unbinds a token
  (`unbindToken` or `unbindTokens`), `TokenBindingExtendedModule._unbindToken` also clears the token's
  self-binding approval and emits `TokenSelfBindingApprovalSet(token, false)`, so the token cannot undo the
  manager's decision by binding itself again. A token that unbinds itself (`msg.sender == token`) keeps its
  approval. A host that combines this module with another one defining `_unbindToken` must disambiguate the
  override in favour of `TokenBindingExtendedModule`, as `ERC3643ComplianceExtendedModule` does.
- **Self-binding approvals have two events; indexers must handle both.** `setTokenSelfBindingApproval` emits
  `TokenSelfBindingApprovalSet(address indexed token, bool approved)`; `setTokenSelfBindingApprovalBatch` emits
  a single `TokenSelfBindingApprovalBatchSet(address[] tokens, bool approved)` with the array as passed, and no
  per-token event. A log filter on the indexed `token` therefore misses batch updates, and the batch array also
  lists tokens that were already at the requested value, and duplicates. Monitoring that must catch every token
  gaining self-binding rights (which lets it unbind itself) subscribes to both events, or reads
  `isTokenSelfBindingApproved(token)`, which is authoritative. Kept as is by decision; the alternatives
  (per-token events, with or without a change check) are measured in the rc7 code-quality review, `C-2`.
- **The batch functions are atomic, on purpose.** `bindTokens` / `unbindTokens` apply the single-call rule to
  every element: one token already bound (or listed twice) in `bindTokens`, or not bound in `unbindTokens`,
  reverts the whole call, and the tokens processed before it in the same call are rolled back. This departs
  from the batch convention used elsewhere in the project (the reference `RuleAddressList` rule skips elements
  already in the target state so that one stale entry does not waste the whole batch). Binding is treated
  differently because a binding change is security-relevant: a token that is already bound in the list is most
  likely an operator mistake (wrong list, wrong environment), and it should stop the operation rather than be
  silently skipped. The cost is that the operator re-submits a corrected list. An empty array is accepted as a
  no-op, consistent with the batch rule (nothing to change, nothing reverts).

## 5. What is tested

| Area | File | Tests |
|---|---|---|
| Standalone reuse, outside any compliance context | `test/TokenBinding/TokenBindingStandalone.t.sol` | 10 |
| Registry through the ERC-3643 surface, RBAC variant | `test/RuleEngine/ERC3643Compliance.t.sol` | 31 |
| Registry through the ERC-3643 surface, ownable variant | `test/RuleEngineOwnable/ERC3643Compliance.t.sol` | 30 |

## 6. Related documents

- [RuleEngine-with-ERC3643.md](./RuleEngine-with-ERC3643.md) — the ERC-3643 integration
- [RuleEngine-with-CMTAT.md](./RuleEngine-with-CMTAT.md) — the CMTAT integration
- [../README.md](../README.md) — full interface and API reference
