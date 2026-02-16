// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CMTATWithRuleEngineScript} from "../../script/CMTATWithRuleEngineScript.s.sol";

/**
 * @title Test for the CMTATWithRuleEngineScript deployment script
 */
contract CMTATWithRuleEngineScriptTest is Test {
    function testRun() public {
        (, uint256 deployerPk) = makeAddrAndKey("deployer");
        vm.setEnv("PRIVATE_KEY", vm.toString(deployerPk));
        CMTATWithRuleEngineScript deployScript = new CMTATWithRuleEngineScript();
        deployScript.run();
    }
}
