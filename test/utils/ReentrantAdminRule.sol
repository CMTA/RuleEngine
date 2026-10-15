// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {IRulesManagementModule} from "src/interfaces/IRulesManagementModule.sol";
import {RuleInterfaceId} from "src/modules/library/RuleInterfaceId.sol";

/**
 * @title ReentrantAdminRule
 * @notice Test-only rule that, when the engine calls its `transferred` hook, calls back into the engine to add
 * another rule. Used to show that a rule cannot reconfigure the engine from inside a callback, because rule
 * accounts hold no role and no ownership (security review, threats RE-4 and AC-2).
 */
contract ReentrantAdminRule is IRule, ERC165 {
    IRulesManagementModule public immutable ENGINE;
    IRule public immutable RULE_TO_ADD;

    constructor(IRulesManagementModule engine, IRule ruleToAdd) {
        ENGINE = engine;
        RULE_TO_ADD = ruleToAdd;
    }

    function transferred(address, address, uint256) external override {
        ENGINE.addRule(RULE_TO_ADD);
    }

    function transferred(address, address, address, uint256) external override {
        ENGINE.addRule(RULE_TO_ADD);
    }

    function detectTransferRestriction(address, address, uint256) external pure override returns (uint8) {
        return 0;
    }

    function detectTransferRestrictionFrom(address, address, address, uint256) external pure override returns (uint8) {
        return 0;
    }

    function canReturnTransferRestrictionCode(uint8) external pure override returns (bool) {
        return false;
    }

    function messageForTransferRestriction(uint8) external pure override returns (string memory) {
        return "";
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == RuleInterfaceId.IRULE_INTERFACE_ID || ERC165.supportsInterface(interfaceId);
    }
}
