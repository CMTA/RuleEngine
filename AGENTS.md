# AI Agent Guide for RuleEngine

This file helps AI agents (Cursor, Claude Code, etc.) understand and work with this codebase.

AGENTS.md and CLAUDE.md files must always be identical — always update both together.

## Project Summary

**RuleEngine** is a Solidity smart contract system that enforces transfer restrictions for [CMTAT](https://github.com/CMTA/CMTAT) and [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643) tokens. It acts as an external controller that calls pluggable rule contracts on each token transfer, mint, or burn.

- **Version:** 3.0.0 (defined in `src/modules/VersionModule.sol`)
- **Solidity:** ^0.8.20 (compiled with 0.8.36)
- **EVM target:** Prague
- **License:** MPL-2.0

## Build & Test Commands

```bash
forge build              # Compile all contracts
forge test               # Run all tests
forge test -vvv          # Verbose test output
forge test --match-contract <Name> --match-test <fn>  # Run specific test
forge coverage           # Code coverage
forge coverage --no-match-coverage "(script|mocks|test)" --report lcov  # Production coverage
forge fmt                # Format code
```

Dependencies are git submodules. Initialize with `forge install`, update with `forge update`.
CMTAT submodule also needs `cd lib/CMTAT && npm install` for its OpenZeppelin deps.

## Agent Workflow

- **Never create git commits.** Provide commit messages only when they are requested.
- **Always run the full test suite (`forge test`) after any code modification** — including lint-driven or mechanical refactors — before reporting completion.
- **Always update the documentation** to reflect the latest change. There are two READMEs: `README.md` at the root is the short overview (project, architecture, main files, quick start); `doc/README.md` is the full reference (interfaces, Ethereum API, deployment, UML, audits). Update whichever the change affects — often both.
- After each implemented feature or fix, provide a **one-line GitHub commit message** covering all changes since the last commit.

### When implementing a new rule or feature

1. Create or update the technical documentation in `doc/technical`
2. Update `README.md` (root overview) and `doc/README.md` (full reference) as applicable
3. Create or update tests, targeting **100% code coverage** — check with `forge coverage --report summary`
4. Update `CHANGELOG.md`

## Import Remappings

| Alias | Path |
|-------|------|
| `CMTAT/` | `lib/CMTAT/contracts/` |
| `CMTATv3.0.0/` | `lib/CMTATv3.0.0/contracts/` |
| `@openzeppelin/contracts/` | `lib/openzeppelin-contracts/contracts` |

Use `@openzeppelin/contracts/` for OpenZeppelin imports, `CMTAT/` for CMTAT imports, `src/` for local imports.

## Architecture

### Three Deployable Contracts

```
RuleEngine              — RBAC via AccessControl (multi-operator)
RuleEngineOwnable       — ERC-173 Ownable (single-owner)
RuleEngineOwnable2Step  — ERC-173 Ownable2Step (single-owner, two-step handover)
```

All three share their core logic through `RuleEngineBase` directly or via `RuleEngineOwnableShared`.

### Inheritance Hierarchy

```
RuleEngineBase (abstract)
├── VersionModule                         → version() returns "3.0.0"
├── RulesManagementModule                 → add/remove/set/clear rules, maxRules cap
│   ├── AccessControl (OZ)
│   └── RulesManagementModuleInvariantStorage  → errors, events, roles
├── ERC3643ComplianceExtendedModule       → bind/unbind tokens (extended API)
│   └── ERC3643ComplianceModule           → core ERC-3643 compliance
│       ├── IERC3643Compliance
│       └── ERC3643ComplianceModuleInvariantStorage  → errors
├── RuleEngineInvariantStorage            → errors
└── IRuleEngineERC1404                    → CMTAT interface

RuleEngine
├── ERC2771ModuleStandalone → gasless support
└── RuleEngineBase

RuleEngineOwnable
├── ERC2771ModuleStandalone → gasless support
├── RuleEngineOwnableShared
│   └── RuleEngineBase
└── Ownable (OZ) → ERC-173

RuleEngineOwnable2Step
├── ERC2771ModuleStandalone → gasless support
├── RuleEngineOwnableShared
│   └── RuleEngineBase
└── Ownable2Step (OZ) → ERC-173
```

### Access Control Pattern

Modules define **virtual internal hooks** for access control. Concrete contracts override them:

```solidity
// In RulesManagementModule (abstract):
function _onlyRulesManager() internal virtual;
function _onlyRulesLimitManager() internal virtual;  // guards setMaxRules

// In ERC3643ComplianceModule (abstract):
function _onlyComplianceManager() internal virtual;

// RuleEngine overrides with RBAC:
function _onlyRulesManager() internal virtual override onlyRole(RULES_MANAGEMENT_ROLE) {}
function _onlyRulesLimitManager() internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {}
function _onlyComplianceManager() internal virtual override onlyRole(COMPLIANCE_MANAGER_ROLE) {}

// RuleEngineOwnable overrides with Ownable:
function _onlyRulesManager() internal virtual override onlyOwner {}
function _onlyRulesLimitManager() internal virtual override onlyOwner {}
function _onlyComplianceManager() internal virtual override onlyOwner {}
```

**When adding a new protected function**, follow this pattern: define a virtual hook in the module, then override it in `RuleEngine`, `RuleEngineOwnable`, and `RuleEngineOwnable2Step`.

### `_checkRule` Override Chain

Rule validation uses a two-layer override:

1. **`RulesManagementModule._checkRule()`** — checks zero address + duplicates
2. **`RuleEngineBase._checkRule()`** — calls `RulesManagementModule._checkRule()` then validates ERC-165 interface

```solidity
// RulesManagementModule (generic checks):
function _checkRule(address rule_) internal view virtual {
    if (rule_ == address(0x0)) revert ...ZeroNotAllowed();
    if (_rules.contains(rule_)) revert ...AlreadyExists();
}

// RuleEngineBase (adds ERC-165 check):
function _checkRule(address rule_) internal view virtual override {
    RulesManagementModule._checkRule(rule_);
    if (!ERC165Checker.supportsInterface(rule_, RuleInterfaceId.IRULE_INTERFACE_ID))
        revert RuleEngine_RuleInvalidInterface();
}
```

### Rule Execution Flow

```
Token operation → RuleEngine.transferred(spender, from, to, value)   ← transferFrom, mint, burn (spender = _msgSender())
                   ├── onlyBoundToken modifier (caller must be bound)
                   └── for each rule in _rules:
                         rule.transferred(spender, from, to, value)  // reverts if disallowed

                  RuleEngine.transferred(from, to, value)            ← standard transfer (spender == address(0))
                   ├── onlyBoundToken modifier
                   └── for each rule in _rules:
                         rule.transferred(from, to, value)

                  RuleEngine.created(to, value)                      ← ERC-3643 mint entry point
                   ├── onlyBoundToken modifier
                   └── calls _transferred(address(0), to, value)

                  RuleEngine.destroyed(from, value)                  ← ERC-3643 burn entry point
                   ├── onlyBoundToken modifier
                   └── calls _transferred(from, address(0), value)
```

CMTAT selects the overload in `ValidationModuleRuleEngine._callRuleEngineTransferred`, branching on `spender != address(0)`. A standard `transfer` passes `address(0)` as spender (`CMTATBaseCommon.transfer`) and therefore uses the **3-argument** overload; `transferFrom`, `mint` and `burn` pass `_msgSender()` and use the **4-argument** overload. Neither is a fallback — which one is called depends purely on the operation.

Since CMTAT v3.3.0, mint (`from == address(0)`) and burn (`to == address(0)`) therefore also reach the 4-argument overload with the operator as `spender`. Rules that check `spender` must skip or adapt that check for mint/burn to avoid blocking those operations unintentionally.

`created` and `destroyed` use the 3-argument `_transferred` path (no spender), consistent with the ERC-3643 spec which does not carry a spender for mint/burn.

View path: `detectTransferRestriction()` iterates rules, returns first non-zero code.

### Storage: EnumerableSet

Both rules and bound tokens use `EnumerableSet.AddressSet`:
- `_rules` in `RulesManagementModule` — the set of active rules
- `_boundTokens` in `ERC3643ComplianceModule` — tokens allowed to call `transferred`

This gives O(1) add/remove/contains and iterable storage.

## Key Interfaces

| Interface | Purpose | Where Defined |
|-----------|---------|---------------|
| `IRule` | What every rule must implement (extends `IRuleEngineERC1404`) | `src/interfaces/IRule.sol` |
| `IRulesManagementModule` | Rule CRUD operations | `src/interfaces/IRulesManagementModule.sol` |
| `IERC3643Compliance` | Token binding + compliance hooks | `src/interfaces/IERC3643Compliance.sol` |
| `IRuleEngine` | Full CMTAT integration interface | `lib/CMTAT/contracts/interfaces/engine/IRuleEngine.sol` |

**ERC-165 interface IDs:**
- `IRule`: `0x2497d6cb` (defined in `src/modules/library/RuleInterfaceId.sol`)
- `IRuleEngine`: from `CMTAT/library/RuleEngineInterfaceId.sol`
- `IERC1404Extend`: from `CMTAT/library/ERC1404ExtendInterfaceId.sol`
- `ERC-173`: `0x7f5828d0` (hardcoded in `RuleEngineOwnable`)

## Invariant Storage Pattern

Errors, events, and role constants are centralized in "invariant storage" abstract contracts:

| Contract | Contains |
|----------|----------|
| `RuleEngineInvariantStorage` | `RuleEngine_AdminWithAddressZeroNotAllowed`, `RuleEngine_RuleInvalidInterface` |
| `RulesManagementModuleInvariantStorage` | Rule errors, `AddRule`/`RemoveRule`/`ClearRules` events, `RULES_MANAGEMENT_ROLE` |

**Convention:** Error names follow `Contract_Module_ErrorName` pattern. Test contracts inherit these to access `.selector` for `vm.expectRevert`.

## Project Structure

```
src/
├── deployment/
│   ├── RuleEngine.sol             # RBAC variant (deploy this)
│   ├── RuleEngineOwnable.sol      # Ownable variant (deploy this)
│   └── RuleEngineOwnable2Step.sol # Ownable2Step variant (deploy this)
├── RuleEngineBase.sol             # Abstract core logic (do not deploy)
├── RuleEngineOwnableShared.sol    # Shared logic for ownable variants
├── interfaces/                    # IRule, IRulesManagementModule, IERC3643Compliance
├── modules/                       # VersionModule, RulesManagementModule, ERC3643ComplianceModule, ERC2771ModuleStandalone
│   └── library/                   # InvariantStorage contracts, RuleInterfaceId
└── mocks/                         # Test-only/reference contracts

test/
├── HelperContract.sol             # Base helper for RuleEngine tests
├── HelperContractOwnable.sol      # Base helper for RuleEngineOwnable tests
├── HelperContractOwnable2Step.sol # Base helper for RuleEngineOwnable2Step tests
├── utils/                         # CMTAT deployment helpers
├── RuleEngine/                    # Tests for RuleEngine (RBAC)
├── RuleEngineOwnable/             # Tests for RuleEngineOwnable
├── RuleEngineOwnable2Step/        # Tests for RuleEngineOwnable2Step
└── RuleWhitelist/                 # Tests for the whitelist mock rule

script/                            # Foundry example/deployment scripts
```

## Test Conventions

For detailed test conventions, templates, helper contracts, test addresses, naming patterns, and the base test pattern, see the **testing skill**: `.claude/skills/testing/SKILL.md`.

Key points:
- Tests for `RuleEngine` go in `test/RuleEngine/`, tests for `RuleEngineOwnable` go in `test/RuleEngineOwnable/`
- Tests for `RuleEngineOwnable2Step` go in `test/RuleEngineOwnable2Step/`
- Use `HelperContract` for RBAC tests, `HelperContractOwnable` for Ownable tests
- Use `HelperContractOwnable2Step` for `RuleEngineOwnable2Step` tests
- Always use specific error selectors in `vm.expectRevert()`
- When adding a feature to `RuleEngineBase`, add tests for **all deployable variants**

## RBAC Roles (RuleEngine only)

| Role | Identifier | Purpose |
|------|-----------|---------|
| `DEFAULT_ADMIN_ROLE` | `0x00...00` | Has all roles (via `hasRole` override) |
| `RULES_MANAGEMENT_ROLE` | `keccak256("RULES_MANAGEMENT_ROLE")` | Add/remove/set/clear rules |
| `COMPLIANCE_MANAGER_ROLE` | `keccak256("COMPLIANCE_MANAGER_ROLE")` | Bind/unbind tokens |

## Key Invariants

1. **Only bound tokens** can call `transferred()`, `created()`, `destroyed()`
2. **Rules are validated via ERC-165** before being added — they must support `IRULE_INTERFACE_ID`
3. **No duplicate rules** — `EnumerableSet` prevents this
4. **No zero-address rules** — checked in `_checkRule`
5. **Admin has all roles** in `RuleEngine` (the `hasRole` override)
6. **Forwarder is immutable** — set at construction, cannot be changed
7. **Rule contracts in `src/mocks/` are reference implementations** — they are useful for testing and examples, not as production rule contracts. Production rules live in a [separate repository](https://github.com/CMTA/Rules).

## Solidity Style

- Follow the [Solidity style guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- NatSpec comments on all public/external functions
- Function ordering: constructor, receive, fallback, external, public, internal, private (view/pure last within each group)
- Function declaration order: visibility, mutability, virtual, override, custom modifiers
- All `internal` functions must be marked `virtual`, so inheriting contracts can override them.
- Use `require(condition, CustomError(...))` for custom errors; avoid direct `revert CustomError(...)`.
- In `src/`, avoid `super` calls and prefer explicit parent-contract calls (e.g., `AccessControl.grantRole(...)`) for readability and deterministic inheritance behavior.
- Section headers: `/* ============ SECTION ============ */`
- **No emoji in code comments or NatSpec.** Use a plain word marker instead: `WARNING:`, `NOTE:`, `IMPORTANT:`. Emoji render inconsistently across editors, terminals, `forge doc` output and diffs; they are not searchable (`grep WARNING` finds the marker, `grep ⚠️` depends on the shell); and they encode as multi-byte sequences that can be silently mangled by tooling. This applies to `src/`, `test/` and `script/`. Markdown documentation may use emoji freely — the restriction is Solidity comments only.
- Run `forge fmt` before committing

## Common Tasks

### Adding a new module
1. Create the module in `src/modules/`
2. Create an invariant storage contract in `src/modules/library/` for errors/events
3. Add a virtual access control hook (e.g., `_onlyNewManager()`)
4. Have `RuleEngineBase` inherit the module
5. Override the hook in both `RuleEngine` and `RuleEngineOwnable`
6. Add tests in `test/RuleEngine/`, `test/RuleEngineOwnable/`, and `test/RuleEngineOwnable2Step/`

### Adding a new rule (mock)
1. Create the rule in `src/mocks/rules/`
2. Implement `IRule` (which extends `IRuleEngineERC1404`)
3. Implement ERC-165 with `IRULE_INTERFACE_ID`
4. Add tests using the existing `HelperContract` base

### Modifying access control
1. Update the virtual hook in the relevant module
2. Update overrides in **both** `RuleEngine.sol` and `RuleEngineOwnable.sol`
3. Update tests in all affected test directories
