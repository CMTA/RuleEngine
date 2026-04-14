// SPDX-License-Identifier: MPL-2.0

// Documentation :
// https://book.getfoundry.sh/tutorials/solidity-scripting
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {RuleEngine} from "src/deployment/RuleEngine.sol";
import {RuleWhitelist} from "src/mocks/rules/validation/RuleWhitelist.sol";
import {
    ValidationModuleRuleEngine
} from "CMTAT/modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol";

/**
 * @title Example deployment of a mock RuleWhitelist and a RuleEngine
 * @dev This script deploys a reference/mock rule from `src/mocks/` for demo and testing flows.
 * It is not a production deployment recipe for rule contracts.
 */
contract RuleEngineScript is Script {
    function run() external {
        // Get env variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.addr(deployerPrivateKey);
        address cmtatAddress = vm.envAddress("CMTAT_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);
        //whitelist
        RuleWhitelist ruleWhitelist = new RuleWhitelist(admin, address(0));
        console.log("whitelist: ", address(ruleWhitelist));
        // ruleEngine
        RuleEngine ruleEngine = new RuleEngine(admin, address(0), address(0));
        console.log("RuleEngine: ", address(ruleEngine));
        ruleEngine.addRule(ruleWhitelist);
        // Configure the new ruleEngine for CMTAT
        (bool success,) =
            address(cmtatAddress).call(abi.encodeCall(ValidationModuleRuleEngine.setRuleEngine, ruleEngine));
        require(success);
        vm.stopBroadcast();
    }
}
