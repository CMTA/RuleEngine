// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

/**
 * @title IIdentity — minimal stand-in for ONCHAINID's `IIdentity`.
 * @notice ERC-3643 imports `@onchain-id/solidity/contracts/interface/IIdentity.sol`. That package
 * is an npm dependency, not a git submodule, so it is not vendored here. This file supplies the
 * members ERC-3643 actually *calls* — `keyHasPurpose` in `Token.recoveryAddress`, and `getClaim` in
 * `IdentityRegistry.isVerified` — and is wired in through a context-scoped remapping that applies to
 * `lib/ERC-3643/` only.
 *
 * @dev Same approach as `src/rules/interfaces/AggregatorV3Interface.sol`: redeclare the slice of a
 * third-party interface that is genuinely used rather than vendor the whole package. Everywhere
 * else in ERC-3643, `IIdentity` appears only as a parameter or event type, and a contract type
 * canonicalises to `address` in the ABI, so the declared members do not affect any selector.
 *
 * WARNING: this is NOT the real ONCHAINID interface. The genuine `IIdentity` extends ERC-734
 * (key management) and ERC-735 (claims) with a much larger surface. Do not treat this file as a
 * specification of ONCHAINID, and do not import it outside the ERC-3643 build context.
 */
interface IIdentity {
    /**
     * @notice Returns whether a key holds a given purpose.
     * @param _key The key, `keccak256(abi.encode(walletAddress))` in ERC-3643's usage.
     * @param _purpose The ERC-734 purpose (1 = MANAGEMENT).
     * @return True if the key holds the purpose.
     */
    function keyHasPurpose(bytes32 _key, uint256 _purpose) external view returns (bool);

    /**
     * @notice Returns a claim held by this identity (ERC-735).
     * @dev Called by `IdentityRegistry.isVerified` once the token requires at least one claim topic.
     * @param _claimId `keccak256(abi.encode(issuer, topic))`.
     * @return topic The claim topic.
     * @return scheme The signature scheme.
     * @return issuer The claim issuer.
     * @return signature The claim signature.
     * @return data The claim data.
     * @return uri A URI pointing at the claim.
     */
    function getClaim(bytes32 _claimId)
        external
        view
        returns (
            uint256 topic,
            uint256 scheme,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory uri
        );
}
