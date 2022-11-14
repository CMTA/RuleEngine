// SPDX-License-Identifier: UNLICENSED
// Documentation :
// https://book.getfoundry.sh/tutorials/solidity-scripting
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "CMTAT/CMTAT.sol";
import "src/RuleEngine.sol";

/**
@title Deploy a RuleWhitelist and a RuleEngine. The CMTAT is considred already deployed
*/
contract MyScript is Script {
    function run() external {
        // Get env variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address CMTAT_Address = vm.envAddress("CMTAT_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);
        //whitelist
        RuleWhitelist ruleWhitelist = new RuleWhitelist();
        console.log("whitelist: ", address(ruleWhitelist));
        // ruleEngine
        RuleEngine RULE_ENGINE = new RuleEngine();
        console.log("RuleEngine: ", address(RULE_ENGINE));
        RULE_ENGINE.addRule(ruleWhitelist);
        // Configure the new ruleEngine for CMTAT
        (bool success, ) = address(CMTAT_Address).call(
            abi.encodeCall(CMTAT.setRuleEngine, RULE_ENGINE)
        );
        require(success);
        vm.stopBroadcast();
    }
}
