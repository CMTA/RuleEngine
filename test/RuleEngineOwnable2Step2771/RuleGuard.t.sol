// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngineOwnable2Step2771} from "src/deployment/ownable/RuleEngineOwnable2Step2771.sol";
import {Ownable2StepRuleGuardTestBase} from "../utils/Ownable2StepRuleGuardTestBase.sol";

/**
 * @title Ownable2Step2771RuleGuardTest
 * @notice v3.0.0-rc7 security review, threat AC-3, for `RuleEngineOwnable2Step2771`.
 */
contract Ownable2Step2771RuleGuardTest is Ownable2StepRuleGuardTestBase {
    function _deployEngine(address owner_) internal override returns (address) {
        return address(new RuleEngineOwnable2Step2771(owner_, address(0xF0F0), address(0)));
    }
}
