//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";

interface IERC3643Compliance is
    IERC3643ComplianceRead,
    IERC3643IComplianceContract
{
    /* ============ Events ============ */
    /**
     * @notice Emitted when a token is successfully bound to the compliance contract.
     * @param token The address of the token that was bound.
     */
    event TokenBound(address token);

    /**
     * @notice Emitted when a token is successfully unbound from the compliance contract.
     * @param token The address of the token that was unbound.
     */
    event TokenUnbound(address token);

    /* ============ Functions ============ */
    /**
     * @notice Associates a token contract with this compliance contract.
     * @dev The compliance contract may restrict operations on the bound token
     *      according to the compliance logic.
     *      Reverts if the token is already bound.
     *      Complexity: O(1).
     * @param token The address of the token to bind.
     */
    function bindToken(address token) external;

    /**
     * @notice Removes the association of a token contract from this compliance contract.
     * @dev Reverts if the token is not currently bound.
     * Complexity: O(1).
     * @param token The address of the token to unbind.
     */
    function unbindToken(address token) external;

    /**
     * @notice Checks whether a token is currently bound to this compliance contract.
     * @dev
     * Complexity: O(1).
     * Note that there are no guarantees on the ordering of values inside the array,
     * and it may change when more values are added or removed.
     * @param token The token address to verify.
     * @return isBound True if the token is bound, false otherwise.
     */
    function isTokenBound(address token) external view returns (bool isBound);

    /**
     * @notice Returns the single token currently bound to this compliance contract.
     * @dev If multiple tokens are supported, consider using getTokenBounds().
     * @return token The address of the currently bound token.
     */
    function getTokenBound() external view returns (address token);

    /**
     * @notice Returns all tokens currently bound to this compliance contract.
     * @dev This is a view-only function and does not modify state.
     * This function is not part of the original ERC-3643 specification
     * This operation will copy the entire storage to memory, which can be quite expensive.
     * This is designed to mostly be used by view accessors that are queried without any gas fees.
     * @return tokens An array of addresses of bound token contracts.
     */
    function getTokenBounds() external view returns (address[] memory tokens);

    /**
     * @notice Updates the compliance contract state when tokens are created (minted).
     * @dev Called by the token contract when new tokens are issued to an account.
     *      Reverts if the minting does not comply with the rules.
     * @param to The address receiving the minted tokens.
     * @param value The number of tokens created.
     */
    function created(address to, uint256 value) external;

    /**
     * @notice Updates the compliance contract state when tokens are destroyed (burned).
     * @dev Called by the token contract when tokens are redeemed or burned.
     *      Reverts if the burning does not comply with the rules.
     * @param from The address whose tokens are being destroyed.
     * @param value The number of tokens destroyed.
     */
    function destroyed(address from, uint256 value) external;
}
