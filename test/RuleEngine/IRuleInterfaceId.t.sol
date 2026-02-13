// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {IRuleInterfaceIdHelper} from "src/mocks/IRuleInterfaceIdHelper.sol";

/**
 * @title Tests to verify IRule ERC-165 interface ID computation
 * @dev Verifies that the IRULE_INTERFACE_ID constant matches the full XOR of all selectors
 */
contract IRuleInterfaceIdTest is Test {
    IRuleInterfaceIdHelper public helper;

    function setUp() public {
        helper = new IRuleInterfaceIdHelper();
    }

    function testConstantMatchesAllFunctionsXOR() public view {
        bytes4 constant_ = helper.getRuleInterfaceIdConstant();
        bytes4 allFunctionsId = helper.getIRuleAllFunctionsInterfaceId();
        bytes4 manualXOR = helper.computeManualXOR();

        assertEq(constant_, allFunctionsId, "Constant should match IRuleAllFunctions interface ID");
        assertEq(constant_, manualXOR, "Constant should match manual XOR");
    }

    function testIRuleInterfaceIdIsSubsetOfAllFunctions() public view {
        bytes4 iRuleId = helper.getIRuleInterfaceId();
        bytes4 constant_ = helper.getRuleInterfaceIdConstant();

        // type(IRule).interfaceId only covers canReturnTransferRestrictionCode
        assertTrue(iRuleId != constant_, "type(IRule).interfaceId should differ from full IRule ID");
    }

    function testLogAllInterfaceIds() public {
        bytes4 iRuleId = helper.getIRuleInterfaceId();
        bytes4 allFunctionsId = helper.getIRuleAllFunctionsInterfaceId();
        bytes4 constant_ = helper.getRuleInterfaceIdConstant();

        emit log_named_bytes32("type(IRule).interfaceId (only canReturnTransferRestrictionCode)", bytes32(iRuleId));
        emit log_named_bytes32("type(IRuleAllFunctions).interfaceId (full XOR)", bytes32(allFunctionsId));
        emit log_named_bytes32("RuleInterfaceId.IRULE_INTERFACE_ID constant", bytes32(constant_));

        (
            bytes4 iRule,
            bytes4 iRuleEngineERC1404,
            bytes4 iRuleEngine,
            bytes4 iERC1404,
            bytes4 iERC1404Extend,
            bytes4 iERC3643ComplianceRead,
            bytes4 iERC3643IComplianceContract,
            bytes4 iERC7551Compliance,
            bytes4 iERC165
        ) = helper.getParentInterfaceIds();

        emit log_named_bytes32("IRule", bytes32(iRule));
        emit log_named_bytes32("IRuleEngineERC1404", bytes32(iRuleEngineERC1404));
        emit log_named_bytes32("IRuleEngine", bytes32(iRuleEngine));
        emit log_named_bytes32("IERC1404", bytes32(iERC1404));
        emit log_named_bytes32("IERC1404Extend", bytes32(iERC1404Extend));
        emit log_named_bytes32("IERC3643ComplianceRead", bytes32(iERC3643ComplianceRead));
        emit log_named_bytes32("IERC3643IComplianceContract", bytes32(iERC3643IComplianceContract));
        emit log_named_bytes32("IERC7551Compliance", bytes32(iERC7551Compliance));
        emit log_named_bytes32("IERC165", bytes32(iERC165));
    }
}
