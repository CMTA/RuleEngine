// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngine2771} from "src/deployment/accessControl/RuleEngine2771.sol";
import {RuleAggregationTestBase} from "../utils/RuleAggregationTestBase.sol";

/**
 * @title RuleAggregation2771Test
 * @notice Rule aggregation tests for the RBAC `RuleEngine2771`.
 */
contract RuleAggregation2771Test is RuleAggregationTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngine2771(admin, address(0), token));
    }
}
