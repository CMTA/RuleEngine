---
name: testing
description: Instructions for writing and organizing Foundry tests in the RuleEngine project
---

This file provides project-specific test conventions, organization, and patterns for the RuleEngine codebase. For generic Foundry test cheatcodes, assertions, and deployment scripts, see the `foundry` skill.

## Test Directory Structure

```
test/
├── HelperContract.sol             # Base helper for RuleEngine (RBAC) tests
├── HelperContractOwnable.sol      # Base helper for RuleEngineOwnable tests
├── utils/
│   ├── CMTATDeployment.sol        # CMTAT deployment helper
│   └── CMTATDeploymentV3.sol      # CMTAT v3 deployment helper
├── RuleEngine/                    # Tests for RuleEngine (RBAC variant)
│   ├── AccessControl/
│   ├── RulesManagementModuleTest/
│   ├── ruleEngineValidation/
│   ├── RuleEngineDeployment.t.sol
│   ├── RuleEngineCoverage.t.sol
│   ├── ERC3643Compliance.t.sol
│   └── IRuleInterfaceId.t.sol
├── RuleEngineOwnable/             # Tests for RuleEngineOwnable (ERC-173 variant)
│   ├── AccessControl/
│   ├── RulesManagementModuleTest/
│   ├── RuleEngineOwnableDeployment.t.sol
│   ├── RuleEngineOwnableCoverage.t.sol
│   └── ERC3643Compliance.t.sol
└── RuleWhitelist/                 # Tests for the whitelist mock rule
    ├── AccessControl/
    ├── RuleWhitelist.t.sol
    └── CMTATIntegration.t.sol
```

### Organization Rules

- Tests for `RuleEngine` go in `test/RuleEngine/`
- Tests for `RuleEngineOwnable` go in `test/RuleEngineOwnable/`
- Shared test logic uses `*Base.sol` abstract contracts with virtual hooks
- Test files use `.t.sol` suffix; base/helper files use `.sol`
- **Both variants must be tested.** When adding a feature to `RuleEngineBase`, add tests in both `test/RuleEngine/` and `test/RuleEngineOwnable/`.

## Helper Contracts

### HelperContract (for RuleEngine tests)

```solidity
import "./HelperContract.sol";

contract MyTest is Test, HelperContract {
    // ...
}
```

- Inherits all invariant storage contracts (gives access to error `.selector` values)
- Admin address: `DEFAULT_ADMIN_ADDRESS = address(1)`
- Instantiates: `ruleEngineMock` (`RuleEngine`), `ruleWhitelist`, `ruleConditionalTransferLight`
- Provides result variables: `resUint256`, `resUint8`, `resBool`, `resString`, `resAddr`

### HelperContractOwnable (for RuleEngineOwnable tests)

```solidity
import "../HelperContractOwnable.sol";

contract MyOwnableTest is Test, HelperContractOwnable {
    // ...
}
```

- Same structure as `HelperContract` but for the Ownable variant
- Owner address: `OWNER_ADDRESS = address(1)`
- Instantiates: `ruleEngineMock` (`RuleEngineOwnable`)
- Additional address: `NEW_OWNER_ADDRESS = address(8)` for ownership transfer tests

## Test Addresses

| Name | Address | Purpose |
|------|---------|---------|
| `DEFAULT_ADMIN_ADDRESS` / `OWNER_ADDRESS` | `address(1)` | Admin/owner for RuleEngine / RuleEngineOwnable |
| `WHITELIST_OPERATOR_ADDRESS` | `address(2)` | Whitelist rule operator |
| `RULE_ENGINE_OPERATOR_ADDRESS` | `address(3)` | RuleEngine operator |
| `ATTACKER` | `address(4)` | Unauthorized caller |
| `ADDRESS1` | `address(5)` | Test user 1 |
| `ADDRESS2` | `address(6)` | Test user 2 |
| `ADDRESS3` | `address(7)` | Test user 3 |
| `NEW_OWNER_ADDRESS` | `address(8)` | Ownership transfer target (Ownable only) |
| `CONDITIONAL_TRANSFER_OPERATOR_ADDRESS` | `address(9)` | Conditional transfer operator |

## Naming Conventions

Test function names use camelCase with `test` prefix:

```
testCan<Action>()                 — positive test (should succeed)
testCannot<Action>()              — negative test (expects revert)
testCannotAddEOAAsRule()          — specific error case
testSupportsRuleEngineInterface() — ERC-165 interface check
```

