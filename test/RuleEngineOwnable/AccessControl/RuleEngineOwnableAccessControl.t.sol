// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContractOwnable.sol";
import {Ownable} from "OZ/access/Ownable.sol";

/**
 * @title Access Control tests for RuleEngineOwnable
 */
contract RuleEngineOwnableAccessControlTest is Test, HelperContractOwnable {
    // Arrange
    function setUp() public {
        ruleEngineMock = new RuleEngineOwnable(
            OWNER_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
        ruleConditionalTransferLight = new RuleConditionalTransferLight(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ruleEngineMock
        );
    }

    /*//////////////////////////////////////////////////////////////
                        OWNER CAN CALL PROTECTED FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function testOwnerCanAddRule() public {
        // Act
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);

        // Assert
        assertEq(ruleEngineMock.rulesCount(), 1);
        assertTrue(ruleEngineMock.containsRule(ruleConditionalTransferLight));
    }

    function testOwnerCanRemoveRule() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);
        assertEq(ruleEngineMock.rulesCount(), 1);

        // Act
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.removeRule(ruleConditionalTransferLight);

        // Assert
        assertEq(ruleEngineMock.rulesCount(), 0);
    }

    function testOwnerCanSetRules() public {
        // Arrange
        RuleConditionalTransferLight rule1 = new RuleConditionalTransferLight(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ruleEngineMock
        );
        RuleConditionalTransferLight rule2 = new RuleConditionalTransferLight(
            CONDITIONAL_TRANSFER_OPERATOR_ADDRESS,
            ruleEngineMock
        );
        IRule[] memory rules = new IRule[](2);
        rules[0] = IRule(rule1);
        rules[1] = IRule(rule2);

        // Act
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.setRules(rules);

        // Assert
        assertEq(ruleEngineMock.rulesCount(), 2);
    }

    function testOwnerCanClearRules() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);

        // Act
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.clearRules();

        // Assert
        assertEq(ruleEngineMock.rulesCount(), 0);
    }

    function testOwnerCanBindToken() public {
        // Act
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(ADDRESS1);

        // Assert
        assertTrue(ruleEngineMock.isTokenBound(ADDRESS1));
    }

    function testOwnerCanUnbindToken() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(ADDRESS1);

        // Act
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.unbindToken(ADDRESS1);

        // Assert
        assertFalse(ruleEngineMock.isTokenBound(ADDRESS1));
    }

    /*//////////////////////////////////////////////////////////////
                    NON-OWNER CANNOT CALL PROTECTED FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function testNonOwnerCannotAddRule() public {
        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        vm.prank(ATTACKER);
        ruleEngineMock.addRule(ruleConditionalTransferLight);
    }

    function testNonOwnerCannotRemoveRule() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);

        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        vm.prank(ATTACKER);
        ruleEngineMock.removeRule(ruleConditionalTransferLight);
    }

    function testNonOwnerCannotSetRules() public {
        // Arrange
        IRule[] memory rules = new IRule[](1);
        rules[0] = IRule(ruleConditionalTransferLight);

        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        vm.prank(ATTACKER);
        ruleEngineMock.setRules(rules);
    }

    function testNonOwnerCannotClearRules() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);

        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        vm.prank(ATTACKER);
        ruleEngineMock.clearRules();
    }

    function testNonOwnerCannotBindToken() public {
        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        vm.prank(ATTACKER);
        ruleEngineMock.bindToken(ADDRESS1);
    }

    function testNonOwnerCannotUnbindToken() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(ADDRESS1);

        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        vm.prank(ATTACKER);
        ruleEngineMock.unbindToken(ADDRESS1);
    }

    /*//////////////////////////////////////////////////////////////
                        OWNERSHIP TRANSFER
    //////////////////////////////////////////////////////////////*/

    function testOwnerCanTransferOwnership() public {
        // Act
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.transferOwnership(NEW_OWNER_ADDRESS);

        // Assert
        assertEq(ruleEngineMock.owner(), NEW_OWNER_ADDRESS);
    }

    function testNewOwnerCanCallProtectedFunctions() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.transferOwnership(NEW_OWNER_ADDRESS);

        // Act
        vm.prank(NEW_OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);

        // Assert
        assertEq(ruleEngineMock.rulesCount(), 1);
    }

    function testOldOwnerCannotCallAfterTransfer() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.transferOwnership(NEW_OWNER_ADDRESS);

        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                OWNER_ADDRESS
            )
        );
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);
    }

    function testNonOwnerCannotTransferOwnership() public {
        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        vm.prank(ATTACKER);
        ruleEngineMock.transferOwnership(ATTACKER);
    }

    /*//////////////////////////////////////////////////////////////
                        RENOUNCE OWNERSHIP
    //////////////////////////////////////////////////////////////*/

    function testOwnerCanRenounceOwnership() public {
        // Act
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.renounceOwnership();

        // Assert
        assertEq(ruleEngineMock.owner(), ZERO_ADDRESS);
    }

    function testNoOneCanCallProtectedFunctionsAfterRenounce() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.renounceOwnership();

        // Act & Assert - even previous owner cannot call
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                OWNER_ADDRESS
            )
        );
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);
    }

    function testNonOwnerCannotRenounceOwnership() public {
        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                ATTACKER
            )
        );
        vm.prank(ATTACKER);
        ruleEngineMock.renounceOwnership();
    }
}
