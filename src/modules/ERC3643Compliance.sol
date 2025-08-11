//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC3643Compliance} from "../interfaces/IERC3643Compliance.sol";
import {AccessControl}  from "OZ/access/AccessControl.sol";
import "OZ/utils/structs/EnumerableSet.sol";
abstract contract ERC3643Compliance is IERC3643Compliance, AccessControl {
    bytes32 public constant COMPLIANCE_MANAGER_ROLE = keccak256("COMPLIANCE_MANAGER_ROLE");
    // Add the library methods
    using EnumerableSet for EnumerableSet.AddressSet;
    // Errors
    error RuleEngine_ERC3643Compliance_NotComplianceManager();
    error RuleEngine_ERC3643Compliance_InvalidTokenAddress();
    error RuleEngine_ERC3643Compliance_TokenAlreadyBound();
    error RuleEngine_ERC3643Compliance_TokenNotBound();
    error RuleEngine_ERC3643Compliance_UnauthorizedCaller();

    // Token binding tracking
    EnumerableSet.AddressSet private _boundTokens;

    modifier onlyBoundToken() {
    if (!_boundTokens.contains(_msgSender())) {
        revert RuleEngine_ERC3643Compliance_UnauthorizedCaller();
    }
    _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State functions ============ */
    /// @inheritdoc IERC3643Compliance
    function bindToken(address token) public override virtual onlyRole(COMPLIANCE_MANAGER_ROLE) {
       _bindToken(token);
    }

    /// @inheritdoc IERC3643Compliance
    function unbindToken(address token) public override virtual onlyRole(COMPLIANCE_MANAGER_ROLE) {
        _unbindToken(token);
    }

    /// @inheritdoc IERC3643Compliance
    function isTokenBound(address token) public view override returns (bool) {
        return _boundTokens.contains(token);
    }

    /// @inheritdoc IERC3643Compliance
    function getTokenBound() external view override returns (address) {
        if(_boundTokens.length() > 0){
            return _boundTokens.at(0);
        } else {
            return address(0);
        }
    }

    /// @inheritdoc IERC3643Compliance
    function getTokenBounds() external view override returns (address[] memory) {
        return _boundTokens.values();
    }



    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _unbindToken(address token)  internal {
        require (_boundTokens.contains(token), RuleEngine_ERC3643Compliance_TokenNotBound()); 
        _boundTokens.remove(token);

        emit TokenUnbound(token);
    }
    function _bindToken(address token) internal{
        require(token != address(0), RuleEngine_ERC3643Compliance_InvalidTokenAddress());
        require(!_boundTokens.contains(token), RuleEngine_ERC3643Compliance_TokenAlreadyBound());
        _boundTokens.add(token);

        emit TokenBound(token);
    }
}