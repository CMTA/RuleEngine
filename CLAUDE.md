# CLAUDE.md — AI Agent Guide for RuleEngine

This file helps AI agents (Cursor, Claude Code, etc.) understand and work with this codebase.

## Project Summary

**RuleEngine** is a Solidity smart contract system that enforces transfer restrictions for [CMTAT](https://github.com/CMTA/CMTAT) and [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643) tokens. It acts as an external controller that calls pluggable rule contracts on each token transfer, mint, or burn.

- **Version:** 3.0.0 (defined in `src/modules/VersionModule.sol`)
- **Solidity:** ^0.8.20 (compiled with 0.8.33)
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

## Import Remappings

| Alias | Path |
|-------|------|
| `OZ/` | `lib/openzeppelin-contracts/contracts` |
| `CMTAT/` | `lib/CMTAT/contracts/` |
| `CMTATv3.0.0/` | `lib/CMTATv3.0.0/contracts/` |
| `@openzeppelin/contracts/` | `lib/openzeppelin-contracts/contracts` |

Use `OZ/` for OpenZeppelin imports, `CMTAT/` for CMTAT imports, `src/` for local imports.

## Architecture

### Two Deployable Contracts

```
RuleEngine         — RBAC via AccessControl (multi-operator)
RuleEngineOwnable  — ERC-173 Ownable (single-owner)
```

Both share 100% of their core logic through `RuleEngineBase`.

### Inheritance Hierarchy

```
RuleEngineBase (abstract)
├── VersionModule                         → version() returns "3.0.0"
├── RulesManagementModule                 → add/remove/set/clear rules
│   ├── AccessControl (OZ)
│   └── RulesManagementModuleInvariantStorage  → errors, events, roles
├── ERC3643ComplianceModule               → bind/unbind tokens
│   └── IERC3643Compliance
├── RuleEngineInvariantStorage            → errors
└── IRuleEngineERC1404                    → CMTAT interface

RuleEngine
├── ERC2771ModuleStandalone → gasless support
└── RuleEngineBase

RuleEngineOwnable
├── ERC2771ModuleStandalone → gasless support
├── RuleEngineBase
└── Ownable (OZ) → ERC-173
```

### Access Control Pattern

Modules define **virtual internal hooks** for access control. Concrete contracts override them:

```solidity
// In RulesManagementModule (abstract):
function _onlyRulesManager() internal virtual;

// In ERC3643ComplianceModule (abstract):
function _onlyComplianceManager() internal virtual;

// RuleEngine overrides with RBAC:
function _onlyRulesManager() internal virtual override onlyRole(RULES_MANAGEMENT_ROLE) {}
function _onlyComplianceManager() internal virtual override onlyRole(COMPLIANCE_MANAGER_ROLE) {}

// RuleEngineOwnable overrides with Ownable:
function _onlyRulesManager() internal virtual override onlyOwner {}
function _onlyComplianceManager() internal virtual override onlyOwner {}
```

**When adding a new protected function**, follow this pattern: define a virtual hook in the module, then override it in both `RuleEngine` and `RuleEngineOwnable`.

### `_checkRule` Override Chain

Rule validation uses a two-layer override:

1. **`RulesManagementModule._checkRule()`** — checks zero address + duplicates
2. **`RuleEngineBase._checkRule()`** — calls `super._checkRule()` then validates ERC-165 interface

```solidity
// RulesManagementModule (generic checks):
function _checkRule(address rule_) internal view virtual {
    if (rule_ == address(0x0)) revert ...ZeroNotAllowed();
    if (_rules.contains(rule_)) revert ...AlreadyExists();
}

// RuleEngineBase (adds ERC-165 check):
function _checkRule(address rule_) internal view virtual override {
    super._checkRule(rule_);
    if (!ERC165Checker.supportsInterface(rule_, RuleInterfaceId.IRULE_INTERFACE_ID))
        revert RuleEngine_RuleInvalidInterface();
}
```

### Rule Execution Flow

```
Token.transfer() → RuleEngine.transferred(from, to, value)
                    ├── onlyBoundToken modifier (caller must be bound)
                    └── for each rule in _rules:
                          rule.transferred(from, to, value)  // reverts if disallowed
```

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
├── RuleEngine.sol                 # RBAC variant (deploy this)
├── RuleEngineOwnable.sol          # Ownable variant (deploy this)
├── RuleEngineBase.sol             # Abstract core logic (do not deploy)
├── interfaces/                    # IRule, IRulesManagementModule, IERC3643Compliance
├── modules/                       # VersionModule, RulesManagementModule, ERC3643ComplianceModule, ERC2771ModuleStandalone
│   └── library/                   # InvariantStorage contracts, RuleInterfaceId
└── mocks/                         # Test-only contracts (RuleWhitelist, RuleConditionalTransferLight, etc.)

test/
├── HelperContract.sol             # Base helper for RuleEngine tests
├── HelperContractOwnable.sol      # Base helper for RuleEngineOwnable tests
├── utils/                         # CMTAT deployment helpers
├── RuleEngine/                    # Tests for RuleEngine (RBAC)
├── RuleEngineOwnable/             # Tests for RuleEngineOwnable
└── RuleWhitelist/                 # Tests for the whitelist mock rule

script/                            # Foundry deployment scripts
```

## Test Conventions

For detailed test conventions, templates, helper contracts, test addresses, naming patterns, and the base test pattern, see the **testing skill**: `.claude/skills/testing/SKILL.md`.

Key points:
- Tests for `RuleEngine` go in `test/RuleEngine/`, tests for `RuleEngineOwnable` go in `test/RuleEngineOwnable/`
- Use `HelperContract` for RBAC tests, `HelperContractOwnable` for Ownable tests
- Always use specific error selectors in `vm.expectRevert()`
- When adding a feature to `RuleEngineBase`, add tests for **both** variants

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
7. **Rule contracts are in `src/mocks/`** — they are reference implementations for testing, not production rules. Production rules live in a [separate repository](https://github.com/CMTA/Rules).

## Solidity Style

- Follow the [Solidity style guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- NatSpec comments on all public/external functions
- Function ordering: constructor, receive, fallback, external, public, internal, private (view/pure last within each group)
- Function declaration order: visibility, mutability, virtual, override, custom modifiers
- Section headers: `/* ============ SECTION ============ */`
- Run `forge fmt` before committing

## Common Tasks

### Adding a new module
1. Create the module in `src/modules/`
2. Create an invariant storage contract in `src/modules/library/` for errors/events
3. Add a virtual access control hook (e.g., `_onlyNewManager()`)
4. Have `RuleEngineBase` inherit the module
5. Override the hook in both `RuleEngine` and `RuleEngineOwnable`
6. Add tests in both `test/RuleEngine/` and `test/RuleEngineOwnable/`

### Adding a new rule (mock)
1. Create the rule in `src/mocks/rules/`
2. Implement `IRule` (which extends `IRuleEngineERC1404`)
3. Implement ERC-165 with `IRULE_INTERFACE_ID`
4. Add tests using the existing `HelperContract` base

### Modifying access control
1. Update the virtual hook in the relevant module
2. Update overrides in **both** `RuleEngine.sol` and `RuleEngineOwnable.sol`
3. Update tests in **both** test directories
