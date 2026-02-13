// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContractOwnable.sol";
import {RuleEngineOwnableExposed} from "src/mocks/RuleEngineExposed.sol";
import {RuleInvalidMock} from "src/mocks/RuleInvalidMock.sol";

/**
 * @title Coverage tests for RuleEngineOwnable (supportsInterface fallback, _msgData, ERC-165 rule check)
 */
contract RuleEngineOwnableCoverageTest is Test, HelperContractOwnable {
    RuleEngineOwnableExposed public ruleEngineOwnableExposed;

    // Known interface IDs
    bytes4 constant RULE_ENGINE_ID = 0x20c49ce7;
    bytes4 constant ERC1404_EXTEND_ID = 0x78a8de7d;
    bytes4 constant ERC173_ID = 0x7f5828d0;
    bytes4 constant ERC165_ID = 0x01ffc9a7;
    bytes4 constant INVALID_ID = 0xffffffff;

    function setUp() public {
        ruleEngineMock = new RuleEngineOwnable(
            OWNER_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
        ruleEngineOwnableExposed = new RuleEngineOwnableExposed(
            OWNER_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
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

    function testSupportsERC173Interface() public view {
        assertTrue(ruleEngineMock.supportsInterface(ERC173_ID));
    }

    function testSupportsERC165ViaAccessControlFallback() public view {
        // This hits line 61: AccessControl.supportsInterface(interfaceId)
        assertTrue(ruleEngineMock.supportsInterface(ERC165_ID));
    }

    function testDoesNotSupportInvalidInterface() public view {
        // Falls through all checks including AccessControl.supportsInterface -> false
        assertFalse(ruleEngineMock.supportsInterface(INVALID_ID));
    }

    /*//////////////////////////////////////////////////////////////
                            MSG DATA
    //////////////////////////////////////////////////////////////*/

    function testMsgDataReturnsCalldata() public view {
        bytes memory data = ruleEngineOwnableExposed.exposedMsgData();
        // Should return the calldata (selector of exposedMsgData)
        assertEq(data.length, 4);
        assertEq(bytes4(data), ruleEngineOwnableExposed.exposedMsgData.selector);
    }

    /*//////////////////////////////////////////////////////////////
                    ERC-165 RULE INTERFACE CHECK
    //////////////////////////////////////////////////////////////*/

    function testCannotAddRuleWithInvalidInterface() public {
        RuleInvalidMock invalidRule = new RuleInvalidMock();

        vm.expectRevert(
            RuleEngine_RulesManagementModule_RuleInvalidInterface.selector
        );
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(IRule(address(invalidRule)));
    }

    function testCannotSetRulesWithInvalidInterface() public {
        RuleInvalidMock invalidRule = new RuleInvalidMock();
        IRule[] memory rules_ = new IRule[](1);
        rules_[0] = IRule(address(invalidRule));

        vm.expectRevert(
            RuleEngine_RulesManagementModule_RuleInvalidInterface.selector
        );
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.setRules(rules_);
    }
}
