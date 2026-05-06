// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title ComplianceInterfaceId
 * @dev ERC-165 interface IDs used by RuleEngine for compliance interfaces.
 */
library ComplianceInterfaceId {
    bytes4 public constant ERC3643_COMPLIANCE_INTERFACE_ID = 0x3144991c;
    bytes4 public constant ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID = 0x646ba2be;
    bytes4 public constant IERC7551_COMPLIANCE_INTERFACE_ID = 0x7157797f;
}
