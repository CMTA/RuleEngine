// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

// forge-lint: disable-next-line(unaliased-plain-import)
import "./CMTATIntegrationBase.sol";
import {CMTATDeploymentV3} from "../../utils/CMTATDeploymentV3.sol";

/**
 * @title General functions of the RuleEngine (v3.0.0)
 */
contract RuleEngineCMTATIntegrationV3Test is RuleEngineCMTATIntegrationBase {
    function _deployCmtat() internal override returns (CMTATStandalone) {
        CMTATDeploymentV3 v3deploy = new CMTATDeploymentV3();
        return CMTATStandalone(address(v3deploy.cmtat()));
    }
}
