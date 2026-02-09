---
name: foundry
description: Instructions for Foundry Development (test & deployment script)
---

This file provides instructions for Claude Code when working with Foundry tests and deployment scripts in this project.

## Project Context

This is a Foundry-based Solidity project for CMTAT. The main contracts are located in `lib/CMTAT/contracts/`.

## Writing Foundry Tests

### File Structure

- Place test files in `test/` directory
- Name test files with `.t.sol` suffix (e.g., `MyModule.t.sol`)
- Use `HelperContract.sol` as base for shared utilities

### Test Contract Template

```solidity
//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "./HelperContract.sol";

contract MyModuleTest is HelperContract {
    function setUp() public {
        _deployToken();
        // Additional setup
    }

    function test_DescriptiveName() public {
        // Test implementation
    }

    function test_RevertWhen_Condition() public {
        vm.expectRevert();
        // Call that should revert
    }
}
```

### Test Naming Conventions

- `test_` prefix for standard tests
- `test_RevertWhen_` prefix for tests expecting reverts
- `testFuzz_` prefix for fuzz tests
- Use descriptive names: `test_AdminCanMint`, `test_RevertWhen_NonOwnerCalls`

### Key Cheatcodes

```solidity
// Change msg.sender for next call
vm.prank(address);

// Change msg.sender for all subsequent calls
vm.startPrank(address);
vm.stopPrank();

// Expect a revert
vm.expectRevert();
vm.expectRevert(CustomError.selector);
vm.expectRevert("Error message");

// Expect an event
vm.expectEmit(true, true, false, true);
emit ExpectedEvent(param1, param2, param3);
actualCall();

// Manipulate block properties
vm.warp(timestamp);      // Set block.timestamp
vm.roll(blockNumber);    // Set block.number

// Deal ETH or tokens
deal(address, amount);
deal(tokenAddress, recipient, amount);

// Environment variables
vm.envOr("VAR_NAME", defaultValue);
vm.envString("VAR_NAME");
```

### Assertions

```solidity
assertEq(actual, expected);
assertEq(actual, expected, "Error message");
assertTrue(condition);
assertFalse(condition);
assertGt(a, b);      // a > b
assertGe(a, b);      // a >= b
assertLt(a, b);      // a < b
assertLe(a, b);      // a <= b
assertApproxEqAbs(a, b, maxDelta);
assertApproxEqRel(a, b, maxPercentDelta);
```

### Testing Events

```solidity
// Declare event (copy from contract or interface)
event Transfer(address indexed from, address indexed to, uint256 value);

function test_EmitsTransferEvent() public {
    vm.expectEmit(true, true, false, true);
    emit Transfer(from, to, amount);
    token.transfer(to, amount);
}
```

### Testing Access Control

```solidity
function test_RevertWhen_NonAdminCalls() public {
    vm.prank(USER1);  // USER1 is not admin
    vm.expectRevert();
    cmtat.adminOnlyFunction();
}

function test_AdminCanCall() public {
    vm.prank(ADMIN);
    cmtat.adminOnlyFunction();
    // Assert expected state changes
}
```

### Available Test Addresses (from HelperContract)

```solidity
address constant ZERO_ADDRESS = address(0);
address constant ADMIN = address(1);
address constant USER1 = address(2);
address constant USER2 = address(3);
address constant USER3 = address(4);
```

### Available Roles (from HelperContract)

```solidity
bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");
bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
```

## Writing Deployment Scripts

### File Structure

- Place scripts in `script/` directory
- Name script files with `.s.sol` suffix
- Use descriptive names: `DeployCMTATStandalone.s.sol`

### Deployment Script Template

```solidity
//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
// Import contracts to deploy

contract DeployMyContract is Script {
    function run() external returns (MyContract) {
        // Read config from environment
        address admin = vm.envOr("ADMIN_ADDRESS", msg.sender);

        vm.startBroadcast();

        MyContract deployed = new MyContract(admin);

        vm.stopBroadcast();

        return deployed;
    }
}
```

### Environment Variables for Scripts

```solidity
// With default fallback
address admin = vm.envOr("ADMIN_ADDRESS", msg.sender);
uint256 amount = vm.envOr("AMOUNT", uint256(1000));
string memory name = vm.envOr("TOKEN_NAME", "Default");

// Required (reverts if not set)
address required = vm.envAddress("REQUIRED_ADDRESS");
```

### Running Scripts

```bash
# Dry run (simulation)
forge script script/Deploy.s.sol

# With RPC (simulation on fork)
forge script script/Deploy.s.sol --rpc-url $RPC_URL

# Broadcast to network
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast

# With verification
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Multi-Chain Deployment

```solidity
function run() public {
    vm.createSelectFork("mainnet");
    vm.startBroadcast();
    new MyContract();
    vm.stopBroadcast();

    vm.createSelectFork("polygon");
    vm.startBroadcast();
    new MyContract();
    vm.stopBroadcast();
}
```

## Running Tests

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific contract
forge test --match-contract BurnModuleTest

# Run specific test
forge test --match-test test_AdminCanBurn

# Run with gas report
forge test --gas-report

# Run with coverage
forge coverage

# Watch mode
forge test --watch
```

## Project-Specific Notes

### CMTAT Constructor Parameters

When deploying CMTATStandalone, these structs are required:

```solidity
ICMTATConstructor.ERC20Attributes memory erc20Attributes = ICMTATConstructor.ERC20Attributes({
    name: "Token Name",
    symbol: "SYM",
    decimalsIrrevocable: 0
});

IERC1643CMTAT.DocumentInfo memory termsDoc = IERC1643CMTAT.DocumentInfo({
    name: "Terms",
    uri: "https://example.com/terms",
    documentHash: bytes32(0)
});

ICMTATConstructor.ExtraInformationAttributes memory extraInfoAttributes = ICMTATConstructor.ExtraInformationAttributes({
    tokenId: "TOKEN_ID",
    terms: termsDoc,
    information: "Token info"
});

ICMTATConstructor.Engine memory engines = ICMTATConstructor.Engine({
    ruleEngine: IRuleEngine(address(0))
});
```

### Required Imports for CMTAT

```solidity
import "CMTAT/deployment/CMTATStandalone.sol";
import "CMTAT/interfaces/technical/ICMTATConstructor.sol";
import "CMTAT/interfaces/tokenization/draft-IERC1643CMTAT.sol";
```

## Code Style

- Use descriptive test names
- Group related tests with comments: `// ============ Section Name ============`
- Do NOT use `view` modifier on test functions that use assertions
