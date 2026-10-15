// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngineOwnable2Step} from "src/deployment/ownable/RuleEngineOwnable2Step.sol";
import {RuleEngineInvariantTestBase} from "../utils/RuleEngineInvariantTestBase.sol";

/**
 * @title RuleEngineOwnable2StepInvariantTest
 * @notice Invariant tests over the rule set and the bound tokens for `RuleEngineOwnable2Step`.
 */
contract RuleEngineOwnable2StepInvariantTest is RuleEngineInvariantTestBase {
    function _deployEngine(address admin) internal override returns (address) {
        return address(new RuleEngineOwnable2Step(admin, address(0)));
    }
}
