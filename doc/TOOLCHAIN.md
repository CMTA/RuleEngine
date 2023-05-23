# TOOLCHAIN

[TOC]



## Node.JS  package

This part describe the list of libraries present in the file `package.json`.

### Dev

This section concerns the packages installed in the section `devDependencies` of package.json

[hardhat-foundry](https://hardhat.org/hardhat-runner/docs/advanced/hardhat-and-foundry)

[Hardhat](https://hardhat.org/) plugin for integration with Foundry

**[Ethlint](https://github.com/duaraghav8/Ethlint)**
Solidity static analyzer.

**[prettier-plugin-solidity](https://github.com/prettier-solidity/prettier-plugin-solidity)**

A [Prettier plugin](https://prettier.io/docs/en/plugins.html) for automatically formatting your [Solidity](https://github.com/ethereum/solidity) code.

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

RuleEngine

```
npx sol2uml class -i -c src/RuleEngine.sol
```

Whitelist

```
npx sol2uml class src/Whitelist.sol
```

The related component can be installed with `npm install` (see [package.json](./package.json)). 

### [Surya](https://github.com/ConsenSys/surya)

#### Graph

To generate  graphs with Surya, you can run the following command

```bash
npm run-script surya:graph
```

OR

- RuleWhitelist

```bash
 npx surya graph  src/RuleWhitelist.sol | dot -Tpng > surya_graph_Whitelist.png
```
- RuleEngine

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

We use the following tools to ensure consistent coding style:

[Prettier](https://github.com/prettier-solidity/prettier-plugin-solidity)

```
npm run-script lint:sol:prettier 
```

[Ethlint / Solium](https://github.com/duaraghav8/Ethlint)

```
npm run-script lint:sol 
npm run-script lint:sol:fix 
npm run-script lint:sol:test 
npm run-script lint:sol:test:fix
```

The related components can be installed with `npm install` (see [package.json](./package.json)). 
