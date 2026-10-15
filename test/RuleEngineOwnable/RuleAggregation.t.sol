// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngineOwnable} from "src/deployment/RuleEngineOwnable.sol";
import {RuleAggregationTestBase} from "../utils/RuleAggregationTestBase.sol";

/**
 * @title RuleAggregationOwnableTest
 * @notice Rule aggregation tests for the `RuleEngineOwnable`.
 */
contract RuleAggregationOwnableTest is RuleAggregationTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngineOwnable(admin, token));
    }
}
