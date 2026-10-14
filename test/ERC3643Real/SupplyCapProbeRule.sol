// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {RuleInterfaceId} from "src/modules/library/RuleInterfaceId.sol";

/**
 * @title SupplyCapProbeRule
 * @notice CMTAT-style supply cap (`totalSupply() + value <= cap` on mint), used to observe *when* the real
 * ERC-3643 token notifies compliance. CMTAT calls the engine before the mint, so the check projects the
 * pending amount once. T-REX calls `created` after `_mint`, so the same check counts the amount twice.
 * @dev Test-only probe, not a production rule.
 */
contract SupplyCapProbeRule is IRule {
    uint8 public constant CODE_CAP_EXCEEDED = 50;

    IERC20 public immutable TOKEN;
    uint256 public immutable CAP;

    error SupplyCapProbeRule_CapExceeded(uint256 supply, uint256 value, uint256 cap);

    /**
     * @param token_ The token whose supply is read.
     * @param cap_ The maximum total supply.
     */
    constructor(IERC20 token_, uint256 cap_) {
        TOKEN = token_;
        CAP = cap_;
    }

    /* ============ State-changing ============ */

    /// @dev See {IRule}.
    function transferred(address from, address to, uint256 value) external view override {
        _revertIfRestricted(from, to, value);
    }

    /// @dev See {IRule}.
    function transferred(address, address from, address to, uint256 value) external view override {
        _revertIfRestricted(from, to, value);
    }

    /* ============ View ============ */

    /// @dev See {IRule}.
    function canReturnTransferRestrictionCode(uint8 restrictionCode) external pure override returns (bool) {
        return restrictionCode == CODE_CAP_EXCEEDED;
    }

    /// @dev See {IRule}.
    function messageForTransferRestriction(uint8 restrictionCode) external pure override returns (string memory) {
        return restrictionCode == CODE_CAP_EXCEEDED ? "SupplyCapProbeRule: cap exceeded" : "No restriction";
    }

    /// @dev See {IRule}.
    function canTransfer(address from, address to, uint256 value) external view override returns (bool) {
        return detectTransferRestriction(from, to, value) == 0;
    }

    /// @dev See {IRule}.
    function canTransferFrom(address, address from, address to, uint256 value) external view override returns (bool) {
        return detectTransferRestriction(from, to, value) == 0;
    }

    /// @dev See {IRule}.
    function detectTransferRestrictionFrom(address, address from, address to, uint256 value)
        external
        view
        override
        returns (uint8)
    {
        return detectTransferRestriction(from, to, value);
    }

    /// @dev See {IERC165}.
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == RuleInterfaceId.IRULE_INTERFACE_ID || interfaceId == type(IERC165).interfaceId;
    }

    /// @dev See {IRule}.
    function detectTransferRestriction(address from, address, uint256 value) public view override returns (uint8) {
        if (from == address(0) && TOKEN.totalSupply() + value > CAP) {
            return CODE_CAP_EXCEEDED;
        }
        return 0;
    }

    function _revertIfRestricted(address from, address to, uint256 value) internal view virtual {
        require(
            detectTransferRestriction(from, to, value) == 0,
            SupplyCapProbeRule_CapExceeded(TOKEN.totalSupply(), value, CAP)
        );
    }
}
