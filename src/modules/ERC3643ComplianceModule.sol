//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
/* ==== Interface and other library === */
import {IERC3643Compliance} from "../interfaces/IERC3643Compliance.sol";
import {ERC3643ComplianceModuleInvariantStorage} from "./library/ERC3643ComplianceModuleInvariantStorage.sol";

/**
 * @title ERC3643ComplianceModule
 * @notice Core ERC-3643 compliance module: tracks the tokens bound to this engine.
 */
abstract contract ERC3643ComplianceModule is Context, IERC3643Compliance, ERC3643ComplianceModuleInvariantStorage {
    /* ==== Type declaration === */
    using EnumerableSet for EnumerableSet.AddressSet;
    /* ==== State Variables === */
    // Token binding tracking
    /**
     * @notice Set of tokens allowed to call the compliance callbacks.
     */
    EnumerableSet.AddressSet internal _boundTokens;

    /* ==== Modifier === */
    modifier onlyBoundToken() {
        _checkBoundToken();
        _;
    }

    modifier onlyComplianceManager() {
        _onlyComplianceManager();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/public FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State functions ============ */
    /**
     * @inheritdoc IERC3643Compliance
     * @dev Operator warning: "multi-tenant" means one RuleEngine is shared by
     * multiple token contracts. In that setup, bind only tokens that are equally
     * trusted and governed together.
     * @custom:security-note Operation rules (stateful rules such as `RuleConditionalTransferLight`
     * or `RuleMintAllowance`) maintain per-address accounting that is shared across all bound tokens.
     * Binding tokens from different issuers to the same engine will silently cross-contaminate
     * their accounting. Only bind tokens that are equally trusted and governed together.
     */
    function bindToken(address token) public virtual override {
        _authorizeComplianceBindingChange(token);
        _bindToken(token);
    }

    /**
     * @inheritdoc IERC3643Compliance
     * @dev Operator warning: unbinding is an administrative operation and does not
     * erase any state already stored by external rule contracts in a previously
     * shared ("multi-tenant") setup.
     */
    function unbindToken(address token) public virtual override {
        _authorizeComplianceBindingChange(token);
        _unbindToken(token);
    }

    /// @inheritdoc IERC3643Compliance
    function isTokenBound(address token) public view virtual override returns (bool) {
        return _boundTokens.contains(token);
    }

    /// @inheritdoc IERC3643Compliance
    function getTokenBound() public view virtual override returns (address) {
        if (_boundTokens.length() > 0) {
            // Note that there are no guarantees on the ordering of values inside the array,
            // and it may change when more values are added or removed.
            return _boundTokens.pos(0);
        } else {
            return address(0);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Removes a token from the bound set.
     * @param token The token to unbind; reverts when it is not currently bound.
     */
    function _unbindToken(address token) internal virtual {
        // remove() returns false when the token was not bound, so a separate
        // contains() lookup is unnecessary.
        require(_boundTokens.remove(token), RuleEngine_ERC3643Compliance_TokenNotBound());

        emit TokenUnbound(token);
    }

    /**
     * @dev Adds a token to the bound set.
     * @param token The token to bind; reverts on the zero address or when already bound.
     */
    function _bindToken(address token) internal virtual {
        require(token != address(0), RuleEngine_ERC3643Compliance_InvalidTokenAddress());
        // add() returns false when the token is already bound, so a separate
        // contains() lookup is unnecessary.
        require(_boundTokens.add(token), RuleEngine_ERC3643Compliance_TokenAlreadyBound());
        emit TokenBound(token);
    }

    /**
     * @dev Authorization hook for bind/unbind, implemented by the deployable contracts.
     * @param token The token being bound or unbound.
     */
    function _authorizeComplianceBindingChange(address token) internal virtual;

    /**
     * @dev Access control hook guarding compliance management operations.
     */
    function _onlyComplianceManager() internal virtual;

    /**
     * @dev Reverts when the caller is not a bound token.
     */
    function _checkBoundToken() internal view virtual {
        if (!_boundTokens.contains(_msgSender())) {
            revert RuleEngine_ERC3643Compliance_UnauthorizedCaller();
        }
    }
}
