// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngine} from "src/deployment/accessControl/RuleEngine.sol";
import {RuleEngineInvariantTestBase} from "../utils/RuleEngineInvariantTestBase.sol";

/**
 * @title RuleEngineInvariantTest
 * @notice Invariant tests over the rule set and the bound tokens for the RBAC `RuleEngine`.
 */
contract RuleEngineInvariantTest is RuleEngineInvariantTestBase {
    function _deployEngine(address admin) internal override returns (address) {
        return address(new RuleEngine(admin, address(0)));
    }
}
