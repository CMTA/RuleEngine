// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {RuleEngine} from "src/deployment/accessControl/RuleEngine.sol";
import {SecurityReviewTestBase} from "../utils/SecurityReviewTestBase.sol";

/**
 * @title SecurityReviewTest
 * @notice v3.0.0-rc7 security review tests for the RBAC `RuleEngine`.
 */
contract SecurityReviewTest is SecurityReviewTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngine(admin, token));
    }

    function _unauthorizedRevertData(address caller, bytes32 role) internal pure override returns (bytes memory) {
        return abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, caller, role);
    }

    function _renounceAdministration() internal override {
        vm.prank(ADMIN);
        IAccessControl(address(engine)).renounceRole(DEFAULT_ADMIN_ROLE, ADMIN);
    }
}
