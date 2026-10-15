//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.27;

import {ITokenBinding} from "./ITokenBinding.sol";

/**
 * @title ITokenBindingExtended
 * @notice Extends the token binding registry with batch operations, token self-binding
 * and enumeration of the bound tokens.
 * @dev Standard-agnostic, see {ITokenBinding}. None of these functions belongs to a token
 * standard: they are conveniences of the registry itself.
 */
interface ITokenBindingExtended is ITokenBinding {
    /* ============ Events ============ */
    /**
     * @notice Emitted by {setTokenSelfBindingApproval} when self-binding permission is set for a token.
     * @dev Emitted on every call, also when `approved` equals the current value. Not emitted by
     * {setTokenSelfBindingApprovalBatch}, which emits {TokenSelfBindingApprovalBatchSet} instead: a consumer
     * reconstructing the approvals, or filtering on `token`, must handle both events, or read
     * {isTokenSelfBindingApproved}, which is authoritative.
     * @param token The token address whose self-binding permission was set.
     * @param approved True if token self-bind/unbind is allowed, false otherwise.
     */
    event TokenSelfBindingApprovalSet(address indexed token, bool approved);

    /**
     * @notice Emitted once by {setTokenSelfBindingApprovalBatch}, with the input array.
     * @dev `tokens` is the array as passed: it may contain tokens already at `approved` and duplicates, and is
     * empty for an empty batch, so it lists the tokens that were set, not only those that changed. No
     * {TokenSelfBindingApprovalSet} is emitted per token, so a filter on that event's indexed `token` does not
     * see batch updates. `tokens` is not indexed: an indexed array is stored as a hash and cannot be filtered
     * per token.
     * @param tokens The token addresses whose self-binding permission was set, as passed to the call.
     * @param approved True if token self-bind/unbind is allowed, false otherwise.
     */
    event TokenSelfBindingApprovalBatchSet(address[] tokens, bool approved);

    /* ============ Functions ============ */
    /**
     * @notice Binds several token contracts in a single call.
     * @dev Must be restricted by implementation-specific access control.
     * Atomic: reverts if any token is invalid or already bound (or listed twice), and then binds none of them.
     * This deliberately departs from the usual batch convention of skipping elements already in the target
     * state: a binding change is security-relevant, and a token that is already bound in the list is most
     * likely an operator mistake that should stop the whole operation. An empty array is a no-op.
     * @param tokens The token addresses to bind.
     */
    function bindTokens(address[] calldata tokens) external;

    /**
     * @notice Unbinds several token contracts in a single call.
     * @dev Must be restricted by implementation-specific access control.
     * Atomic: reverts if any token is not currently bound, and then unbinds none of them. Deliberately not
     * the skip-if-already-done batch convention, for the same reason as {bindTokens}. An empty array is a no-op.
     * @param tokens The token addresses to unbind.
     */
    function unbindTokens(address[] calldata tokens) external;

    /**
     * @notice Sets whether a token is allowed to bind and unbind itself.
     * @dev Must be restricted by implementation-specific access control.
     * @param token The token address to configure.
     * @param approved Whether self-binding is approved for `token`.
     */
    function setTokenSelfBindingApproval(address token, bool approved) external;

    /**
     * @notice Sets self-binding approval for multiple tokens in one transaction.
     * @dev Must be restricted by implementation-specific access control.
     * Reverts if any token in `tokens` is the zero address. Emits a single {TokenSelfBindingApprovalBatchSet}
     * with the input array, not one {TokenSelfBindingApprovalSet} per token.
     * @param tokens The token addresses to configure.
     * @param approved Whether self-binding is approved for all provided tokens.
     */
    function setTokenSelfBindingApprovalBatch(address[] calldata tokens, bool approved) external;

    /**
     * @notice Returns whether a token is approved to bind and unbind itself.
     * @param token The token address to query.
     * @return approved True if self-binding is approved for `token`, false otherwise.
     */
    function isTokenSelfBindingApproved(address token) external view returns (bool approved);

    /**
     * @notice Returns all tokens currently bound.
     * @dev This operation copies the entire storage set to memory and is mainly intended for
     * off-chain reads.
     * @return tokens An array of bound token addresses.
     */
    function getTokenBounds() external view returns (address[] memory tokens);
}
