//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngineOwnable2Step} from "src/deployment/RuleEngineOwnable2Step.sol";
import {RuleConditionalTransferLight} from "src/mocks/rules/operation/RuleConditionalTransferLight.sol";

/**
 * @title Constants used by tests for RuleEngineOwnable2Step
 */
abstract contract HelperContractOwnable2Step {
    address internal constant ZERO_ADDRESS = address(0);
    address internal constant OWNER_ADDRESS = address(1);
    address internal constant NEW_OWNER_ADDRESS = address(8);
    address internal constant ATTACKER = address(4);
    address internal constant CONDITIONAL_TRANSFER_OPERATOR_ADDRESS = address(9);

    RuleEngineOwnable2Step public ruleEngineMock;
    RuleConditionalTransferLight public ruleConditionalTransferLight;

    string internal constant ERC2771_FORWARDER_DOMAIN = "ERC2771ForwarderDomain";
}
