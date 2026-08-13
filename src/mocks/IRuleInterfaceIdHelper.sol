// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {IRule} from "../interfaces/IRule.sol";
import {IRuleEngineERC1404, IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {IERC1404, IERC1404Extend} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "CMTAT/interfaces/tokenization/draft-IERC7551.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {RuleInterfaceId} from "../modules/library/RuleInterfaceId.sol";

/**
 * @title IRuleAllFunctions
 * @dev Flattened interface containing ALL functions from the IRule hierarchy.
 *      Used to compute the full ERC-165 interface ID (XOR of all selectors).
 *      type(IRule).interfaceId only covers directly defined functions (canReturnTransferRestrictionCode).
 *      type(IRuleAllFunctions).interfaceId covers the full hierarchy.
 */
interface IRuleAllFunctions {
    /**
     * @notice From IRuleEngine: applies the rule to a transfer carrying a spender.
     * @param spender The account moving the tokens on behalf of `from`.
     * @param from The origin address.
     * @param to The destination address.
     * @param value The number of tokens transferred.
     */
    function transferred(address spender, address from, address to, uint256 value) external;

    /**
     * @notice From IERC3643IComplianceContract: applies the rule to a transfer without a spender.
     * @param from The origin address.
     * @param to The destination address.
     * @param value The number of tokens transferred.
     */
    function transferred(address from, address to, uint256 value) external;

    /**
     * @notice From IRule: tells whether the restriction code belongs to this rule.
     * @param restrictionCode The target restriction code.
     * @return True if the restriction code is known by the rule.
     */
    function canReturnTransferRestrictionCode(uint8 restrictionCode) external view returns (bool);

    /**
     * @notice From IERC1404: returns the restriction code applying to a transfer.
     * @param from The origin address.
     * @param to The destination address.
     * @param value The number of tokens to transfer.
     * @return The ERC-1404 restriction code, zero when the transfer is allowed.
     */
    function detectTransferRestriction(address from, address to, uint256 value) external view returns (uint8);

    /**
     * @notice From IERC1404: returns the human readable message for a restriction code.
     * @param restrictionCode The target restriction code.
     * @return The message describing the restriction.
     */
    function messageForTransferRestriction(uint8 restrictionCode) external view returns (string memory);

    /**
     * @notice From IERC1404Extend: returns the restriction code for a spender-initiated transfer.
     * @param spender The account moving the tokens on behalf of `from`.
     * @param from The origin address.
     * @param to The destination address.
     * @param value The number of tokens to transfer.
     * @return The ERC-1404 restriction code, zero when the transfer is allowed.
     */
    function detectTransferRestrictionFrom(address spender, address from, address to, uint256 value)
        external
        view
        returns (uint8);

    /**
     * @notice From IERC3643ComplianceRead: tells whether a transfer is allowed.
     * @param from The origin address.
     * @param to The destination address.
     * @param value The number of tokens to transfer.
     * @return True if the transfer is allowed, false otherwise.
     */
    function canTransfer(address from, address to, uint256 value) external view returns (bool);

    /**
     * @notice From IERC7551Compliance: tells whether a spender-initiated transfer is allowed.
     * @param spender The account moving the tokens on behalf of `from`.
     * @param from The origin address.
     * @param to The destination address.
     * @param value The number of tokens to transfer.
     * @return True if the transfer is allowed, false otherwise.
     */
    function canTransferFrom(address spender, address from, address to, uint256 value) external view returns (bool);

    /**
     * @notice From IERC165: ERC-165 interface detection.
     * @param interfaceId The interface identifier to check.
     * @return True if the interface is supported, false otherwise.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @title IRuleInterfaceIdHelper
 * @dev Helper contract to expose IRule interface IDs and verify computation.
 */
contract IRuleInterfaceIdHelper {
    /**
     * @notice Returns type(IRule).interfaceId (only directly defined functions)
     * @return The ERC-165 interface ID of IRule alone.
     */
    function getIRuleInterfaceId() external pure returns (bytes4) {
        return type(IRule).interfaceId;
    }

    /**
     * @notice Returns the XOR of ALL function selectors in the IRule hierarchy (flattened)
     * @return The ERC-165 interface ID covering the full IRule hierarchy.
     */
    function getIRuleAllFunctionsInterfaceId() external pure returns (bytes4) {
        return type(IRuleAllFunctions).interfaceId;
    }

    /**
     * @notice Returns the constant defined in RuleInterfaceId library
     * @return The interface ID constant shipped in RuleInterfaceId.
     */
    function getRuleInterfaceIdConstant() external pure returns (bytes4) {
        return RuleInterfaceId.IRULE_INTERFACE_ID;
    }

    /**
     * @notice Returns individual interface IDs from each parent interface
     * @return iRuleId The interface ID of IRule.
     * @return iRuleEngineERC1404Id The interface ID of IRuleEngineERC1404.
     * @return iRuleEngineId The interface ID of IRuleEngine.
     * @return iERC1404Id The interface ID of IERC1404.
     * @return iERC1404ExtendId The interface ID of IERC1404Extend.
     * @return iERC3643ComplianceReadId The interface ID of IERC3643ComplianceRead.
     * @return iERC3643IComplianceContractId The interface ID of IERC3643IComplianceContract.
     * @return iERC7551ComplianceId The interface ID of IERC7551Compliance.
     * @return iERC165Id The interface ID of IERC165.
     */
    function getParentInterfaceIds()
        external
        pure
        returns (
            bytes4 iRuleId,
            bytes4 iRuleEngineERC1404Id,
            bytes4 iRuleEngineId,
            bytes4 iERC1404Id,
            bytes4 iERC1404ExtendId,
            bytes4 iERC3643ComplianceReadId,
            bytes4 iERC3643IComplianceContractId,
            bytes4 iERC7551ComplianceId,
            bytes4 iERC165Id
        )
    {
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

    // forge-lint: disable-next-line(mixed-case-function)
    /**
     * @notice Manually computes the XOR of all function selectors and returns it
     * @return The interface ID obtained by XOR-ing every selector by hand.
     */
    function computeManualXOR() external pure returns (bytes4) {
        return IRule.canReturnTransferRestrictionCode.selector ^ IERC1404.detectTransferRestriction.selector
            ^ IERC1404.messageForTransferRestriction.selector ^ IERC1404Extend.detectTransferRestrictionFrom.selector
            ^ IRuleEngine.transferred.selector ^ IERC3643IComplianceContract.transferred.selector
            ^ IERC3643ComplianceRead.canTransfer.selector ^ IERC7551Compliance.canTransferFrom.selector
            ^ IERC165.supportsInterface.selector;
    }
}
