//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
/* ==== Interface and other library === */
import {IERC3643Compliance} from "../interfaces/IERC3643Compliance.sol";

abstract contract ERC3643ComplianceModule is Context, IERC3643Compliance {
    /* ==== Type declaration === */
    using EnumerableSet for EnumerableSet.AddressSet;
    /* ==== State Variables === */
    // Token binding tracking
    EnumerableSet.AddressSet private _boundTokens;
    mapping(address token => bool approved) private _tokenSelfBindingApproval;
    // Access Control
    // Will not be present in the final bytecode if not used
    bytes32 public constant COMPLIANCE_MANAGER_ROLE = keccak256("COMPLIANCE_MANAGER_ROLE");

    /* ==== Errors === */
    error RuleEngine_ERC3643Compliance_InvalidTokenAddress();
    error RuleEngine_ERC3643Compliance_TokenAlreadyBound();
    error RuleEngine_ERC3643Compliance_TokenNotBound();
    error RuleEngine_ERC3643Compliance_UnauthorizedCaller();
    error RuleEngine_ERC3643Compliance_OperationNotSuccessful();

    /* ==== Modifier === */
    modifier onlyBoundToken() {
        _checkBoundToken();
        _;
    }

    modifier onlyComplianceManager() {
        _onlyComplianceManager();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/public FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State functions ============ */
    /**
     * @inheritdoc IERC3643Compliance
     * @dev Operator warning: "multi-tenant" means one RuleEngine is shared by
     * multiple token contracts. In that setup, bind only tokens that are equally
     * trusted and governed together.
     * @dev T-REX compatibility: supports token self-binding (caller equals
     * `token`) when that token was explicitly approved via
     * `setTokenSelfBindingApproval(token, true)`. This preserves the
     * `Token.setCompliance` integration path while preventing arbitrary
     * contracts from self-binding.
     */
    function bindToken(address token) public virtual override {
        _authorizeComplianceBindingChange(token);
        _bindToken(token);
    }

    /**
     * @inheritdoc IERC3643Compliance
     * @dev Operator warning: unbinding is an administrative operation and does not
     * erase any state already stored by external rule contracts in a previously
     * shared ("multi-tenant") setup.
     * @dev T-REX compatibility: supports token self-unbinding (caller equals
     * `token`) when that token was explicitly approved via
     * `setTokenSelfBindingApproval(token, true)`.
     */
    function unbindToken(address token) public virtual override {
        _authorizeComplianceBindingChange(token);
        _unbindToken(token);
    }

    /// @inheritdoc IERC3643Compliance
    function setTokenSelfBindingApproval(address token, bool approved) public virtual override onlyComplianceManager {
        require(token != address(0), RuleEngine_ERC3643Compliance_InvalidTokenAddress());
        _tokenSelfBindingApproval[token] = approved;
        emit TokenSelfBindingApprovalSet(token, approved);
    }

    /// @inheritdoc IERC3643Compliance
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
            emit TokenSelfBindingApprovalSet(token, approved);
        }
    }

    /// @inheritdoc IERC3643Compliance
    function isTokenSelfBindingApproved(address token) public view virtual override returns (bool) {
        return _tokenSelfBindingApproval[token];
    }

    /// @inheritdoc IERC3643Compliance
    function isTokenBound(address token) public view virtual override returns (bool) {
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
        require(_boundTokens.contains(token), RuleEngine_ERC3643Compliance_TokenNotBound());
        // Should never revert because we check if the token address is already set before
        require(_boundTokens.remove(token), RuleEngine_ERC3643Compliance_OperationNotSuccessful());

        emit TokenUnbound(token);
    }

    function _bindToken(address token) internal {
        require(token != address(0), RuleEngine_ERC3643Compliance_InvalidTokenAddress());
        require(!_boundTokens.contains(token), RuleEngine_ERC3643Compliance_TokenAlreadyBound());
        // Should never revert because we check if the token address is already set before
        require(_boundTokens.add(token), RuleEngine_ERC3643Compliance_OperationNotSuccessful());
        emit TokenBound(token);
    }

    function _checkBoundToken() internal view virtual {
        if (!_boundTokens.contains(_msgSender())) {
            revert RuleEngine_ERC3643Compliance_UnauthorizedCaller();
        }
    }

    /**
     * @dev Authorizes bind/unbind operations.
     * Allows compliance manager, or approved token self-calls for T-REX compatibility.
     */
    function _authorizeComplianceBindingChange(address token) internal virtual {
        if (_msgSender() == token && _tokenSelfBindingApproval[token]) {
            return;
        }
        _onlyComplianceManager();
    }

    function _onlyComplianceManager() internal virtual;
}
