// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

/**
 * @dev Test-only subset interface used to validate the advertised ERC-165 ID.
 * ERC-7551 is draft and this interface contains only the compliance method
 * currently implemented by RuleEngine.
 */
interface IERC7551ComplianceSubset {
    function canTransferFrom(address spender, address from, address to, uint256 value) external view returns (bool);
}
