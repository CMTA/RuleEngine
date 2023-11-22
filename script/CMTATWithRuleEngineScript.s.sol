// SPDX-License-Identifier: UNLICENSED
// Documentation :
// https://book.getfoundry.sh/tutorials/solidity-scripting
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "CMTAT/CMTAT_STANDALONE.sol";
import "src/RuleEngine.sol";
import "src/rules/RuleWhitelist.sol";
/**
@title Deploy a CMTAT, a RuleWhitelist and a RuleEngine
*/
contract CMTATWithRuleEngineScript is Script {
    function run() external {
        // Get env variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address ADMIN = vm.addr(deployerPrivateKey);
        address trustedForwarder = address(0x0);
        vm.startBroadcast(deployerPrivateKey);
        uint256 flag = 5;
        uint48 initialDelay = 0;
        uint8 decimals = 0;
        // CMTAT
        CMTAT_STANDALONE CMTAT_CONTRACT = new CMTAT_STANDALONE(
            trustedForwarder,
            ADMIN,
            initialDelay,
            "CMTA Token",
            "CMTAT",
            decimals,
            "CMTAT_ISIN",
            "https://cmta.ch",
            IRuleEngine(address(0)),
            "CMTAT_info",
            flag
        );
        console.log("CMTAT CMTAT_CONTRACT : ", address(CMTAT_CONTRACT));
        // whitelist
        RuleWhitelist ruleWhitelist = new RuleWhitelist(
            ADMIN,
            trustedForwarder
        );
        console.log("whitelist: ", address(ruleWhitelist));
        // ruleEngine
        RuleEngine RULE_ENGINE = new RuleEngine(ADMIN, trustedForwarder);
        console.log("RuleEngine : ", address(RULE_ENGINE));
        RULE_ENGINE.addRule(ruleWhitelist);
        CMTAT_CONTRACT.setRuleEngine(RULE_ENGINE);

        vm.stopBroadcast();
    }
}
