//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Modules === */
import {ERC3643ComplianceModule} from "./ERC3643ComplianceModule.sol";
import {TokenBindingExtendedModule} from "./TokenBindingExtendedModule.sol";
import {TokenBindingModule} from "./TokenBindingModule.sol";
/* ==== Interface and other library === */
import {IERC3643ComplianceExtended} from "../interfaces/IERC3643ComplianceExtended.sol";

/**
 * @title ERC3643ComplianceExtendedModule
 * @notice ERC-3643 flavour of the extended token binding registry: it combines the ERC-3643
 * adapter {ERC3643ComplianceModule} with the batch binding and token self-binding provided by
 * {TokenBindingExtendedModule}.
 * @dev No logic of its own. Batch binding, self-binding approval and {getTokenBounds} are
 * standard-agnostic and therefore implemented in {TokenBindingExtendedModule}; this contract only
 * declares that the ERC-3643 deployment exposes them through {IERC3643ComplianceExtended}.
 */
abstract contract ERC3643ComplianceExtendedModule is
    TokenBindingExtendedModule,
    ERC3643ComplianceModule,
    IERC3643ComplianceExtended
{
    /**
     * @dev Resolves the two inherited definitions of the binding authorization hook, reached
     * through {TokenBindingExtendedModule} and through {ERC3643ComplianceModule}. The extended
     * behaviour wins: the compliance manager, or an approved token binding itself.
     * @param token The token being bound or unbound.
     */
    function _authorizeTokenBindingChange(address token)
        internal
        virtual
        override(TokenBindingModule, TokenBindingExtendedModule)
    {
        TokenBindingExtendedModule._authorizeTokenBindingChange(token);
    }
}
