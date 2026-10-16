// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.30;

/**
 * @title IdentityRegistryStub
 * @notice Minimal identity registry for the real ERC-3643 token: answers `isVerified` from a flag set by the
 * test, so every rejection observed in the suite comes from the RuleEngine rather than from identity checks.
 * @dev `Token` stores the registry as `IERC3643IdentityRegistry` but only calls `isVerified` on the transfer,
 * mint and forced-transfer paths exercised here. `recoveryAddress` would also need `contains` /
 * `registerIdentity` / `deleteIdentity`; it is not exercised.
 * WARNING: test-only. No access control.
 */
contract IdentityRegistryStub {
    mapping(address => bool) private _verified;

    /**
     * @notice Sets the verification flag of a wallet.
     * @param wallet The wallet.
     * @param verified True to mark the wallet as verified.
     */
    function setVerified(address wallet, bool verified) external {
        _verified[wallet] = verified;
    }

    /**
     * @notice Returns whether a wallet is verified.
     * @param wallet The wallet.
     * @return True when the wallet is verified.
     */
    function isVerified(address wallet) external view returns (bool) {
        return _verified[wallet];
    }
}
