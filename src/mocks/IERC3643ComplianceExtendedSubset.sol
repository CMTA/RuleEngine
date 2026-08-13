// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

/**
 * @title IERC3643ComplianceExtendedSubset
 * @dev Test-only subset of the extended ERC-3643 compliance interface, used to validate
 * the advertised ERC-165 interface ID.
 */
interface IERC3643ComplianceExtendedSubset {
    /**
     * @notice Binds several token contracts in a single call.
     * @param tokens The token addresses to bind.
     */
    function bindTokens(address[] calldata tokens) external;

    /**
     * @notice Unbinds several token contracts in a single call.
     * @param tokens The token addresses to unbind.
     */
    function unbindTokens(address[] calldata tokens) external;

    /**
     * @notice Allows or forbids a token to bind and unbind itself.
     * @param token The token whose self-binding permission is updated.
     * @param approved True to allow self-binding, false to forbid it.
     */
    function setTokenSelfBindingApproval(address token, bool approved) external;

    /**
     * @notice Updates the self-binding permission of several tokens at once.
     * @param tokens The token addresses whose permission is updated.
     * @param approved True to allow self-binding, false to forbid it.
     */
    function setTokenSelfBindingApprovalBatch(address[] calldata tokens, bool approved) external;

    /**
     * @notice Tells whether a token may bind and unbind itself.
     * @param token The token address to check.
     * @return approved True if the token is allowed to self-bind, false otherwise.
     */
    function isTokenSelfBindingApproved(address token) external view returns (bool approved);

    /**
     * @notice Returns every token currently bound to the compliance contract.
     * @return tokens The list of bound token addresses.
     */
    function getTokenBounds() external view returns (address[] memory tokens);
}
