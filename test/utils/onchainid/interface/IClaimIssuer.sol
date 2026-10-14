// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {IIdentity} from "./IIdentity.sol";

/**
 * @title IClaimIssuer — minimal stand-in for ONCHAINID's `IClaimIssuer`.
 * @notice Imported by ERC-3643's trusted-issuers registry interface. Within the compile set it is
 * used as a type in most places, and *called* in one: `IdentityRegistry.isVerified` invokes
 * `isClaimValid` on the trusted issuer of each required claim topic.
 *
 * @dev See {IIdentity} for why these stubs exist and the remapping that wires them in.
 *
 * WARNING: not the real ONCHAINID interface. The genuine `IClaimIssuer` adds claim revocation and
 * signature validation. Do not import this outside the ERC-3643 build context.
 */
interface IClaimIssuer is IIdentity {
    /**
     * @notice Returns whether a claim issued by this issuer is currently valid.
     * @dev Called by `IdentityRegistry.isVerified` for every required claim topic.
     * @param _identity The identity the claim is about.
     * @param _claimTopic The claim topic.
     * @param _sig The claim signature.
     * @param _data The claim data.
     * @return True when the claim is valid.
     */
    function isClaimValid(IIdentity _identity, uint256 _claimTopic, bytes calldata _sig, bytes calldata _data)
        external
        view
        returns (bool);
}
