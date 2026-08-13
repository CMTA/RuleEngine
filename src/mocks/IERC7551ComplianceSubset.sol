// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

/**
 * @dev Test-only subset interface used to validate the advertised ERC-165 ID.
 * ERC-7551 is draft and this interface contains only the compliance method
 * currently implemented by RuleEngine.
 */
interface IERC7551ComplianceSubset {
    /**
     * @notice Tells whether a spender-initiated transfer is allowed.
     * @param spender The account moving the tokens on behalf of `from`.
     * @param from The origin address.
     * @param to The destination address.
     * @param value The number of tokens to transfer.
     * @return True if the transfer is allowed, false otherwise.
     */
    function canTransferFrom(address spender, address from, address to, uint256 value) external view returns (bool);
}
