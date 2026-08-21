// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {TokenBindingModule} from "../modules/TokenBindingModule.sol";

/**
 * @title TokenBindingStandaloneMock
 * @notice Minimal engine reusing {TokenBindingModule} on its own, without any rule, ERC-1404 or
 * ERC-3643 code.
 * @dev Reference implementation showing what another project has to provide to embed the binding
 * registry: an access control model wired to {_onlyTokenBindingManager}, and the bound-token
 * entry points guarded by the `onlyBoundToken` modifier. It also covers the module's default
 * {_authorizeTokenBindingChange}, which the RuleEngine replaces with the self-binding aware
 * variant of {TokenBindingExtendedModule}.
 * This contract is a reference implementation for testing and examples, not a production
 * contract.
 */
contract TokenBindingStandaloneMock is TokenBindingModule, Ownable {
    /**
     * @notice Number of calls received on the bound-token entry point.
     */
    uint256 public callCount;

    /**
     * @notice Deploys the standalone binding registry.
     * @param owner_ Address allowed to bind and unbind tokens.
     */
    constructor(address owner_) Ownable(owner_) {}

    /**
     * @notice Example bound-token entry point: only a bound token can call it.
     */
    function notify() public virtual onlyBoundToken {
        ++callCount;
    }

    /**
     * @dev Access control check using the Ownable pattern.
     */
    function _onlyTokenBindingManager() internal virtual override onlyOwner {}
}
