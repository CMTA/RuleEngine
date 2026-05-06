// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

interface IERC3643ComplianceExtendedSubset {
    function bindTokens(address[] calldata tokens) external;
    function unbindTokens(address[] calldata tokens) external;
    function setTokenSelfBindingApproval(address token, bool approved) external;
    function setTokenSelfBindingApprovalBatch(address[] calldata tokens, bool approved) external;
    function isTokenSelfBindingApproved(address token) external view returns (bool approved);
    function getTokenBounds() external view returns (address[] memory tokens);
}
