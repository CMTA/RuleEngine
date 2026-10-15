// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RuleEngineOwnable2771} from "src/deployment/ownable/RuleEngineOwnable2771.sol";
import {ERC2771TokenGateTestBase} from "../utils/ERC2771TokenGateTestBase.sol";

/**
 * @title ERC2771TokenGateOwnableTest
 * @notice ERC-2771 token-identity gate tests for `RuleEngineOwnable2771`.
 */
contract ERC2771TokenGateOwnableTest is ERC2771TokenGateTestBase {
    function _deployEngine(address admin, address forwarder, address token) internal override returns (address) {
        return address(new RuleEngineOwnable2771(admin, forwarder, token));
    }

    function _managerRevertData(address caller) internal pure override returns (bytes memory) {
        return abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, caller);
    }
}
