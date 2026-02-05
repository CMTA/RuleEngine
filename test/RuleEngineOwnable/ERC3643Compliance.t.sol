// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContractOwnable.sol";
import {IERC3643Compliance} from "../../src/interfaces/IERC3643Compliance.sol";
import {ERC3643ComplianceModule} from "../../src/modules/ERC3643ComplianceModule.sol";

// Minimal mock ERC-3643 token to simulate calls to RuleEngine
contract ERC3643MockTokenOwnable {
    IERC3643Compliance public ruleEngine;

    constructor(address _ruleEngine) {
        ruleEngine = IERC3643Compliance(_ruleEngine);
    }

    function simulateCreated(address to, uint256 amount) external {
        ruleEngine.created(to, amount);
    }

    function simulateDestroyed(address from, uint256 amount) external {
        ruleEngine.destroyed(from, amount);
    }

    function simulateTransferred(
        address from,
        address to,
        uint256 amount
    ) external {
        ruleEngine.transferred(from, to, amount);
    }
}

contract RuleEngineOwnableERC3643Test is Test, HelperContractOwnable {
    ERC3643MockTokenOwnable public token1;
    ERC3643MockTokenOwnable public token2;
    ERC3643MockTokenOwnable public token3;

    address public user1 = address(0xB0B);
    address public user2 = address(0xC0C);

    function setUp() public {
        // Deploy RuleEngineOwnable with owner
        ruleEngineMock = new RuleEngineOwnable(OWNER_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS);

        // Deploy multiple mock tokens
        token1 = new ERC3643MockTokenOwnable(address(ruleEngineMock));
        token2 = new ERC3643MockTokenOwnable(address(ruleEngineMock));
        token3 = new ERC3643MockTokenOwnable(address(ruleEngineMock));
    }

    function testBindToken() public {
        // Expect events for each bound token
        vm.startPrank(OWNER_ADDRESS);

        vm.expectEmit(true, false, false, true);
        emit IERC3643Compliance.TokenBound(address(token1));
        ruleEngineMock.bindToken(address(token1));

        vm.expectEmit(true, false, false, true);
        emit IERC3643Compliance.TokenBound(address(token2));
        ruleEngineMock.bindToken(address(token2));

        vm.expectEmit(true, false, false, true);
        emit IERC3643Compliance.TokenBound(address(token3));
        ruleEngineMock.bindToken(address(token3));

        vm.stopPrank();

        // Check bindings
        assertTrue(ruleEngineMock.isTokenBound(address(token1)));
        assertTrue(ruleEngineMock.isTokenBound(address(token2)));
        assertTrue(ruleEngineMock.isTokenBound(address(token3)));

        // getTokenBound() should return a value different from 0
        // Since we use EnumerableSet, we can not guarantee the address returned if there are more than 1 token bound
        assertNotEq(ruleEngineMock.getTokenBound(), address(0));

        // getTokenBounds() should return all 3
        address[] memory tokens = ruleEngineMock.getTokenBounds();
        assertEq(tokens.length, 3);
        assertEq(tokens[0], address(token1));
        assertEq(tokens[1], address(token2));
        assertEq(tokens[2], address(token3));
    }

    function testCanUnbindToken() public {
        // Bind all first
        vm.startPrank(OWNER_ADDRESS);

        ruleEngineMock.bindToken(address(token1));
        ruleEngineMock.bindToken(address(token2));
        ruleEngineMock.bindToken(address(token3));

        // Expect events for each unbind
        vm.expectEmit(true, false, false, true);
        emit IERC3643Compliance.TokenUnbound(address(token2));
        ruleEngineMock.unbindToken(address(token2));

        vm.expectEmit(true, false, false, true);
        emit IERC3643Compliance.TokenUnbound(address(token1));
        ruleEngineMock.unbindToken(address(token1));

        vm.expectEmit(true, false, false, true);
        emit IERC3643Compliance.TokenUnbound(address(token3));
        ruleEngineMock.unbindToken(address(token3));

        vm.stopPrank();

        // All should be unbound now
        assertFalse(ruleEngineMock.isTokenBound(address(token1)));
        assertFalse(ruleEngineMock.isTokenBound(address(token2)));
        assertFalse(ruleEngineMock.isTokenBound(address(token3)));

        assertEq(ruleEngineMock.getTokenBound(), address(0));
        assertEq(ruleEngineMock.getTokenBounds().length, 0);
    }

    function testCanCreatedAndDestroyed() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(address(token1));

        vm.startPrank(address(user1));
        token1.simulateCreated(user1, 100);
        token1.simulateDestroyed(user2, 50);
        vm.stopPrank();
    }

    function testCanTransferred() public {
        vm.startPrank(address(OWNER_ADDRESS));
        ruleEngineMock.bindToken(address(token1));

        vm.startPrank(address(user1));
        token1.simulateTransferred(user1, user2, 200);
        vm.stopPrank();
    }

    function testCannotBoundIfInvalidAddress() public {
        vm.expectRevert(
            ERC3643ComplianceModule
                .RuleEngine_ERC3643Compliance_InvalidTokenAddress
                .selector
        );
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(address(ZERO_ADDRESS));
    }

    function testCannotUnBoundIfTokenIsNotBound() public {
        vm.expectRevert(
            ERC3643ComplianceModule
                .RuleEngine_ERC3643Compliance_TokenNotBound
                .selector
        );
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.unbindToken(address(0x100));
    }

    function testCannotBoundIfTokenIsAlreadyBound() public {
        // Arrange
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(address(0x1));

        // Assert
        vm.expectRevert(
            ERC3643ComplianceModule
                .RuleEngine_ERC3643Compliance_TokenAlreadyBound
                .selector
        );
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(address(0x1));
    }

    function testCannotCreatedIfNotBound() public {
        vm.expectRevert(
            ERC3643ComplianceModule
                .RuleEngine_ERC3643Compliance_UnauthorizedCaller
                .selector
        );
        ruleEngineMock.created(user1, 100);
    }

    function testCannotDestroyedIfNotBound() public {
        vm.expectRevert(
            ERC3643ComplianceModule
                .RuleEngine_ERC3643Compliance_UnauthorizedCaller
                .selector
        );
        ruleEngineMock.destroyed(user2, 50);
    }

    function testCannotTransferredIfNotBound() public {
        vm.expectRevert(
            ERC3643ComplianceModule
                .RuleEngine_ERC3643Compliance_UnauthorizedCaller
                .selector
        );
        ruleEngineMock.transferred(user1, user2, 200);
    }
}
