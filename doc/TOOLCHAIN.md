# TOOLCHAIN

[TOC]



## Node.JS  package

This part describe the list of libraries present in the file `package.json`.

### Dev

This section concerns the packages installed in the section `devDependencies` of package.json

[hardhat-foundry](https://hardhat.org/hardhat-runner/docs/advanced/hardhat-and-foundry)

[Hardhat](https://hardhat.org/) plugin for integration with Foundry

**[Foundry forge fmt](https://book.getfoundry.sh/reference/forge/forge-fmt)**
Solidity code formatter integrated with the Foundry toolchain.

**[Foundry forge lint](https://book.getfoundry.sh/reference/forge/forge-lint)**
Solidity linter integrated with the Foundry toolchain.

#### Documentation

**[sol2uml](https://github.com/naddison36/sol2uml)**

Generate UML for smart contracts

**[solidity-docgen](https://github.com/OpenZeppelin/solidity-docgen)**

Program that extracts documentation for a Solidity project.

**[Surya](https://github.com/ConsenSys/surya)**

Utility tool for smart contract systems.



## Submodule

**[OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)**
OpenZeppelin Contracts
The version of the library used is available in the [README](./README.md#dependencies)

Warning: 
- Submodules are not automatically updated when the host repository is updated.  
- Only update the module to a specific version, not an intermediary commit.

## Tested versions

The current tested baseline is:

- Solidity: [0.8.36](https://docs.soliditylang.org/en/v0.8.36/)
- OpenZeppelin Contracts (submodule): [v5.6.1](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.6.1)
- CMTAT: [v3.2.0](https://github.com/CMTA/CMTAT/releases/tag/v3.2.0)



## Generate documentation

### [docgen](https://github.com/OpenZeppelin/solidity-docgen)

>Solidity-docgen is a program that extracts documentation for a Solidity project.

```
npx hardhat docgen 
```

### [sol2uml](https://github.com/naddison36/sol2uml)

>Generate UML for smart contracts

You can generate UML for smart contracts by running the following command:

```bash
npm run-script uml
npm run-script uml:test
```

Or only specified contracts

```
npx sol2uml class -i -c src/RuleEngine.sol
```

The related component can be installed with `npm install` (see [package.json](../package.json)). 

> To avoid the error "Maximum call stack size exceeded", you can flatten the contract before
>
> forge flatten src/RuleEngine.sol > RuleEngineFlatten.sol

### [Surya](https://github.com/ConsenSys/surya)

To generate documentation with surya, you can call the three bash scripts in `doc/script`

| Task                 | Script                        |
| -------------------- | ----------------------------- |
| Generate graph       | `script_surya_graph.sh`       |
| Generate inheritance | `script_surya_inheritance.sh` |
| Generate report      | `script_surya_report.sh`      |

In the report, the path for the different files are indicated in absolute. You have to remove the part which correspond to your local filesystem.



#### Graph

To generate  graphs with Surya, you can run the following command

```bash
npm run-script surya:graph
```

```bash
npx surya graph  src/deployment/RuleEngine.sol | dot -Tpng > surya_graph_RuleEngine.png
```

#### Report

```bash
npm run-script surya:report
```



### [Slither](https://github.com/crytic/slither)

>Slither is a Solidity static analysis framework written in Python3

```bash
slither .  --checklist --filter-paths "openzeppelin-contracts|test|mocks|CMTAT|forge-std" > slither-report.md
```

### [Aderyn](https://github.com/Cyfrin/aderyn)

```bash
aderyn -x mocks --output aderyn-report.md
```

## Code coverage

**[forge coverage](https://book.getfoundry.sh/reference/forge/forge-coverage)** — test coverage

```bash
# Summary in the terminal
forge coverage

# Production coverage as an HTML report in ./coverage, mocks and tests excluded
forge coverage --no-match-coverage "(mocks|test)" --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage
```

`genhtml` ships with [LCOV](https://github.com/linux-test-project/lcov) (`apt install lcov`). Open
`coverage/index.html` to browse the result. `--no-match-coverage "(mocks|test)"` keeps the figure meaningful by
excluding the reference rules in `src/mocks/` and the test contracts, which would otherwise inflate it.

Both `lcov.info` and the generated `coverage/` directory are gitignored scratch. The **published** report is
committed under [doc/coverage](./coverage/); refresh it by copying the generated directory there.

Add `script` to the exclusion — `--no-match-coverage "(script|mocks|test)"` — to measure `src/` alone, without
the Foundry deployment scripts. Measured on v3.0.0-rc5 the difference is marginal, since both scripts are
covered by tests:

| Exclusion | Lines | Functions | Branches |
|---|---|---|---|
| `(mocks\|test)` | 98.5% (270/274) | 95.3% (81/85) | 93.0% (40/43) |
| `(script\|mocks\|test)` | 98.3% (234/238) | 95.2% (79/83) | 93.0% (40/43) |

### Reading the report: abstract declarations always show 0

An `internal virtual;` declaration with **no body** is reported with a hit count of `0`, which looks like a
coverage gap but is not one. There is no bytecode at that line: the declaration only fixes the signature, and
the executable code lives in the contracts that override it.

This affects the access-control hooks, which the project declares in the abstract modules and implements in
each deployable contract:

```solidity
// src/modules/ERC3643ComplianceModule.sol — reported as 0, no body to execute
function _authorizeComplianceBindingChange(address token) internal virtual;
function _onlyComplianceManager() internal virtual;

// src/modules/RulesManagementModule.sol — likewise
function _onlyRulesManager() internal virtual;
function _onlyRulesLimitManager() internal virtual;
```

The implementations are covered. Measured on v3.0.0-rc5 (`FNDA` records in `lcov.info`):

| Implementation | Hits |
|---|---|
| `RuleEngine._onlyRulesManager` | 217 |
| `ERC3643ComplianceExtendedModule._authorizeComplianceBindingChange` | 87 |
| `RuleEngineOwnable._onlyRulesManager` | 69 |
| `RuleEngine._onlyComplianceManager` | 56 |
| `RuleEngineOwnable._onlyComplianceManager` | 46 |
| `RuleEngineOwnable2Step._onlyComplianceManager` | 25 |
| `RuleEngine._onlyRulesLimitManager` | 5 |

The `onlyX` **modifiers** that call these hooks are counted in the abstract module itself
(`onlyComplianceManager` 9 hits, `onlyRulesManager` 19), which is the giveaway: the modifier executes there,
while the hook it dispatches to resolves to the derived contract.

To check a specific hook rather than trusting the HTML, read the function records directly:

```bash
grep -E "^FNDA:.*_onlyComplianceManager" lcov.info
```

**Rule of thumb: a `0` on a line that declares an abstract function means "implemented elsewhere", not
"untested".**

See also [Solidity Coverage in VS Code with Foundry](https://mirror.xyz/devanon.eth/RrDvKPnlD-pmpuW7hQeR5wWdVjklrpOgPCOA-PJkWFU)
and [Foundry forge coverage](https://www.rareskills.io/post/foundry-forge-coverage).

## Code style guidelines

We use the following Foundry tools to ensure consistent coding style:

**[forge fmt](https://book.getfoundry.sh/reference/forge/forge-fmt)** — Solidity formatter

```bash
# Format all files
forge fmt

# Check formatting without modifying files
forge fmt --check
```

**[forge lint](https://book.getfoundry.sh/reference/forge/forge-lint)** — Solidity linter

```bash
# Run linter on all files
forge lint
```
