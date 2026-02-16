// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CMTATDeployment} from "../utils/CMTATDeployment.sol";
import {CMTATStandalone} from "CMTAT/deployment/CMTATStandalone.sol";
import {RuleEngineScript} from "../../script/RuleEngineScript.s.sol";

/**
 * @title Test for the RuleEngineScript deployment script
 * @dev This script expects an already-deployed CMTAT contract.
 * The deployer must have DEFAULT_ADMIN_ROLE on the CMTAT to call setRuleEngine.
 */
contract RuleEngineScriptTest is Test {
    function testRun() public {
        (address deployer, uint256 deployerPk) = makeAddrAndKey("deployer");

        // Deploy a CMTAT first (admin is address(1) by default in CMTATDeployment)
        CMTATDeployment cmtatDeployment = new CMTATDeployment();
        CMTATStandalone cmtat = cmtatDeployment.cmtat();

        // Grant DEFAULT_ADMIN_ROLE to the deployer so setRuleEngine succeeds.
        // Cache the role bytes32 before pranking to avoid consuming the prank on a view call.
        address cmtatAdmin = address(1);
        bytes32 adminRole = cmtat.DEFAULT_ADMIN_ROLE();
        vm.prank(cmtatAdmin);
        cmtat.grantRole(adminRole, deployer);

        // Set env vars
        vm.setEnv("PRIVATE_KEY", vm.toString(deployerPk));
        vm.setEnv("CMTAT_ADDRESS", vm.toString(address(cmtat)));

        RuleEngineScript deployScript = new RuleEngineScript();
        deployScript.run();
    }
}
