> To use the ruleEngine and the different rules, we recommend the latest audited version, from the [Releases](https://github.com/CMTA/CMTAT/releases) page. Currently, it is the version [v1.0.2](https://github.com/CMTA/RuleEngine/releases/tag/v1.0.2)

# RuleEngine

This repository includes the RuleEngine contract for the [CMTAT](https://github.com/CMTA/CMTAT) token. 
- The CMTAT version used is the version [v2.3.1](https://github.com/CMTA/CMTAT/releases/tag/v2.3.1)
- The OpenZeppelin version used is the version [v5.0.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.0.0)

The CMTAT contracts and the OpenZeppelin library are included as a submodule of the present repository.

## Audit

The contracts have been audited by [ABDKConsulting](https://www.abdk.consulting/), a globally recognized firm specialized in smart contracts' security.

#### First Audit - March 2022

Fixed version : [v1.0.2](https://github.com/CMTA/RuleEngine/releases/tag/v1.0.2)

The first audit was performed by ABDK on the version [1.0.1](https://github.com/CMTA/RuleEngine/releases/tag/1.0.1).

The release [v1.0.2](https://github.com/CMTA/RuleEngine/releases/tag/v1.0.2) contains the different fixes and improvements related to this audit.

The temporary report is available in [Taurus. Audit 3.3.CollectedIssues.ods](doc/audits/Taurus.Audit3.3.CollectedIssues.ods) 

The final report is available in [ABDK_CMTA_CMTATRuleEngine_v_1_0.pdf](https://github.com/CMTA/CMTAT/blob/master/doc/audits/ABDK_CMTA_CMTATRuleEngine_v_1_0/ABDK_CMTA_CMTATRuleEngine_v_1_0.pdf).

### Tools

You will find the report performed with [Slither](https://github.com/crytic/slither) in

| Version | File                                                         |
| ------- | ------------------------------------------------------------ |
| v1.0.2  | [v1.0.2-slither-report.md](./doc/audits/tools/v1.0.2-slither-report.md) |
| v1.0.3  | [v1.0.3-slither-report.md](./doc/audits/tools/v1.0.3-slither-report.md) |

## Documentation

Here a summary of the main documentation

| Document                            | Link/Files                                             |
| ----------------------------------- | ------------------------------------------------------ |
| Solidity API Documentation (docgen) | [doc/solidityAPI](./doc/solidityAPI)                   |
| Technical documentation             | [doc/technical](./doc/technical)                       |
| Toolchain                           | [doc/TOOLCHAIN.md](./doc/TOOLCHAIN.md)                 |
| Functionalities                     | [doc/functionalities.pdf](./doc/functionalities.pdf)   |
| Surya report                        | [doc/surya](./doc/surya)                               |
| Test (v1.0.2)                       | [doc/test/v1.0.2/test.pdf](./doc/test/v1.0.2/test.pdf) |



## Usage

*Explain how it works.*


## Toolchain installation
The contracts are developed and tested with [Foundry](https://book.getfoundry.sh), a smart contract development toolchain.

To install the Foundry suite, please refer to the official instructions in the [Foundry book](https://book.getfoundry.sh/getting-started/installation).

## Initialization

You must first initialize the submodules, with

```
forge install
```

See also the command's [documentation](https://book.getfoundry.sh/reference/forge/forge-install).

Later you can update all the submodules with:

```
forge update
```

See also the command's [documentation](https://book.getfoundry.sh/reference/forge/forge-update).



## Compilation

The official documentation is available in the Foundry [website](https://book.getfoundry.sh/reference/forge/build-commands) 
```
 forge build --contracts src/RuleEngine.sol
```
```
 forge build --contracts src/RuleWhiteList.sol
```

## Testing
You can run the tests with

```
forge test
```

To run a specific test, use

```
forge test --match-contract <contract name> --match-test <function name>
```

See also the test framework's [official documentation](https://book.getfoundry.sh/forge/tests), and that of the [test commands](https://book.getfoundry.sh/reference/forge/test-commands).

### Coverage
* Perform a code coverage
```
forge coverage
```

* Generate LCOV report
```
forge coverage --report lcov
```

- Generate `index.html`

```bash
forge coverage --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage
```

See [Solidity Coverage in VS Code with Foundry](https://mirror.xyz/devanon.eth/RrDvKPnlD-pmpuW7hQeR5wWdVjklrpOgPCOA-PJkWFU) & [Foundry forge coverage](https://www.rareskills.io/post/foundry-forge-coverage)

## Deployment
The official documentation is available in the Foundry [website](https://book.getfoundry.sh/reference/forge/deploy-commands) 
### Script

> This documentation has been written for the version v1.0.2

To run the script for deployment, you need to create a .env file. The value for CMTAT.ADDRESS is require only to use the script **RuleEngine.s.sol**
Warning : put your private key in a .env file is not the best secure way.

* File .env
```
PRIVATE_KEY=<YOUR_PRIVATE_KEY>
CMTAT_ADDRESS=<CMTAT ADDDRESS
```
* Command

CMTAT with RuleEngine

```bash
forge script script/CMTATWithRuleEngineScript.s.sol:CMTATWithRuleEngineScript --rpc-url=$RPC_URL  --broadcast --verify -vvv
```
Value of YOUR_RPC_URL with a local instance of anvil : [http://127.0.0.1:8545](http://127.0.0.1:8545)

Only RuleEngine with a Whitelist contract

```bash
forge script script/RuleEngineScript.s.sol:RuleEngineScript --rpc-url=$RPC_URL  --broadcast --verify -vvv
```

### Local

> This documentation has been written for the version v1.0.2

With Foundry, you [can create a local testnet](https://book.getfoundry.sh/reference/anvil/) node for deploying and testing smart contracts, based on the [Anvil](https://anvil.works/) framework. 

On Linux, using the default RPC URL, and Anvil's test private key, run:  

Example - Deploy the CMTAT, standalone version

```  bash
export RPC_URL=http://127.0.0.1:8545
export PRIVATE_KEY=<Local Private Key>
forge create CMTAT_BASE --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY --constructor-args 0x0000000000000000000000000000000000000000,ADMIN,"CMTA Token","CMTAT","CMTAT_ISIN","https://cmta.ch",0x0000000000000000000000000000000000000000,"CMTAT_info",5
```

See also the command's [documentation](https://book.getfoundry.sh/reference/forge/deploy-command).
