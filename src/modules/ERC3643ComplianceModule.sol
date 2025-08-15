//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {AccessControl} from "OZ/access/AccessControl.sol";
import {EnumerableSet} from "OZ/utils/structs/EnumerableSet.sol";
/* ==== Interface and other library === */
import {IERC3643Compliance} from "../interfaces/IERC3643Compliance.sol";

abstract contract ERC3643ComplianceModule is IERC3643Compliance, AccessControl {
    /* ==== Type declaration === */
    using EnumerableSet for EnumerableSet.AddressSet;
    /* ==== State Variables === */
    // Token binding tracking
    EnumerableSet.AddressSet private _boundTokens;
    // Access Control
    bytes32 public constant COMPLIANCE_MANAGER_ROLE =
        keccak256("COMPLIANCE_MANAGER_ROLE");

    /* ==== Errors === */
    error RuleEngine_ERC3643Compliance_InvalidTokenAddress();
    error RuleEngine_ERC3643Compliance_TokenAlreadyBound();
    error RuleEngine_ERC3643Compliance_TokenNotBound();
    error RuleEngine_ERC3643Compliance_UnauthorizedCaller();
    error RuleEngine_ERC3643Compliance_OperationNotSuccessful();

    /* ==== Modifier === */
    modifier onlyBoundToken() {
        if (!_boundTokens.contains(_msgSender())) {
            revert RuleEngine_ERC3643Compliance_UnauthorizedCaller();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/public FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State functions ============ */
    /// @inheritdoc IERC3643Compliance
    function bindToken(
        address token
    ) public virtual override onlyRole(COMPLIANCE_MANAGER_ROLE) {
        _bindToken(token);
    }

    /// @inheritdoc IERC3643Compliance
    function unbindToken(
        address token
    ) public virtual override onlyRole(COMPLIANCE_MANAGER_ROLE) {
        _unbindToken(token);
    }

    /// @inheritdoc IERC3643Compliance
    function isTokenBound(
        address token
    ) public view virtual override returns (bool) {
        return _boundTokens.contains(token);
    }

    /// @inheritdoc IERC3643Compliance
    function getTokenBound() public view virtual override returns (address) {
        if (_boundTokens.length() > 0) {
            // Note that there are no guarantees on the ordering of values inside the array,
            // and it may change when more values are added or removed.
            return _boundTokens.at(0);
        } else {
            return address(0);
        }
    }

    /// @inheritdoc IERC3643Compliance
    function getTokenBounds() public view override returns (address[] memory) {
        return _boundTokens.values();
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _unbindToken(address token) internal {
        require(
            _boundTokens.contains(token),
            RuleEngine_ERC3643Compliance_TokenNotBound()
        );
        // Should never revert because we check if the token address is already set before
        require(
            _boundTokens.remove(token),
            RuleEngine_ERC3643Compliance_OperationNotSuccessful()
        );

        emit TokenUnbound(token);
    }

    function _bindToken(address token) internal {
        require(
            token != address(0),
            RuleEngine_ERC3643Compliance_InvalidTokenAddress()
        );
        require(
            !_boundTokens.contains(token),
            RuleEngine_ERC3643Compliance_TokenAlreadyBound()
        );
        // Should never revert because we check if the token address is already set before
        require(
            _boundTokens.add(token),
            RuleEngine_ERC3643Compliance_OperationNotSuccessful()
        );
        emit TokenBound(token);
    }
}
