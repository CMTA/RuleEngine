// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

// forge-lint: disable-next-line(unaliased-plain-import)
import "./RuleEngineOperationRevertBase.sol";

/**
 * @title General functions of the RuleEngine (v3.2.0-rc2)
 */
contract RuleEngineOperationTestRevert is RuleEngineOperationRevertBase {
    function _deployCmtat() internal override returns (CMTATStandalone) {
        cmtatDeployment = new CMTATDeployment();
        return cmtatDeployment.cmtat();
    }
}
