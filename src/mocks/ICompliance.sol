// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

/**
 * @title ICompliance
 * @notice Reference ERC-3643 compliance interface used by the mocks and tests.
 */
interface ICompliance {
    /**
     * @notice Emitted when a token is bound to the compliance contract.
     * @param _token The address of the token that was bound.
     */
    event TokenBound(address _token);

    /**
     * @notice Emitted when a token is unbound from the compliance contract.
     * @param _token The address of the token that was unbound.
     */
    event TokenUnbound(address _token);

    /**
     * @notice Binds a token contract to this compliance contract.
     * @param _token The address of the token to bind.
     */
    function bindToken(address _token) external;

    /**
     * @notice Unbinds a token contract from this compliance contract.
     * @param _token The address of the token to unbind.
     */
    function unbindToken(address _token) external;

    /**
     * @notice Updates the compliance state after a transfer has been executed.
     * @param _from The address the tokens were sent from.
     * @param _to The address the tokens were sent to.
     * @param _amount The number of tokens transferred.
     */
    function transferred(address _from, address _to, uint256 _amount) external;

    /**
     * @notice Updates the compliance state after tokens have been minted.
     * @param _to The address receiving the minted tokens.
     * @param _amount The number of tokens created.
     */
    function created(address _to, uint256 _amount) external;

    /**
     * @notice Updates the compliance state after tokens have been burned.
     * @param _from The address whose tokens were destroyed.
     * @param _amount The number of tokens destroyed.
     */
    function destroyed(address _from, uint256 _amount) external;

    /**
     * @notice Checks whether a token is currently bound to this compliance contract.
     * @param _token The token address to verify.
     * @return True if the token is bound, false otherwise.
     */
    function isTokenBound(address _token) external view returns (bool);

    /**
     * @notice Returns the token currently bound to this compliance contract.
     * @return The address of the bound token.
     */
    function getTokenBound() external view returns (address);

    /**
     * @notice Checks whether a transfer complies with the configured rules.
     * @param _from The address the tokens would be sent from.
     * @param _to The address the tokens would be sent to.
     * @param _amount The number of tokens to transfer.
     * @return True if the transfer is allowed, false otherwise.
     */
    function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool);
}
