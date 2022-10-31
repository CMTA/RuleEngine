# RuleEngine

This repository includes the RuleEngine contract for the
[CMTAT](https://github.com/CMTA/CMTAT) token.

The CMTAT contracts are included as a [submodule](CMTAT/) of the present repository.

## Usage

*Explain how it works.*


## Toolchain installation
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
The official documentation is available here : [website](https://book.getfoundry.sh/reference/forge/build-commands) 
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
forge coverage --report lcov
```

* Generate LCOV report
```
forge coverage --report lcov
```

See [Solidity Coverage in VS Code with Foundry](https://mirror.xyz/devanon.eth/RrDvKPnlD-pmpuW7hQeR5wWdVjklrpOgPCOA-PJkWFU)

## Deployment
The official documentation is available here : [website](https://book.getfoundry.sh/reference/forge/deploy-commands) 
### Script
To run the script for deployment, you need to create a .env file. The value for CMTAT.ADDRESS is require only to use the script **RuleEngine.s.sol**
Warning : put your private key in a .env file is not the best secure way.

* File .env
```
PRIVATE_KEY=<YOUR_PRIVATE_KEY>
CMTAT_ADDRESS=<CMTAT ADDDRESS
```
* Command
```
forge script script/CMTATWithRuleEngine.s.sol:MyScript --rpc-url=<YOUR_RPC_URL>  --broadcast --verify -vvv
```
Value of YOUR_RPC_URL with a local instance of anvil : http://127.0.0.1:8545

### Local
With Foundry, you [can create a local testnet](https://book.getfoundry.sh/reference/anvil/) node for deploying and testing smart contracts, based on the [Anvil](https://anvil.works/) framework. 

On Linux, using the default RPC URL, and Anvil's test private key, run:  

```  
export RPC_URL=http://127.0.0.1:8545`  
export PRIVATE_KEY=<Local Private Key>
forge create CMTAT --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY
```

See also the command's [documentation](https://book.getfoundry.sh/reference/forge/deploy-command).

## Code style guidelines
We use the following tools to ensure consistent coding style:


[Prettier](https://github.com/prettier-solidity/prettier-plugin-solidity):

```
npx prettier --write 'test/**/*.sol'
```

[Ethlint/ Solium](https://github.com/duaraghav8/Ethlint)

```
npx solium -d test
```  

The related components can be installed with `npm install` (see [package.json](./package.json)). 

