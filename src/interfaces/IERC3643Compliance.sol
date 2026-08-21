//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";
/* ==== Interface === */
import {ITokenBinding} from "./ITokenBinding.sol";

/**
 * @title IERC3643Compliance
 * @notice Compliance interface implemented by the RuleEngine for ERC-3643 tokens.
 * @dev Token binding (`bindToken`, `unbindToken`, `isTokenBound`, and the `TokenBound` /
 * `TokenUnbound` events) is inherited from the standard-agnostic {ITokenBinding}, so the
 * registry can be reused outside a compliance context. Only the ERC-3643 specific parts are
 * declared here.
 *
 * Security note: a "multi-tenant" setup means multiple token contracts share one RuleEngine
 * instance (all are bound via {ITokenBinding-bindToken}). ERC-3643 callbacks do not carry the
 * token address to rules, so stateful rules with per-address accounting are unsafe across
 * mutually untrusted tokens. In that setup, all bound tokens must be equally trusted and
 * governed together, and unbinding does not retroactively isolate rule state accumulated while
 * they were shared.
 */
interface IERC3643Compliance is IERC3643ComplianceRead, IERC3643IComplianceContract, ITokenBinding {
    /* ============ Functions ============ */
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

    /**
     * @notice Returns the single token currently bound to this compliance contract.
     * @dev If multiple tokens are supported, consider using getTokenBounds().
     * @return token The address of the currently bound token.
     */
    function getTokenBound() external view returns (address token);
}
