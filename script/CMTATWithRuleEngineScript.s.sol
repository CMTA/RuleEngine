// SPDX-License-Identifier: MPL-2.0

// Documentation :
// https://book.getfoundry.sh/tutorials/solidity-scripting
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ICMTATConstructor, CMTATStandardStandalone} from "CMTAT/deployment/CMTATStandardStandalone.sol";
import {IERC1643CMTAT} from "CMTAT/interfaces/tokenization/draft-IERC1643CMTAT.sol";
import {IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {RuleEngine} from "../src/deployment/RuleEngine.sol";
import {RuleWhitelistMock} from "../src/mocks/rules/validation/RuleWhitelistMock.sol";

/**
 * @title Example deployment of a CMTAT, a mock RuleWhitelistMock and a RuleEngine
 * @dev This script deploys a reference/mock rule from `src/mocks/` for demo and testing flows.
 * It is not a production deployment recipe for rule contracts.
 */
contract CMTATWithRuleEngineScript is Script {
    /**
     * @notice Deploys a CMTAT token, the demo whitelist rule and a RuleEngine, and wires them
     * together.
     * @dev Reads the deployer key from `PRIVATE_KEY`; the deployer becomes the token and engine
     * admin.
     */
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
        CMTATStandardStandalone cmtatContract =
            new CMTATStandardStandalone(trustedForwarder, admin, erc20Attributes, extraInformationAttributes, engines);
        console.log("CMTAT cmtatContract : ", address(cmtatContract));
        // whitelist
        RuleWhitelistMock ruleWhitelist = new RuleWhitelistMock(admin, trustedForwarder);
        console.log("whitelist: ", address(ruleWhitelist));
        // ruleEngine
        RuleEngine ruleEngine = new RuleEngine(admin, trustedForwarder, address(cmtatContract));
        console.log("RuleEngine : ", address(ruleEngine));
        ruleEngine.addRule(ruleWhitelist);
        cmtatContract.setRuleEngine(ruleEngine);

        vm.stopBroadcast();
    }
}
