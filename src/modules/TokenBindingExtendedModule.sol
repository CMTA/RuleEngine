//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

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
                            PUBLIC/public FUNCTIONS
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
        _tokenSelfBindingApproval[token] = approved;
        emit TokenSelfBindingApprovalSet(token, approved);
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
     * @dev Authorizes bind/unbind operations.
     * Allows the binding manager, or approved token self-calls (used by ERC-3643 `setCompliance`).
     * @param token The token being bound or unbound.
     */
    function _authorizeTokenBindingChange(address token) internal virtual override {
        if (_msgSender() == token && _tokenSelfBindingApproval[token]) {
            return;
        }
        _onlyTokenBindingManager();
    }
}
