> To use the ruleEngine and the different rules, we recommend the latest audited version, from the [Releases](https://github.com/CMTA/CMTAT/releases) page. Currently, it is the version [v1.0.2](https://github.com/CMTA/RuleEngine/releases/tag/v1.0.2)

# RuleEngine

This repository includes the RuleEngine contract for the [CMTAT](https://github.com/CMTA/CMTAT) token. 
- The CMTAT version used is the version [v2.3.1](https://github.com/CMTA/CMTAT/releases/tag/v2.3.1)
- The OpenZeppelin version used is the version [v5.0.0](https://github.com/OpenZeppelin/openzeppelin-contracts/releases/tag/v5.0.0)

The CMTAT contracts and the OpenZeppelin library are included as a submodule of the present repository.

## How to include it

While it has been designed for the CMTAT, the ruleEngine can be used with others contracts to apply restriction on transfer.

For that, the only thing to do is to import in your contract the interface `IRuleEngine` which declares the function `operateOnTransfer`

This interface can be found in `CMTAT/contracts/interfaces/engine/IRuleEngine.sol`

Before each transfer, your contract have to call the function `operateOnTransfer` which is the entrypoint for the RuleEngine

## Schema

![Engine-RuleEngine.drawio](./doc/schema/Engine-RuleEngine.drawio.png)



## Available Rules

The following rules are available:

| Rule                                                         | Type           | Description                                                  | Doc                                                          |
| ------------------------------------------------------------ | -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [RuleWhitelist](src/rules/RuleWhitelist.sol)                 | RuleValidation | This rule can be used to restrict transfers from/to only addresses inside a whitelist. | [RuleWhitelist.md](./doc/technical/RuleWhitelist.md)<br />[surya-report](./doc/surya/surya_report/surya_report_RuleWhitelist.sol.md) |
| [RuleBlacklist](src/rules/RuleBlacklist.sol)                 | RuleValidation | This rule can be used to forbid transfer from/to addresses in the blacklist | [RuleBlacklist.md](./doc/technical/RuleBlacklist.md)<br />[surya-report](./doc/surya/surya_report/surya_report_RuleBlacklist.sol.md) |
| [RuleSanctionList](src/rules/RuleSanctionList.sol)           | RuleValidation | The purpose of this contract is to use the oracle contract from Chainalysis to forbid transfer from/to an address  included in a sanctions designation (US, EU, or UN). | [RuleSanctionList.md](./doc/technical/RuleSanctionList.md)<br />[surya-report](./doc/surya/surya_report/surya_report_RuleSanctionList.sol.md) |
| [RuleConditionalTransfer](src/rules/RuleConditionalTransfer.sol) | RuleOperation  | This page describes a Conditional Transfer implementation. This rule requires that transfers have to be approved before being executed by the token holders. | [RuleConditionalTransfer.md](./doc/technical/RuleConditionalTransfer.md)<br />[surya-report](./doc/surya/surya_report/surya_report_RuleConditionalTransfer.sol.md) |



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
| latest  | [slither-report.md](./doc/security/audits/tools/slither-report.md) |
| v1.0.2  | [v1.0.2-slither-report.md](./doc/security/audits/archive/v1.0.2-slither-report.md) |
| v1.0.3  | [v1.0.3-slither-report.md](./doc/security/audits/archive/v1.0.3-slither-report.md) |



## Documentation

Here a summary of the main documentation

| Document                | Link/Files                                           |
| ----------------------- | ---------------------------------------------------- |
| Technical documentation | [doc/technical/general](./doc/technical/general.md)  |
| Toolchain               | [doc/TOOLCHAIN.md](./doc/TOOLCHAIN.md)               |
| Functionalities         | [doc/functionalities.pdf](./doc/functionalities.pdf) |
| Surya report            | [doc/surya](./doc/surya/)                            |



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
