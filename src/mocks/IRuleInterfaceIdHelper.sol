// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {IRule} from "../interfaces/IRule.sol";
import {IRuleEngineERC1404, IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {IERC1404, IERC1404Extend} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "CMTAT/interfaces/tokenization/draft-IERC7551.sol";
import {IERC165} from "OZ/utils/introspection/IERC165.sol";
import {RuleInterfaceId} from "../modules/library/RuleInterfaceId.sol";

/**
 * @title IRuleAllFunctions
 * @dev Flattened interface containing ALL functions from the IRule hierarchy.
 *      Used to compute the full ERC-165 interface ID (XOR of all selectors).
 *      type(IRule).interfaceId only covers directly defined functions (canReturnTransferRestrictionCode).
 *      type(IRuleAllFunctions).interfaceId covers the full hierarchy.
 */
interface IRuleAllFunctions {
    // From IRule
    function canReturnTransferRestrictionCode(uint8 restrictionCode) external view returns (bool);
    // From IERC1404
    function detectTransferRestriction(address from, address to, uint256 value) external view returns (uint8);
    function messageForTransferRestriction(uint8 restrictionCode) external view returns (string memory);
    // From IERC1404Extend
    function detectTransferRestrictionFrom(address spender, address from, address to, uint256 value) external view returns (uint8);
    // From IRuleEngine
    function transferred(address spender, address from, address to, uint256 value) external;
    // From IERC3643IComplianceContract
    function transferred(address from, address to, uint256 value) external;
    // From IERC3643ComplianceRead
    function canTransfer(address from, address to, uint256 value) external view returns (bool);
    // From IERC7551Compliance
    function canTransferFrom(address spender, address from, address to, uint256 value) external view returns (bool);
    // From IERC165
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @title IRuleInterfaceIdHelper
 * @dev Helper contract to expose IRule interface IDs and verify computation.
 */
contract IRuleInterfaceIdHelper {
    /// @notice Returns type(IRule).interfaceId (only directly defined functions)
    function getIRuleInterfaceId() external pure returns (bytes4) {
        return type(IRule).interfaceId;
    }

    /// @notice Returns the XOR of ALL function selectors in the IRule hierarchy (flattened)
    function getIRuleAllFunctionsInterfaceId() external pure returns (bytes4) {
        return type(IRuleAllFunctions).interfaceId;
    }

    /// @notice Returns the constant defined in RuleInterfaceId library
    function getRuleInterfaceIdConstant() external pure returns (bytes4) {
        return RuleInterfaceId.IRULE_INTERFACE_ID;
    }

    /// @notice Returns individual interface IDs from each parent interface
    function getParentInterfaceIds() external pure returns (
        bytes4 iRuleId,
        bytes4 iRuleEngineERC1404Id,
        bytes4 iRuleEngineId,
        bytes4 iERC1404Id,
        bytes4 iERC1404ExtendId,
        bytes4 iERC3643ComplianceReadId,
        bytes4 iERC3643IComplianceContractId,
        bytes4 iERC7551ComplianceId,
        bytes4 iERC165Id
    ) {
        iRuleId = type(IRule).interfaceId;
        iRuleEngineERC1404Id = type(IRuleEngineERC1404).interfaceId;
        iRuleEngineId = type(IRuleEngine).interfaceId;
        iERC1404Id = type(IERC1404).interfaceId;
        iERC1404ExtendId = type(IERC1404Extend).interfaceId;
        iERC3643ComplianceReadId = type(IERC3643ComplianceRead).interfaceId;
        iERC3643IComplianceContractId = type(IERC3643IComplianceContract).interfaceId;
        iERC7551ComplianceId = type(IERC7551Compliance).interfaceId;
        iERC165Id = type(IERC165).interfaceId;
    }

    /// @notice Manually computes the XOR of all function selectors and returns it
    function computeManualXOR() external pure returns (bytes4) {
        return
            IRule.canReturnTransferRestrictionCode.selector ^
            IERC1404.detectTransferRestriction.selector ^
            IERC1404.messageForTransferRestriction.selector ^
            IERC1404Extend.detectTransferRestrictionFrom.selector ^
            IRuleEngine.transferred.selector ^
            IERC3643IComplianceContract.transferred.selector ^
            IERC3643ComplianceRead.canTransfer.selector ^
            IERC7551Compliance.canTransferFrom.selector ^
            IERC165.supportsInterface.selector;
    }
}
