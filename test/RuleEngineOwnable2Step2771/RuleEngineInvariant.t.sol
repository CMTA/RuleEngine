// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngineOwnable2Step2771} from "src/deployment/ownable/RuleEngineOwnable2Step2771.sol";
import {RuleEngineInvariantTestBase} from "../utils/RuleEngineInvariantTestBase.sol";

/**
 * @title RuleEngineOwnable2Step2771InvariantTest
 * @notice Invariant tests over the rule set and the bound tokens for `RuleEngineOwnable2Step2771`.
 */
contract RuleEngineOwnable2Step2771InvariantTest is RuleEngineInvariantTestBase {
    function _deployEngine(address admin) internal override returns (address) {
        return address(new RuleEngineOwnable2Step2771(admin, address(0), address(0)));
    }
}
