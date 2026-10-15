// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RuleEngineOwnable2Step} from "src/deployment/RuleEngineOwnable2Step.sol";
import {NoForwarderTestBase} from "../utils/NoForwarderTestBase.sol";

/**
 * @title NoForwarderOwnable2StepTest
 * @notice `RuleEngineOwnable2Step` has no ERC-2771 support.
 */
contract NoForwarderOwnable2StepTest is NoForwarderTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngineOwnable2Step(admin, token));
    }

    function _managerRevertData(address caller) internal pure override returns (bytes memory) {
        return abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, caller);
    }
}
