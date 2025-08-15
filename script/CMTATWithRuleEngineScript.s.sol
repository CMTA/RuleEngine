// SPDX-License-Identifier: MPL-2.0

// Documentation :
// https://book.getfoundry.sh/tutorials/solidity-scripting
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../test/HelperContract.sol";
import {RuleEngine} from "src/RuleEngine.sol";
import {RuleWhitelist} from "src/mocks/rules/validation/RuleWhitelist.sol";

/**
 * @title Deploy a CMTAT, a RuleWhitelist and a RuleEngine
 */
contract CMTATWithRuleEngineScript is Script, HelperContract {
    function run() external {
        // Get env variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address ADMIN = vm.addr(deployerPrivateKey);
        address trustedForwarder = address(0x0);
        vm.startBroadcast(deployerPrivateKey);
        // CMTAT
        cmtatDeployment = new CMTATDeployment();
        CMTAT_CONTRACT = cmtatDeployment.cmtat();
        console.log("CMTAT CMTAT_CONTRACT : ", address(CMTAT_CONTRACT));
        // whitelist
        RuleWhitelist ruleWhitelist = new RuleWhitelist(
            ADMIN,
            trustedForwarder
        );
        console.log("whitelist: ", address(ruleWhitelist));
        // ruleEngine
        RuleEngine RULE_ENGINE = new RuleEngine(
            ADMIN,
            trustedForwarder,
            address(CMTAT_CONTRACT)
        );
        console.log("RuleEngine : ", address(RULE_ENGINE));
        RULE_ENGINE.addRule(ruleWhitelist);
        CMTAT_CONTRACT.setRuleEngine(RULE_ENGINE);

        vm.stopBroadcast();
    }
}
