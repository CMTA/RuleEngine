// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngineOwnable2Step} from "src/deployment/ownable/RuleEngineOwnable2Step.sol";
import {Ownable2StepRuleGuardTestBase} from "../utils/Ownable2StepRuleGuardTestBase.sol";

/**
 * @title Ownable2StepRuleGuardTest
 * @notice v3.0.0-rc7 security review, threat AC-3, for `RuleEngineOwnable2Step`.
 */
contract Ownable2StepRuleGuardTest is Ownable2StepRuleGuardTestBase {
    function _deployEngine(address owner_) internal override returns (address) {
        return address(new RuleEngineOwnable2Step(owner_, address(0)));
    }
}
