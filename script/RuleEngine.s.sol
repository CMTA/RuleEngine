// SPDX-License-Identifier: UNLICENSED
// Documentation : 
// https://book.getfoundry.sh/tutorials/solidity-scripting
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "CMTAT/CMTAT.sol";
import "src/RuleEngine.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address OWNER =  vm.addr(deployerPrivateKey);
        address trustedForwarder = address(0x0);
        CMTAT CMTAT_CONTRACT = new CMTAT();
        CMTAT_CONTRACT.initialize(
            OWNER,
            trustedForwarder,
            "CMTA Token",
            "CMTAT",
            "CMTAT_ISIN",
            "https://cmta.ch"
        );
        RuleWhitelist ruleWhitelist = new RuleWhitelist();
        RuleEngineMock ruleEngineMock = new RuleEngineMock(ruleWhitelist);
        CMTAT_CONTRACT.setRuleEngine(ruleEngineMock);
        vm.stopBroadcast();
    }
}