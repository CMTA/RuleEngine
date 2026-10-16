// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {RuleInterfaceId} from "src/modules/library/RuleInterfaceId.sol";

/**
 * @title RevertingViewRule
 * @notice Test-only rule whose enforcement hooks accept every operation while every view reverts. Used to show
 * that the engine's ERC-1404 / ERC-3643 views propagate a rule's revert instead of returning a code, and that
 * the views and the enforcement path can then disagree (security review, threat RE-2).
 */
contract RevertingViewRule is IRule, ERC165 {
    error RevertingViewRule_ViewReverted();

    function transferred(address, address, uint256) external pure override {}

    function transferred(address, address, address, uint256) external pure override {}

    function detectTransferRestriction(address, address, uint256) external pure override returns (uint8) {
        revert RevertingViewRule_ViewReverted();
    }

    function detectTransferRestrictionFrom(address, address, address, uint256) external pure override returns (uint8) {
        revert RevertingViewRule_ViewReverted();
    }

    function canReturnTransferRestrictionCode(uint8) external pure override returns (bool) {
        revert RevertingViewRule_ViewReverted();
    }

    function messageForTransferRestriction(uint8) external pure override returns (string memory) {
        revert RevertingViewRule_ViewReverted();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == RuleInterfaceId.IRULE_INTERFACE_ID || ERC165.supportsInterface(interfaceId);
    }
}
