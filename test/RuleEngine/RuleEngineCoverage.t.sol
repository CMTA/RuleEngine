// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import {RuleEngineExposed} from "src/mocks/RuleEngineExposed.sol";

/**
 * @title Coverage tests for RuleEngine (supportsInterface, _msgData)
 */
contract RuleEngineCoverageTest is Test, HelperContract {
    RuleEngineExposed public ruleEngineExposed;

    // Known interface IDs
    bytes4 constant RULE_ENGINE_ID = 0x20c49ce7;
    bytes4 constant ERC1404_EXTEND_ID = 0x78a8de7d;
    bytes4 constant ERC165_ID = 0x01ffc9a7;
    bytes4 constant INVALID_ID = 0xffffffff;

    function setUp() public {
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
        ruleEngineExposed = new RuleEngineExposed(
            RULE_ENGINE_OPERATOR_ADDRESS,
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

    function testSupportsERC165Interface() public view {
        assertTrue(ruleEngineMock.supportsInterface(ERC165_ID));
    }

    function testDoesNotSupportInvalidInterface() public view {
        assertFalse(ruleEngineMock.supportsInterface(INVALID_ID));
    }

    /*//////////////////////////////////////////////////////////////
                            MSG DATA
    //////////////////////////////////////////////////////////////*/

    function testMsgDataReturnsCalldata() public view {
        bytes memory data = ruleEngineExposed.exposedMsgData();
        // Should return the calldata (selector of exposedMsgData)
        assertEq(data.length, 4);
        assertEq(bytes4(data), ruleEngineExposed.exposedMsgData.selector);
    }
}
