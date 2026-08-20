// SPDX-License-Identifier: MPL-2.0

// Documentation :
// https://book.getfoundry.sh/tutorials/solidity-scripting
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {RuleEngine} from "src/deployment/RuleEngine.sol";
import {RuleWhitelistMock} from "src/mocks/rules/validation/RuleWhitelistMock.sol";
import {IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {
    ValidationModuleRuleEngine
} from "CMTAT/modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol";

/**
 * @title Example deployment of a mock RuleWhitelistMock and a RuleEngine
 * @dev This script deploys a reference/mock rule from `src/mocks/` for demo and testing flows.
 * It is not a production deployment recipe for rule contracts.
 *
 * Expects an already-deployed CMTAT at `CMTAT_ADDRESS`. The deployer must hold `DEFAULT_ADMIN_ROLE`
 * on that token, otherwise {setRuleEngine} reverts.
 *
 * The token is bound to the engine through the constructor: without it, every transfer, mint and burn
 * reverts with `TokenBinding_UnauthorizedCaller`, because the compliance callbacks are
 * guarded by `onlyBoundToken`.
 *
 * The deployer and the zero address are added to the whitelist so the resulting deployment is usable
 * as-is: the zero address is required for mint and burn, since the rule treats it as an ordinary
 * participant. Replace this with the real address list for anything beyond a demo.
 */
contract RuleEngineScript is Script {
    function run() external {
        // Get env variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.addr(deployerPrivateKey);
        address cmtatAddress = vm.envAddress("CMTAT_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);
        //whitelist
        RuleWhitelistMock ruleWhitelist = new RuleWhitelistMock(admin, address(0));
        console.log("whitelist: ", address(ruleWhitelist));
        // Seed the list so the demo deployment can actually transfer, mint and burn.
        address[] memory listed = new address[](2);
        listed[0] = admin;
        listed[1] = address(0);
        ruleWhitelist.addAddressesToTheList(listed);
        // ruleEngine, bound to the CMTAT token
        RuleEngine ruleEngine = new RuleEngine(admin, address(0), cmtatAddress);
        console.log("RuleEngine: ", address(ruleEngine));
        ruleEngine.addRule(ruleWhitelist);
        // Configure the new ruleEngine for CMTAT.
        // A typed call is used deliberately: a low-level `.call` would return success even when
        // `cmtatAddress` holds no code, silently producing an unconfigured deployment.
        ValidationModuleRuleEngine(cmtatAddress).setRuleEngine(IRuleEngine(address(ruleEngine)));
        vm.stopBroadcast();
    }
}
