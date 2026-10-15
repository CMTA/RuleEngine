// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {RuleEngine} from "src/deployment/accessControl/RuleEngine.sol";
import {NoForwarderTestBase} from "../utils/NoForwarderTestBase.sol";

/**
 * @title NoForwarderTest
 * @notice The RBAC `RuleEngine` has no ERC-2771 support.
 */
contract NoForwarderTest is NoForwarderTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngine(admin, token));
    }

    function _managerRevertData(address caller) internal view override returns (bytes memory) {
        return abi.encodeWithSelector(
            IAccessControl.AccessControlUnauthorizedAccount.selector,
            caller,
            RuleEngine(engine).COMPLIANCE_MANAGER_ROLE()
        );
    }
}
