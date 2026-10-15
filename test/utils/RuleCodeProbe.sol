// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {RuleInterfaceId} from "src/modules/library/RuleInterfaceId.sol";

/**
 * @title RuleCodeProbe
 * @notice Test-only rule whose answers are set by the test: the restriction code of each view path, the code
 * it claims and the message for it. Used to pin how the engine aggregates several rules.
 * @dev The 3-argument and 4-argument paths have separate codes so a test can tell which path the engine used.
 * Each `transferred` overload reverts with the code of its own path when that code is non-zero.
 * Implements only `IRule`, with no `canTransfer` / `canTransferFrom`: an engine-only rule, which the narrowed
 * interface accepts (rc7 code-quality review `I-1`).
 */
contract RuleCodeProbe is IRule, ERC165 {
    error RuleCodeProbe_Rejected(uint8 code);

    uint8 public code;
    uint8 public codeFrom;
    uint8 public immutable CLAIMED_CODE;
    string public message;

    constructor(uint8 claimedCode, string memory message_) {
        CLAIMED_CODE = claimedCode;
        message = message_;
    }

    function setCodes(uint8 code_, uint8 codeFrom_) external {
        code = code_;
        codeFrom = codeFrom_;
    }

    function transferred(address, address, uint256) external view override {
        require(code == 0, RuleCodeProbe_Rejected(code));
    }

    function transferred(address, address, address, uint256) external view override {
        require(codeFrom == 0, RuleCodeProbe_Rejected(codeFrom));
    }

    function detectTransferRestriction(address, address, uint256) external view override returns (uint8) {
        return code;
    }

    function detectTransferRestrictionFrom(address, address, address, uint256) external view override returns (uint8) {
        return codeFrom;
    }

    function canReturnTransferRestrictionCode(uint8 restrictionCode) external view override returns (bool) {
        return restrictionCode == CLAIMED_CODE;
    }

    function messageForTransferRestriction(uint8 restrictionCode) external view override returns (string memory) {
        return restrictionCode == CLAIMED_CODE ? message : "RuleCodeProbe: unclaimed code";
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == RuleInterfaceId.IRULE_INTERFACE_ID || ERC165.supportsInterface(interfaceId);
    }
}