Examples from the codebase:
- `testCanSetRules()` — setting rules succeeds
- `testCannotSetRuleIfARuleIsAlreadyPresent()` — duplicate rule reverts
- `testCannotSetEmptyRulesT1WithEmptyTab()` — edge case with variant identifier
- `testMsgDataReturnsCalldata()` — coverage test for internal function

## Revert Testing

**Always use specific error selectors**, never bare `vm.expectRevert()`:

```solidity
// Good — specific error selector
vm.expectRevert(RuleEngine_RuleInvalidInterface.selector);
ruleEngineMock.addRule(IRule(address(0x999)));

// Bad — matches any revert
vm.expectRevert();
ruleEngineMock.addRule(IRule(address(0x999)));
```

Error selectors are available because test helpers inherit the invariant storage contracts (`RuleEngineInvariantStorage`, `RulesManagementModuleInvariantStorage`, etc.).

## Base Test Pattern (Shared Logic)

For functionality shared across `RuleEngine` and `RuleEngineOwnable`, use abstract base contracts with virtual hooks:

```solidity
// Base contract defines shared tests + virtual hook
abstract contract CMTATIntegrationBase is Test, HelperContract {
    function _deployCMTAT() internal virtual;

    function setUp() public {
        _deployCMTAT();
        // shared setup: deploy RuleEngine, bind token, add rules, etc.
    }

    function testCanTransferWithWhitelist() public {
        // shared test logic
    }
}

// Concrete test implements the hook
contract CMTATIntegration is CMTATIntegrationBase {
    function _deployCMTAT() internal override {
        // deploy specific CMTAT version
    }
}

// Another concrete test for a different CMTAT version
contract CMTATIntegrationV3 is CMTATIntegrationBase {
    function _deployCMTAT() internal override {
        // deploy CMTAT v3
    }
}
```

This pattern is used for:
- `CMTATIntegrationBase` — CMTAT integration tests across CMTAT versions
- `RuleEngineOperationRevertBase` — revert scenario tests

## Test Template: RuleEngine (RBAC)

```solidity
//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";

contract MyFeatureTest is Test, HelperContract {
    RuleEngine ruleEngineMock;
    RuleWhitelist ruleWhitelist;

    function setUp() public {
        ruleWhitelist = new RuleWhitelist(DEFAULT_ADMIN_ADDRESS, ZERO_ADDRESS);
        ruleEngineMock = new RuleEngine(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS,  // forwarder
            ZERO_ADDRESS   // token (bound later)
        );
    }

    function testCanDoSomething() public {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleEngineMock.addRule(IRule(address(ruleWhitelist)));
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotDoSomethingUnauthorized() public {
        vm.prank(ATTACKER);
        vm.expectRevert();  // AccessControl revert
        ruleEngineMock.addRule(IRule(address(ruleWhitelist)));
    }
}
```

## Test Template: RuleEngineOwnable

```solidity
//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContractOwnable.sol";

contract MyFeatureOwnableTest is Test, HelperContractOwnable {
    RuleEngineOwnable ruleEngineMock;
    RuleWhitelist ruleWhitelist;

    function setUp() public {
        ruleWhitelist = new RuleWhitelist(OWNER_ADDRESS, ZERO_ADDRESS);
        ruleEngineMock = new RuleEngineOwnable(
            OWNER_ADDRESS,
            ZERO_ADDRESS,  // forwarder
            ZERO_ADDRESS   // token
        );
    }

    function testCanDoSomething() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(IRule(address(ruleWhitelist)));
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotDoSomethingUnauthorized() public {
        vm.prank(ATTACKER);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", ATTACKER));
        ruleEngineMock.addRule(IRule(address(ruleWhitelist)));
    }
}
```

## Coverage Tests

Coverage tests live in `RuleEngineCoverage.t.sol` / `RuleEngineOwnableCoverage.t.sol` and target hard-to-reach code paths:

- `supportsInterface()` for all supported interface IDs
- `_msgData()` via exposed mock contracts (`RuleEngineExposed`, `RuleEngineOwnableExposed`)
- AccessControl fallback paths in `supportsInterface`
- ERC-165 rejection of invalid rules (EOA, wrong interface)

Exposed mock contracts are in `src/mocks/RuleEngineExposed.sol` and expose internal functions for testing.

## Running Tests

```bash
forge test                                    # All tests
forge test --match-contract RuleEngineCoverage  # Specific test contract
forge test --match-test testCanSetRules         # Specific test function
forge test -vvv                                 # Verbose (shows revert reasons)
forge test --gas-report                         # Gas usage report
forge coverage                                  # Code coverage
```
