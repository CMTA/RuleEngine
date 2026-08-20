// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IRuleInterfaceIdHelper} from "src/mocks/IRuleInterfaceIdHelper.sol";
import {ComplianceInterfaceId} from "src/modules/library/ComplianceInterfaceId.sol";
import {ERC1404InterfaceId} from "src/modules/library/ERC1404InterfaceId.sol";
import {IERC3643ComplianceExtended} from "src/interfaces/IERC3643ComplianceExtended.sol";
import {ITokenBindingExtended} from "src/interfaces/ITokenBindingExtended.sol";
import {RuleInterfaceId} from "src/modules/library/RuleInterfaceId.sol";

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
        bytes4 manualXor = helper.computeManualXOR();

        assertEq(constant_, allFunctionsId, "Constant should match IRuleAllFunctions interface ID");
        assertEq(constant_, manualXor, "Constant should match manual XOR");
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

    /**
     * @notice Pins every advertised interface ID to the wire value integrators depend on.
     * @dev The constants are computed from the interfaces (see `ComplianceInterfaceId`,
     * `RuleInterfaceId`, `ERC1404InterfaceId`) rather than hardcoded, so this test is what turns an
     * upstream interface change into a failure here instead of a silent change in what
     * `supportsInterface` answers. These literals must never change without a major version.
     */
    function testInterfaceIdConstantsMatchTheirWireValues() public pure {
        assertEq(RuleInterfaceId.IRULE_INTERFACE_ID, bytes4(0x2497d6cb), "IRule");
        assertEq(ComplianceInterfaceId.ERC3643_COMPLIANCE_INTERFACE_ID, bytes4(0x3144991c), "IERC3643Compliance");
        assertEq(
            ComplianceInterfaceId.ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID,
            bytes4(0x646ba2be),
            "IERC3643ComplianceExtended"
        );
        assertEq(ComplianceInterfaceId.IERC7551_COMPLIANCE_INTERFACE_ID, bytes4(0x7157797f), "IERC7551Compliance");
        assertEq(ERC1404InterfaceId.IERC1404_INTERFACE_ID, bytes4(0xab84a5c8), "IERC1404");
    }

    /**
     * @notice Pins the reason the extended compliance ID is computed from {ITokenBindingExtended}.
     * @dev `IERC3643ComplianceExtended` declares no function of its own, so `type(...).interfaceId`
     * is `0x00000000` — a trap for an integrator who uses it instead of the constant. The extended
     * surface is declared in full by `ITokenBindingExtended`, whose own ID is therefore already the
     * flattened one.
     */
    function testMarkerInterfaceHasZeroNaiveIdAndIsNotUsedAsSuch() public pure {
        assertEq(type(IERC3643ComplianceExtended).interfaceId, bytes4(0x00000000), "marker declares nothing");
        assertEq(
            ComplianceInterfaceId.ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID,
            type(ITokenBindingExtended).interfaceId,
            "extended ID comes from ITokenBindingExtended"
        );
    }
}
