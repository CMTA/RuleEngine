// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngine} from "src/deployment/accessControl/RuleEngine.sol";
import {RuleEngine2771} from "src/deployment/accessControl/RuleEngine2771.sol";
import {RuleEngine2771Exposed} from "src/mocks/RuleEngineExposed.sol";
import {RuleEngineInvariantStorage} from "src/modules/library/RuleEngineInvariantStorage.sol";
import {ERC2771VariantTestBase} from "../utils/ERC2771VariantTestBase.sol";

/**
 * @title ERC2771VariantTest
 * @notice ERC-2771 variant tests for `RuleEngine2771`.
 */
contract ERC2771VariantTest is ERC2771VariantTestBase, RuleEngineInvariantStorage {
    function _deploy2771(address admin, address forwarder, address token) internal override returns (address) {
        return address(new RuleEngine2771(admin, forwarder, token));
    }

    function _deployWithoutForwarder(address admin, address token) internal override returns (address) {
        return address(new RuleEngine(admin, token));
    }

    function _deployExposed(address admin, address forwarder) internal override returns (address) {
        return address(new RuleEngine2771Exposed(admin, forwarder, address(0)));
    }

    function _zeroAdminRevertData() internal pure override returns (bytes memory) {
        return abi.encodeWithSelector(RuleEngine_AdminWithAddressZeroNotAllowed.selector);
    }
}
