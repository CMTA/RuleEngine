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
The version of the library used is available in the [READEME](../README.md)

Warning: 
- Submodules are not automatically updated when the host repository is updated.  
- Only update the module to a specific version, not an intermediary commit.



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

The related component can be installed with `npm install` (see [package.json](./package.json)). 

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
npx surya graph  src/RuleEngine.sol | dot -Tpng > surya_graph_RuleEngine.png
```

#### Report

```bash
npm run-script surya:report
```



### [Slither](https://github.com/crytic/slither)

>Slither is a Solidity static analysis framework written in Python3

```bash
slither .  --checklist --filter-paths "openzeppelin-contracts|test|CMTAT|forge-std" > slither-report.md
```



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
