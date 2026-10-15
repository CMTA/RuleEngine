// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {RuleEngine2771} from "src/deployment/RuleEngine2771.sol";
import {ERC2771TokenGateTestBase} from "../utils/ERC2771TokenGateTestBase.sol";

/**
 * @title ERC2771TokenGateTest
 * @notice ERC-2771 token-identity gate tests for the RBAC `RuleEngine2771`.
 */
contract ERC2771TokenGateTest is ERC2771TokenGateTestBase {
    function _deployEngine(address admin, address forwarder, address token) internal override returns (address) {
        return address(new RuleEngine2771(admin, forwarder, token));
    }

    function _managerRevertData(address caller) internal view override returns (bytes memory) {
        return abi.encodeWithSelector(
            IAccessControl.AccessControlUnauthorizedAccount.selector,
            caller,
            RuleEngine2771(engine).COMPLIANCE_MANAGER_ROLE()
        );
    }
}
