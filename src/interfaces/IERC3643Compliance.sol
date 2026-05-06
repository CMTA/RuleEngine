//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";

interface IERC3643Compliance is IERC3643ComplianceRead, IERC3643IComplianceContract {
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
     *      Security note: a "multi-tenant" setup means multiple token contracts
     *      share one RuleEngine instance (all are bound via {bindToken}).
     *      In that setup, all bound tokens must be equally trusted and governed together.
     *      ERC-3643 callbacks do not carry the token address to rules, so stateful
     *      rules with per-address accounting are unsafe across mutually untrusted tokens.
     *      Reverts if the token is already bound.
     *      Complexity: O(1).
     * @param token The address of the token to bind.
     */
    function bindToken(address token) external;

    /**
     * @notice Removes the association of a token contract from this compliance contract.
     * @dev Security note: unbinding does not retroactively isolate rule state from
     *      previously shared multi-token operation. "Multi-tenant" means one RuleEngine
     *      shared by multiple token contracts. Avoid multi-tenant binding unless
     *      all tokens are equally trusted and governed together.
     *      Reverts if the token is not currently bound.
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
