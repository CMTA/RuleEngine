//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ITokenBinding} from "src/interfaces/ITokenBinding.sol";
import {TokenBindingModuleInvariantStorage} from "src/modules/library/TokenBindingModuleInvariantStorage.sol";
import {TokenBindingStandaloneMock} from "src/mocks/TokenBindingStandaloneMock.sol";

/**
 * @title TokenBindingStandaloneTest
 * @notice Tests {TokenBindingModule} used outside the RuleEngine, through
 * {TokenBindingStandaloneMock}, to pin that the binding registry works without any ERC-3643 code.
 */
contract TokenBindingStandaloneTest is Test, TokenBindingModuleInvariantStorage {
    TokenBindingStandaloneMock public engine;

    address constant OWNER_ADDRESS = address(1);
    address constant ATTACKER = address(4);
    address constant ADDRESS1 = address(5);
    address constant ADDRESS2 = address(6);

    function setUp() public {
        engine = new TokenBindingStandaloneMock(OWNER_ADDRESS);
    }

    function testCanBindToken() public {
        vm.expectEmit(true, true, true, true);
        emit ITokenBinding.TokenBound(ADDRESS1);
        vm.prank(OWNER_ADDRESS);
        engine.bindToken(ADDRESS1);

        assertTrue(engine.isTokenBound(ADDRESS1));
        assertFalse(engine.isTokenBound(ADDRESS2));
    }

    function testCanUnbindToken() public {
        vm.prank(OWNER_ADDRESS);
        engine.bindToken(ADDRESS1);

        vm.expectEmit(true, true, true, true);
        emit ITokenBinding.TokenUnbound(ADDRESS1);
        vm.prank(OWNER_ADDRESS);
        engine.unbindToken(ADDRESS1);

        assertFalse(engine.isTokenBound(ADDRESS1));
    }

    function testCannotBindTokenIfNotManager() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ATTACKER));
        vm.prank(ATTACKER);
        engine.bindToken(ADDRESS1);
    }

    function testCannotUnbindTokenIfNotManager() public {
        vm.prank(OWNER_ADDRESS);
        engine.bindToken(ADDRESS1);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ATTACKER));
        vm.prank(ATTACKER);
        engine.unbindToken(ADDRESS1);
    }

    function testCannotSelfBindWithoutTheExtendedModule() public {
        // The core module authorizes bind/unbind through the manager check only,
        // so a token cannot bind itself as it can on the RuleEngine.
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ADDRESS1));
        vm.prank(ADDRESS1);
        engine.bindToken(ADDRESS1);
    }

    function testCannotBindZeroAddress() public {
        vm.expectRevert(TokenBinding_InvalidTokenAddress.selector);
        vm.prank(OWNER_ADDRESS);
        engine.bindToken(address(0));
    }

    function testCannotBindTokenAlreadyBound() public {
        vm.prank(OWNER_ADDRESS);
        engine.bindToken(ADDRESS1);

        vm.expectRevert(TokenBinding_TokenAlreadyBound.selector);
        vm.prank(OWNER_ADDRESS);
        engine.bindToken(ADDRESS1);
    }

    function testCannotUnbindTokenNotBound() public {
        vm.expectRevert(TokenBinding_TokenNotBound.selector);
        vm.prank(OWNER_ADDRESS);
        engine.unbindToken(ADDRESS1);
    }

    function testCanCallBoundTokenEntryPointIfBound() public {
        vm.prank(OWNER_ADDRESS);
        engine.bindToken(ADDRESS1);

        vm.prank(ADDRESS1);
        engine.notify();

        assertEq(engine.callCount(), 1);
    }

    function testCannotCallBoundTokenEntryPointIfNotBound() public {
        vm.expectRevert(TokenBinding_UnauthorizedCaller.selector);
        vm.prank(ADDRESS1);
        engine.notify();
    }
}
