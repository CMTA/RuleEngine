// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "./CMTATIntegrationBase.sol";

/**
 * @title Integration test with the CMTAT (v3.2.0-rc2)
 */
contract CMTATIntegration is CMTATIntegrationBase {
    function _deployCMTAT() internal override returns (CMTATStandalone) {
        cmtatDeployment = new CMTATDeployment();
        return cmtatDeployment.cmtat();
    }
}
