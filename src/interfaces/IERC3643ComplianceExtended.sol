//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC3643Compliance} from "./IERC3643Compliance.sol";

interface IERC3643ComplianceExtended is IERC3643Compliance {
    /**
     * @notice Emitted when self-binding permission is updated for a token.
     * @param token The token address whose self-binding permission changed.
     * @param approved True if token self-bind/unbind is allowed, false otherwise.
     */
    event TokenSelfBindingApprovalSet(address token, bool approved);
    /**
     * @notice Emitted when self-binding permission is updated in batch.
     * @param tokens The token addresses whose self-binding permission changed.
     * @param approved True if token self-bind/unbind is allowed, false otherwise.
     */
    event TokenSelfBindingApprovalBatchSet(address[] tokens, bool approved);

    /**
     * @notice Associates multiple token contracts with this compliance contract.
     * @dev This function is not part of the original ERC-3643 compliance interface.
     * Must be restricted by implementation-specific compliance manager access control.
     * Reverts if any token is invalid or already bound.
     * @param tokens The token addresses to bind.
     */
    function bindTokens(address[] calldata tokens) external;

    /**
     * @notice Removes the association of multiple token contracts from this compliance contract.
     * @dev This function is not part of the original ERC-3643 compliance interface.
     * Must be restricted by implementation-specific compliance manager access control.
     * Reverts if any token is not currently bound.
     * @param tokens The token addresses to unbind.
     */
    function unbindTokens(address[] calldata tokens) external;

    /**
     * @notice Sets whether a token is allowed to self-bind and self-unbind.
     * @dev This function is not part of the original ERC-3643 compliance interface.
     * Must be restricted by implementation-specific compliance manager access control.
     * @param token The token address to configure.
     * @param approved Whether self-binding is approved for `token`.
     */
    function setTokenSelfBindingApproval(address token, bool approved) external;

    /**
     * @notice Sets self-binding approval for multiple tokens in one transaction.
     * @dev This function is not part of the original ERC-3643 compliance interface.
     * Must be restricted by implementation-specific compliance manager access control.
     * Reverts if any token in `tokens` is the zero address.
     * @param tokens The token addresses to configure.
     * @param approved Whether self-binding is approved for all provided tokens.
     */
    function setTokenSelfBindingApprovalBatch(address[] calldata tokens, bool approved) external;

    /**
     * @notice Returns whether a token is approved to self-bind and self-unbind.
     * @dev This function is not part of the original ERC-3643 compliance interface.
     * @param token The token address to query.
     * @return approved True if self-binding is approved for `token`, false otherwise.
     */
    function isTokenSelfBindingApproved(address token) external view returns (bool approved);

    /**
     * @notice Returns all tokens currently bound to this compliance contract.
     * @dev This function is not part of the original ERC-3643 compliance interface.
     * This operation copies the entire storage set to memory and is mainly intended for off-chain reads.
     * @return tokens An array of bound token addresses.
     */
    function getTokenBounds() external view returns (address[] memory tokens);
}
