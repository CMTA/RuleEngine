// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RuleEngineOwnable2Step} from "src/deployment/ownable/RuleEngineOwnable2Step.sol";
import {SecurityReviewTestBase} from "../utils/SecurityReviewTestBase.sol";

/**
 * @title SecurityReviewOwnable2StepTest
 * @notice v3.0.0-rc7 security review tests for `RuleEngineOwnable2Step`.
 */
contract SecurityReviewOwnable2StepTest is SecurityReviewTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngineOwnable2Step(admin, token));
    }

    function _unauthorizedRevertData(address caller, bytes32) internal pure override returns (bytes memory) {
        return abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, caller);
    }

    function _renounceAdministration() internal override {
        vm.prank(ADMIN);
        Ownable(address(engine)).renounceOwnership();
    }
}
