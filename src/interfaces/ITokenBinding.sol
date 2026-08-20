//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title ITokenBinding
 * @notice Minimal token binding registry: the set of token contracts allowed to call back
 * into the contract implementing this interface.
 * @dev Standard-agnostic. It carries no ERC-3643, ERC-1404 or RuleEngine semantics, so it can
 * be reused by any engine (compliance, document, transfer...) that has to maintain an allowlist
 * of tokens. The ERC-3643 specific part lives in {IERC3643Compliance}, which extends this
 * interface.
 */
interface ITokenBinding {
    /* ============ Events ============ */
    /**
     * @notice Emitted when a token is successfully bound.
     * @param token The address of the token that was bound.
     */
    event TokenBound(address token);

    /**
     * @notice Emitted when a token is successfully unbound.
     * @param token The address of the token that was unbound.
     */
    event TokenUnbound(address token);

    /* ============ Functions ============ */
    /**
     * @notice Binds a token contract, allowing it to call the bound-token entry points.
     * @dev Must be restricted by implementation-specific access control.
     *      Reverts on the zero address and if the token is already bound.
     *      Security note: every bound token shares the same contract state. A "multi-tenant"
     *      setup, where several token contracts are bound to the same instance, is only safe
     *      when all bound tokens are equally trusted and governed together, since the
     *      bound-token entry points do not necessarily carry the calling token address to the
     *      downstream logic.
     *      Complexity: O(1).
     * @param token The address of the token to bind.
     */
    function bindToken(address token) external;

    /**
     * @notice Unbinds a token contract, revoking its access to the bound-token entry points.
     * @dev Must be restricted by implementation-specific access control.
     *      Reverts if the token is not currently bound.
     *      Security note: unbinding is an administrative operation. It does not erase any state
     *      already accumulated for that token by the downstream logic.
     *      Complexity: O(1).
     * @param token The address of the token to unbind.
     */
    function unbindToken(address token) external;

    /**
     * @notice Checks whether a token is currently bound.
     * @dev Complexity: O(1).
     * @param token The token address to verify.
     * @return isBound True if the token is bound, false otherwise.
     */
    function isTokenBound(address token) external view returns (bool isBound);
}
