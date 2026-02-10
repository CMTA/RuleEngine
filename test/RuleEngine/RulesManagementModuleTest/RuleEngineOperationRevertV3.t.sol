// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "./RuleEngineOperationRevertBase.sol";
import {CMTATDeploymentV3} from "../../utils/CMTATDeploymentV3.sol";

/**
 * @title General functions of the RuleEngine (v3.0.0)
 */
contract RuleEngineOperationTestRevertV3 is RuleEngineOperationRevertBase {
    function _deployCMTAT() internal override returns (CMTATStandalone) {
        CMTATDeploymentV3 v3deploy = new CMTATDeploymentV3();
        return CMTATStandalone(address(v3deploy.cmtat()));
    }
}
