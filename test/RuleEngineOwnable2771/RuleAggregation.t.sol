// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngineOwnable2771} from "src/deployment/RuleEngineOwnable2771.sol";
import {RuleAggregationTestBase} from "../utils/RuleAggregationTestBase.sol";

/**
 * @title RuleAggregationOwnable2771Test
 * @notice Rule aggregation tests for `RuleEngineOwnable2771`.
 */
contract RuleAggregationOwnable2771Test is RuleAggregationTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngineOwnable2771(admin, address(0), token));
    }
}
