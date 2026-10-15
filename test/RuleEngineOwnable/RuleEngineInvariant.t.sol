// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngineOwnable} from "src/deployment/ownable/RuleEngineOwnable.sol";
import {RuleEngineInvariantTestBase} from "../utils/RuleEngineInvariantTestBase.sol";

/**
 * @title RuleEngineOwnableInvariantTest
 * @notice Invariant tests over the rule set and the bound tokens for `RuleEngineOwnable`.
 */
contract RuleEngineOwnableInvariantTest is RuleEngineInvariantTestBase {
    function _deployEngine(address admin) internal override returns (address) {
        return address(new RuleEngineOwnable(admin, address(0)));
    }
}
