// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngine} from "src/deployment/accessControl/RuleEngine.sol";
import {RuleAggregationTestBase} from "../utils/RuleAggregationTestBase.sol";

/**
 * @title RuleAggregationTest
 * @notice Rule aggregation tests for the RBAC `RuleEngine`.
 */
contract RuleAggregationTest is RuleAggregationTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngine(admin, token));
    }
}
