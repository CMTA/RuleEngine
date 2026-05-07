//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
/* ==== Interface and other library === */
import {IERC3643ComplianceExtended} from "../interfaces/IERC3643ComplianceExtended.sol";
import {ERC3643ComplianceModule} from "./ERC3643ComplianceModule.sol";

abstract contract ERC3643ComplianceExtendedModule is ERC3643ComplianceModule, IERC3643ComplianceExtended {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(address token => bool approved) private _tokenSelfBindingApproval;

    /// @inheritdoc IERC3643ComplianceExtended
    function bindTokens(address[] calldata tokens) public virtual override onlyComplianceManager {
        for (uint256 i = 0; i < tokens.length; ++i) {
            _bindToken(tokens[i]);
        }
    }

    /// @inheritdoc IERC3643ComplianceExtended
    function unbindTokens(address[] calldata tokens) public virtual override onlyComplianceManager {
        for (uint256 i = 0; i < tokens.length; ++i) {
            _unbindToken(tokens[i]);
        }
    }

    /// @inheritdoc IERC3643ComplianceExtended
    function setTokenSelfBindingApproval(address token, bool approved) public virtual override onlyComplianceManager {
        require(token != address(0), RuleEngine_ERC3643Compliance_InvalidTokenAddress());
        _tokenSelfBindingApproval[token] = approved;
        emit TokenSelfBindingApprovalSet(token, approved);
    }

    /// @inheritdoc IERC3643ComplianceExtended
    function setTokenSelfBindingApprovalBatch(address[] calldata tokens, bool approved)
        public
        virtual
        override
        onlyComplianceManager
    {
        for (uint256 i = 0; i < tokens.length; ++i) {
            address token = tokens[i];
            require(token != address(0), RuleEngine_ERC3643Compliance_InvalidTokenAddress());
            _tokenSelfBindingApproval[token] = approved;
        }
        emit TokenSelfBindingApprovalBatchSet(tokens, approved);
    }

    /// @inheritdoc IERC3643ComplianceExtended
    function isTokenSelfBindingApproved(address token) public view virtual override returns (bool) {
        return _tokenSelfBindingApproval[token];
    }

    /// @inheritdoc IERC3643ComplianceExtended
    function getTokenBounds() public view virtual override returns (address[] memory) {
        return _boundTokens.values();
    }

    /**
     * @dev Authorizes bind/unbind operations.
     * Allows compliance manager, or approved token self-calls for T-REX compatibility.
     */
    function _authorizeComplianceBindingChange(address token) internal virtual override {
        if (_msgSender() == token && _tokenSelfBindingApproval[token]) {
            return;
        }
        _onlyComplianceManager();
    }
}
