// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {RuleEngineOwnable2Step} from "src/deployment/RuleEngineOwnable2Step.sol";
import {RuleEngineOwnable2Step2771} from "src/deployment/RuleEngineOwnable2Step2771.sol";
import {RuleEngineOwnable2Step2771Exposed} from "src/mocks/RuleEngineExposed.sol";
import {ERC2771VariantTestBase} from "../utils/ERC2771VariantTestBase.sol";

/**
 * @title ERC2771VariantOwnable2StepTest
 * @notice ERC-2771 variant tests for `RuleEngineOwnable2Step2771`.
 */
contract ERC2771VariantOwnable2StepTest is ERC2771VariantTestBase {
    function _deploy2771(address admin, address forwarder, address token) internal override returns (address) {
        return address(new RuleEngineOwnable2Step2771(admin, forwarder, token));
    }

    function _deployWithoutForwarder(address admin, address token) internal override returns (address) {
        return address(new RuleEngineOwnable2Step(admin, token));
    }

    function _deployExposed(address admin, address forwarder) internal override returns (address) {
        return address(new RuleEngineOwnable2Step2771Exposed(admin, forwarder, address(0)));
    }

    function _zeroAdminRevertData() internal pure override returns (bytes memory) {
        return abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0));
    }
}
