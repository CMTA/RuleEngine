//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
/* ==== Modules === */
import {TokenBindingModule} from "./TokenBindingModule.sol";
/* ==== Interface and other library === */
import {IERC3643Compliance} from "../interfaces/IERC3643Compliance.sol";

/**
 * @title ERC3643ComplianceModule
 * @notice ERC-3643 adapter over the standard-agnostic {TokenBindingModule}: it adds the
 * ERC-3643 specific view {getTokenBound} and names the binding manager in compliance terms.
 * @dev The binding registry itself (storage, `bindToken` / `unbindToken` / `isTokenBound`, the
 * `onlyBoundToken` modifier) lives in {TokenBindingModule} and can be reused outside any
 * compliance context. Everything ERC-3643 specific is here:
 *  - {getTokenBound}, the single-token view required by the ERC-3643 compliance interface;
 *  - {_onlyComplianceManager}, the access control hook the deployable contracts implement, wired
 *    to the generic {_onlyTokenBindingManager} hook.
 *
 * The ERC-3643 compliance callbacks themselves (`transferred`, `created`, `destroyed`) are
 * implemented by `RuleEngineBase`, since they depend on the rules rather than on the binding.
 * @custom:security-note Operation rules (stateful rules such as `RuleConditionalTransferLightMock`
 * or `RuleMintAllowanceMock`) maintain per-address accounting that is shared across all bound
 * tokens, and the ERC-3643 callbacks do not carry the calling token address to the rules.
 * Binding tokens from different issuers to the same engine will silently cross-contaminate their
 * accounting. Only bind tokens that are equally trusted and governed together.
 */
abstract contract ERC3643ComplianceModule is TokenBindingModule, IERC3643Compliance {
    /* ==== Type declaration === */
    using EnumerableSet for EnumerableSet.AddressSet;

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/public FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ View functions ============ */
    /// @inheritdoc IERC3643Compliance
    function getTokenBound() public view virtual override returns (address) {
        if (_boundTokens.length() > 0) {
            // Note that there are no guarantees on the ordering of values inside the array,
            // and it may change when more values are added or removed.
            return _boundTokens.pos(0);
        } else {
            return address(0);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev In an ERC-3643 deployment, the account managing the token bindings is the compliance
     * manager, so the generic binding manager hook delegates to {_onlyComplianceManager}.
     */
    function _onlyTokenBindingManager() internal virtual override {
        _onlyComplianceManager();
    }

    /**
     * @dev Access control hook guarding compliance management operations, implemented by the
     * deployable contracts. Binding management is gated by this hook through
     * {_onlyTokenBindingManager}; the generic `onlyTokenBindingManager` modifier of
     * {TokenBindingModule} is therefore the compliance manager check in an ERC-3643 deployment.
     */
    function _onlyComplianceManager() internal virtual;
}
