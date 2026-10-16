// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngineOwnable2Step2771} from "src/deployment/ownable/RuleEngineOwnable2Step2771.sol";
import {RuleAggregationTestBase} from "../utils/RuleAggregationTestBase.sol";

/**
 * @title RuleAggregationOwnable2Step2771Test
 * @notice Rule aggregation tests for `RuleEngineOwnable2Step2771`.
 */
contract RuleAggregationOwnable2Step2771Test is RuleAggregationTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngineOwnable2Step2771(admin, address(0), token));
    }
}
