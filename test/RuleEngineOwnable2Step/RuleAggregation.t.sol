// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngineOwnable2Step} from "src/deployment/ownable/RuleEngineOwnable2Step.sol";
import {RuleAggregationTestBase} from "../utils/RuleAggregationTestBase.sol";

/**
 * @title RuleAggregationOwnable2StepTest
 * @notice Rule aggregation tests for the `RuleEngineOwnable2Step`.
 */
contract RuleAggregationOwnable2StepTest is RuleAggregationTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngineOwnable2Step(admin, token));
    }
}
