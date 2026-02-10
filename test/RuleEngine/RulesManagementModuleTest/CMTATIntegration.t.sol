// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "./CMTATIntegrationBase.sol";

/**
 * @title General functions of the RuleEngine (v3.2.0-rc2)
 */
contract RuleEngineCMTATIntegrationTest is RuleEngineCMTATIntegrationBase {
    function _deployCMTAT() internal override returns (CMTATStandalone) {
        cmtatDeployment = new CMTATDeployment();
        return cmtatDeployment.cmtat();
    }
}
