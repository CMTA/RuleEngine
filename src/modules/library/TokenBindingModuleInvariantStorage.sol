// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title TokenBindingModuleInvariantStorage
 * @notice Holds the custom errors raised by the token binding module.
 * @dev Standard-agnostic: these errors describe the binding registry itself, not the
 * compliance standard built on top of it. Reused as-is by any project embedding
 * {TokenBindingModule}.
 */
abstract contract TokenBindingModuleInvariantStorage {
    /* ==== Errors === */
    /// @notice Thrown when the zero address is passed as a token to bind or to approve.
    error TokenBinding_InvalidTokenAddress();
    /// @notice Thrown when binding a token that is already bound.
    error TokenBinding_TokenAlreadyBound();
    /// @notice Thrown when unbinding a token that is not currently bound.
    error TokenBinding_TokenNotBound();
    /// @notice Thrown when a caller that is not a bound token calls a bound-token entry point.
    error TokenBinding_UnauthorizedCaller();
}
