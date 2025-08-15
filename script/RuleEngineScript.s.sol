// SPDX-License-Identifier: MPL-2.0

// Documentation :
// https://book.getfoundry.sh/tutorials/solidity-scripting
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {RuleEngine} from "src/RuleEngine.sol";
import {RuleWhitelist} from "src/mocks/rules/validation/RuleWhitelist.sol";
import {ValidationModuleRuleEngine} from "CMTAT/modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol";

/**
@title Deploy a RuleWhitelist and a RuleEngine. The CMTAT is considred already deployed
*/
contract RuleEngineScript is Script {
    function run() external {
        // Get env variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address ADMIN = vm.addr(deployerPrivateKey);
        address CMTAT_Address = vm.envAddress("CMTAT_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);
        //whitelist
        RuleWhitelist ruleWhitelist = new RuleWhitelist(ADMIN, address(0));
        console.log("whitelist: ", address(ruleWhitelist));
        // ruleEngine
        RuleEngine RULE_ENGINE = new RuleEngine(ADMIN, address(0), address(0));
        console.log("RuleEngine: ", address(RULE_ENGINE));
        RULE_ENGINE.addRule(ruleWhitelist);
        // Configure the new ruleEngine for CMTAT
        (bool success, ) = address(CMTAT_Address).call(
            abi.encodeCall(
                ValidationModuleRuleEngine.setRuleEngine,
                RULE_ENGINE
            )
        );
        require(success);
        vm.stopBroadcast();
    }
}
