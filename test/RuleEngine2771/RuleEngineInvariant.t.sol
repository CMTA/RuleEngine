// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngine2771} from "src/deployment/accessControl/RuleEngine2771.sol";
import {RuleEngineInvariantTestBase} from "../utils/RuleEngineInvariantTestBase.sol";

/**
 * @title RuleEngine2771InvariantTest
 * @notice Invariant tests over the rule set and the bound tokens for `RuleEngine2771`.
 */
contract RuleEngine2771InvariantTest is RuleEngineInvariantTestBase {
    function _deployEngine(address admin) internal override returns (address) {
        return address(new RuleEngine2771(admin, address(0), address(0)));
    }
}
