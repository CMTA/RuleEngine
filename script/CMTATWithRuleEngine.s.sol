// SPDX-License-Identifier: UNLICENSED
// Documentation : 
// https://book.getfoundry.sh/tutorials/solidity-scripting
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "CMTAT/CMTAT.sol";
import "src/RuleEngine.sol";

contract MyScript is Script {
    function run() external {
        // Get env variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
          address OWNER =  vm.addr(deployerPrivateKey);
        address trustedForwarder = address(0x0);
        vm.startBroadcast(deployerPrivateKey);
      
        // CMTAT
        CMTAT CMTAT_CONTRACT = new CMTAT(trustedForwarder);
        console.log("CMTAT CMTAT_CONTRACT : ", address(CMTAT_CONTRACT));
        CMTAT_CONTRACT.initialize(
            OWNER,
            "CMTA Token",
            "CMTAT",
            "CMTAT_ISIN",
            "https://cmta.ch"
        );
        // whitelist
        RuleWhitelist ruleWhitelist = new RuleWhitelist();
        console.log("whitelist: ", address(ruleWhitelist));
        // ruleEngine
        RuleEngine RULE_ENGINE = new RuleEngine(ruleWhitelist);
        console.log("RuleEngine : ", address(RULE_ENGINE));
        CMTAT_CONTRACT.setRuleEngine(RULE_ENGINE);
        vm.stopBroadcast();
    }
}