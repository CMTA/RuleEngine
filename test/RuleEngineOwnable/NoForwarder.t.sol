// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RuleEngineOwnable} from "src/deployment/RuleEngineOwnable.sol";
import {NoForwarderTestBase} from "../utils/NoForwarderTestBase.sol";

/**
 * @title NoForwarderOwnableTest
 * @notice `RuleEngineOwnable` has no ERC-2771 support.
 */
contract NoForwarderOwnableTest is NoForwarderTestBase {
    function _deployEngine(address admin, address token) internal override returns (address) {
        return address(new RuleEngineOwnable(admin, token));
    }

    function _managerRevertData(address caller) internal pure override returns (bytes memory) {
        return abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, caller);
    }
}
