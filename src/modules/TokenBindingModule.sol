//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
/* ==== Interface and other library === */
import {ITokenBinding} from "../interfaces/ITokenBinding.sol";
import {TokenBindingModuleInvariantStorage} from "./library/TokenBindingModuleInvariantStorage.sol";

/**
 * @title TokenBindingModule
 * @notice Standard-agnostic token binding registry (an allowlist) implementing {ITokenBinding}:
 * it stores the set of tokens allowed to call the bound-token entry points of the contract
 * embedding it.
 * @dev This module deliberately knows nothing about ERC-3643, ERC-1404, rules or the RuleEngine.
 * It only depends on OpenZeppelin's {Context} and {EnumerableSet}, so it can be reused as-is by
 * any project that has to bind tokens. It provides:
 *  - the allowlist storage and `bindToken` / `unbindToken` / `isTokenBound`;
 *  - the {onlyBoundToken} modifier gating the bound-token entry points;
 *  - two access control hooks left to the deployment: {_authorizeTokenBindingChange}, which
 *    authorizes a bind/unbind, and {_onlyTokenBindingManager}, the manager check it defaults to.
 *
 * The ERC-3643 vocabulary (`compliance`, `getTokenBound`, `created` / `destroyed`) lives in
 * {ERC3643ComplianceModule}, which is a thin adapter over this module.
 */
abstract contract TokenBindingModule is Context, ITokenBinding, TokenBindingModuleInvariantStorage {
    /* ==== Type declaration === */
    using EnumerableSet for EnumerableSet.AddressSet;

    /* ==== State Variables === */
    // Token binding tracking
    /**
     * @notice Set of tokens allowed to call the bound-token entry points.
     */
    EnumerableSet.AddressSet internal _boundTokens;

    /* ==== Modifier === */
    /**
     * @dev Restricts a function to the tokens currently bound.
     */
    modifier onlyBoundToken() {
        _checkBoundToken();
        _;
    }

    /**
     * @dev Restricts a function to the account allowed to manage the bindings.
     */
    modifier onlyTokenBindingManager() {
        _onlyTokenBindingManager();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/public FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State functions ============ */
    /**
     * @inheritdoc ITokenBinding
     * @dev Authorized by {_authorizeTokenBindingChange}.
     * @custom:security-note "Multi-tenant" means one instance is shared by multiple token
     * contracts. Downstream state (for the RuleEngine: the per-address accounting held by
     * stateful rules) is shared across all bound tokens, so binding tokens from different
     * issuers silently cross-contaminates it. Only bind tokens that are equally trusted and
     * governed together.
     */
    function bindToken(address token) public virtual override {
        _authorizeTokenBindingChange(token);
        _bindToken(token);
    }

    /**
     * @inheritdoc ITokenBinding
     * @dev Authorized by {_authorizeTokenBindingChange}.
     * Operator warning: unbinding is an administrative operation and does not erase any state
     * already stored downstream in a previously shared ("multi-tenant") setup.
     */
    function unbindToken(address token) public virtual override {
        _authorizeTokenBindingChange(token);
        _unbindToken(token);
    }

    /* ============ View functions ============ */
    /// @inheritdoc ITokenBinding
    function isTokenBound(address token) public view virtual override returns (bool) {
        return _boundTokens.contains(token);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Adds a token to the bound set.
     * @param token The token to bind; reverts on the zero address or when already bound.
     */
    function _bindToken(address token) internal virtual {
        require(token != address(0), TokenBinding_InvalidTokenAddress());
        // add() returns false when the token is already bound, so a separate
        // contains() lookup is unnecessary.
        require(_boundTokens.add(token), TokenBinding_TokenAlreadyBound());
        emit TokenBound(token);
    }

    /**
     * @dev Removes a token from the bound set.
     * @param token The token to unbind; reverts when it is not currently bound.
     */
    function _unbindToken(address token) internal virtual {
        // remove() returns false when the token was not bound, so a separate
        // contains() lookup is unnecessary.
        require(_boundTokens.remove(token), TokenBinding_TokenNotBound());

        emit TokenUnbound(token);
    }

    /**
     * @dev Authorization hook for bind/unbind, receiving the token being bound or unbound.
     * Defaults to the binding manager check, which ignores the token; {TokenBindingExtendedModule}
     * overrides it to also allow approved token self-calls.
     */
    function _authorizeTokenBindingChange(
        address /* token */
    )
        internal
        virtual
    {
        _onlyTokenBindingManager();
    }

    /**
     * @dev Access control hook guarding binding management operations, implemented by the
     * deployable contracts.
     */
    function _onlyTokenBindingManager() internal virtual;

    /**
     * @dev Reverts when the caller is not a bound token.
     */
    function _checkBoundToken() internal view virtual {
        if (!_boundTokens.contains(_msgSender())) {
            revert TokenBinding_UnauthorizedCaller();
        }
    }
}
