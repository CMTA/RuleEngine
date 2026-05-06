// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
// forge-lint: disable-next-line(unaliased-plain-import)
import "../HelperContractOwnable.sol";

import {RuleEngineOwnableExposed} from "src/mocks/RuleEngineExposed.sol";
import {RuleInvalidMock} from "src/mocks/RuleInvalidMock.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {ICompliance} from "src/mocks/ICompliance.sol";
import {IERC3643ComplianceExtendedSubset} from "src/mocks/IERC3643ComplianceExtendedSubset.sol";
import {IERC173Subset} from "src/mocks/IERC173Subset.sol";
import {IERC1404Subset} from "src/mocks/IERC1404Subset.sol";
import {IERC7551ComplianceSubset} from "src/mocks/IERC7551ComplianceSubset.sol";
import {ComplianceInterfaceId} from "src/modules/library/ComplianceInterfaceId.sol";
import {ERC1404InterfaceId} from "src/modules/library/ERC1404InterfaceId.sol";
import {OwnableInterfaceId} from "src/modules/library/OwnableInterfaceId.sol";

/**
 * @title Coverage tests for RuleEngineOwnable (_msgData, ERC-165 rule check)
 */
contract RuleEngineOwnableCoverageTest is Test, HelperContractOwnable {
    RuleEngineOwnableExposed public ruleEngineOwnableExposed;

    // Known interface IDs
    bytes4 constant RULE_ENGINE_ID = 0x20c49ce7;
    bytes4 constant ERC1404_EXTEND_ID = 0x78a8de7d;
    bytes4 constant ERC165_ID = 0x01ffc9a7;
    bytes4 constant INVALID_ID = 0xffffffff;

    function setUp() public {
        ruleEngineMock = new RuleEngineOwnable(OWNER_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS);
        ruleEngineOwnableExposed = new RuleEngineOwnableExposed(OWNER_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS);
    }

    /*//////////////////////////////////////////////////////////////
                        SUPPORTS INTERFACE
    //////////////////////////////////////////////////////////////*/

    function testSupportsRuleEngineInterface() public view {
        assertTrue(ruleEngineMock.supportsInterface(RULE_ENGINE_ID));
    }

    function testSupportsERC1404ExtendInterface() public view {
        assertTrue(ruleEngineMock.supportsInterface(ERC1404_EXTEND_ID));
    }

    function testSupportsERC1404Interface() public view {
        assertTrue(ruleEngineMock.supportsInterface(ERC1404InterfaceId.IERC1404_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC1404Subset).interfaceId));
    }

    function testSupportsERC173Interface() public view {
        assertTrue(ruleEngineMock.supportsInterface(OwnableInterfaceId.IERC173_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC173Subset).interfaceId));
    }

    function testSupportsERC3643ComplianceInterface() public view {
        assertTrue(ruleEngineMock.supportsInterface(type(ICompliance).interfaceId));
    }

    function testSupportsERC3643ComplianceExtendedSubsetInterface() public view {
        assertTrue(ruleEngineMock.supportsInterface(ComplianceInterfaceId.ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC3643ComplianceExtendedSubset).interfaceId));
    }

    function testSupportsIERC7551ComplianceSubsetInterface() public view {
        assertTrue(ruleEngineMock.supportsInterface(type(IERC7551ComplianceSubset).interfaceId));
    }

    function testSupportsERC165() public view {
        assertTrue(ruleEngineMock.supportsInterface(ERC165_ID));
    }

    function testDoesNotSupportIAccessControlInterface() public view {
        assertFalse(ruleEngineMock.supportsInterface(type(IAccessControl).interfaceId));
    }

    function testDoesNotSupportInvalidInterface() public view {
        assertFalse(ruleEngineMock.supportsInterface(INVALID_ID));
    }

    /*//////////////////////////////////////////////////////////////
                            MSG DATA
    //////////////////////////////////////////////////////////////*/

    function testMsgDataReturnsCalldata() public view {
        bytes memory data = ruleEngineOwnableExposed.exposedMsgData();
        // Should return the calldata (selector of exposedMsgData)
        assertEq(data.length, 4);
        // forge-lint: disable-next-line(unsafe-typecast)
        assertEq(bytes4(data), ruleEngineOwnableExposed.exposedMsgData.selector);
    }

    /*//////////////////////////////////////////////////////////////
                    ERC-165 RULE INTERFACE CHECK
    //////////////////////////////////////////////////////////////*/

    function testCannotAddRuleWithInvalidInterface() public {
        RuleInvalidMock invalidRule = new RuleInvalidMock();

        vm.expectRevert(RuleEngine_RuleInvalidInterface.selector);
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(IRule(address(invalidRule)));
    }

    function testCannotSetRulesWithInvalidInterface() public {
        RuleInvalidMock invalidRule = new RuleInvalidMock();
        IRule[] memory rules_ = new IRule[](1);
        rules_[0] = IRule(address(invalidRule));

        vm.expectRevert(RuleEngine_RuleInvalidInterface.selector);
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.setRules(rules_);
    }

    function testCannotAddEOAAsRule() public {
        // EOA does not implement ERC-165, ERC165Checker returns false
        vm.expectRevert(RuleEngine_RuleInvalidInterface.selector);
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(IRule(address(0x999)));
    }
}
