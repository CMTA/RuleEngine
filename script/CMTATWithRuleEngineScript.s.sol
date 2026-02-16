// SPDX-License-Identifier: MPL-2.0

// Documentation :
// https://book.getfoundry.sh/tutorials/solidity-scripting
pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";
import {ICMTATConstructor, CMTATStandalone} from "CMTAT/deployment/CMTATStandalone.sol";
import {IERC1643CMTAT} from "CMTAT/interfaces/tokenization/draft-IERC1643CMTAT.sol";
import {IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {RuleEngine} from "src/RuleEngine.sol";
import {RuleWhitelist} from "src/mocks/rules/validation/RuleWhitelist.sol";

/**
 * @title Deploy a CMTAT, a RuleWhitelist and a RuleEngine
 */
contract CMTATWithRuleEngineScript is Script {
    function run() external {
        // Get env variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.addr(deployerPrivateKey);
        address trustedForwarder = address(0x0);
        vm.startBroadcast(deployerPrivateKey);
        // CMTAT
        ICMTATConstructor.ERC20Attributes memory erc20Attributes =
            ICMTATConstructor.ERC20Attributes("CMTA Token", "CMTAT", 0);
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes =
            ICMTATConstructor.ExtraInformationAttributes(
                "CMTAT_ISIN",
                IERC1643CMTAT.DocumentInfo(
                    "Terms", "https://cmta.ch", 0x9ff867f6592aa9d6d039e7aad6bd71f1659720cbc4dd9eae1554f6eab490098b
                ),
                "CMTAT_info"
            );
        ICMTATConstructor.Engine memory engines = ICMTATConstructor.Engine(IRuleEngine(address(0)));
        CMTATStandalone cmtatContract =
            new CMTATStandalone(trustedForwarder, admin, erc20Attributes, extraInformationAttributes, engines);
        console.log("CMTAT cmtatContract : ", address(cmtatContract));
        // whitelist
        RuleWhitelist ruleWhitelist = new RuleWhitelist(admin, trustedForwarder);
        console.log("whitelist: ", address(ruleWhitelist));
        // ruleEngine
        RuleEngine ruleEngine = new RuleEngine(admin, trustedForwarder, address(cmtatContract));
        console.log("RuleEngine : ", address(ruleEngine));
        ruleEngine.addRule(ruleWhitelist);
        cmtatContract.setRuleEngine(ruleEngine);

        vm.stopBroadcast();
    }
}
