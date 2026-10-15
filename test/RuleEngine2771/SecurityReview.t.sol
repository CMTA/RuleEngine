// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {RuleEngine2771} from "src/deployment/accessControl/RuleEngine2771.sol";
import {SecurityReviewTestBase} from "../utils/SecurityReviewTestBase.sol";

/**
 * @title SecurityReview2771Test
 * @notice v3.0.0-rc7 security review tests for `RuleEngine2771`.
 */
contract SecurityReview2771Test is SecurityReviewTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngine2771(admin, FORWARDER, token));
    }

    function _unauthorizedRevertData(address caller, bytes32 role) internal pure override returns (bytes memory) {
        return abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, caller, role);
    }

    function _renounceAdministration() internal override {
        vm.prank(ADMIN);
        IAccessControl(address(engine)).renounceRole(DEFAULT_ADMIN_ROLE, ADMIN);
    }
}
