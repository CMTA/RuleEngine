//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.27;

/* ==== OpenZeppelin === */
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
/* ==== Interface and other library === */
import {ITokenBindingExtended} from "../interfaces/ITokenBindingExtended.sol";
import {TokenBindingModule} from "./TokenBindingModule.sol";

/**
 * @title TokenBindingExtendedModule
 * @notice Extends the standard-agnostic {TokenBindingModule} with batch binding, token
 * self-binding and enumeration of the bound tokens.
 * @dev Like its parent, this module carries no token-standard semantics: self-binding exists
 * because a token contract may want to register itself (as ERC-3643 `setCompliance` does), but
 * nothing here is specific to ERC-3643.
 */
abstract contract TokenBindingExtendedModule is TokenBindingModule, ITokenBindingExtended {
    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @notice Tracks which tokens are allowed to bind and unbind themselves.
     */
    mapping(address token => bool approved) private _tokenSelfBindingApproval;

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State functions ============ */
    /**
     * @inheritdoc ITokenBindingExtended
     * @custom:security-note See {bindToken} for multi-tenant state risks. All tokens bound
     * in this batch share the same downstream state. Only bind tokens that are equally trusted
     * and governed together.
     */
    function bindTokens(address[] calldata tokens) public virtual override onlyTokenBindingManager {
        for (uint256 i = 0; i < tokens.length; ++i) {
            _bindToken(tokens[i]);
        }
    }

    /// @inheritdoc ITokenBindingExtended
    function unbindTokens(address[] calldata tokens) public virtual override onlyTokenBindingManager {
        for (uint256 i = 0; i < tokens.length; ++i) {
            _unbindToken(tokens[i]);
        }
    }

    /// @inheritdoc ITokenBindingExtended
    function setTokenSelfBindingApproval(address token, bool approved) public virtual override onlyTokenBindingManager {
        require(token != address(0), TokenBinding_InvalidTokenAddress());
        _setTokenSelfBindingApproval(token, approved);
    }

    /// @inheritdoc ITokenBindingExtended
    function setTokenSelfBindingApprovalBatch(address[] calldata tokens, bool approved)
        public
        virtual
        override
        onlyTokenBindingManager
    {
        for (uint256 i = 0; i < tokens.length; ++i) {
            address token = tokens[i];
            require(token != address(0), TokenBinding_InvalidTokenAddress());
            _tokenSelfBindingApproval[token] = approved;
        }
        emit TokenSelfBindingApprovalBatchSet(tokens, approved);
    }

    /* ============ View functions ============ */
    /// @inheritdoc ITokenBindingExtended
    function isTokenSelfBindingApproved(address token) public view virtual override returns (bool) {
        return _tokenSelfBindingApproval[token];
    }

    /// @inheritdoc ITokenBindingExtended
    function getTokenBounds() public view virtual override returns (address[] memory) {
        return _boundTokens.values();
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Removes a token from the bound set and, when the caller is not the token itself, revokes its
     * self-binding approval. Without the revocation, a token approved for self-binding could bind itself again
     * right after the binding manager unbound it, overriding the manager's decision. A token unbinding itself
     * (ERC-3643 `setCompliance` moving to another compliance contract) keeps its approval, so it can come back.
     * Covers both {unbindToken} and {unbindTokens}. Like the token self-binding check, the caller is the raw
     * `msg.sender`, so a manager call relayed by the ERC-2771 forwarder also revokes the approval.
     * @param token The token to unbind; reverts when it is not currently bound.
     */
    function _unbindToken(address token) internal virtual override {
        TokenBindingModule._unbindToken(token);
        if (msg.sender != token && _tokenSelfBindingApproval[token]) {
            _setTokenSelfBindingApproval(token, false);
        }
    }

    /**
     * @dev Writes a token's self-binding approval and emits {TokenSelfBindingApprovalSet}. Single write path for
     * the per-token event; the batch setter emits {TokenSelfBindingApprovalBatchSet} instead.
     * @param token The token whose approval is set.
     * @param approved Whether the token may bind and unbind itself.
     */
    function _setTokenSelfBindingApproval(address token, bool approved) internal virtual {
        _tokenSelfBindingApproval[token] = approved;
        emit TokenSelfBindingApprovalSet(token, approved);
    }

    /**
     * @dev Authorizes bind/unbind operations.
     * Allows the binding manager, or approved token self-calls (used by ERC-3643 `setCompliance`).
     * IMPORTANT: the token self-call is identified by the raw `msg.sender`, not the ERC-2771
     * `_msgSender()`: a token calls `bindToken` / `unbindToken` on itself directly from
     * `setCompliance`, never through a forwarder. Otherwise the trusted forwarder could append an
     * approved token's address and unbind it. The manager path (`_onlyTokenBindingManager`) keeps
     * `_msgSender()`, so binding administration remains relayable.
     * @param token The token being bound or unbound.
     */
    function _authorizeTokenBindingChange(address token) internal virtual override {
        if (msg.sender == token && _tokenSelfBindingApproval[token]) {
            return;
        }
        _onlyTokenBindingManager();
    }
}
