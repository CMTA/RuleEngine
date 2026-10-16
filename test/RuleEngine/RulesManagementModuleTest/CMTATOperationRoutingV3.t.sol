// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CMTATStandalone} from "CMTATv3.0.0/deployment/CMTATStandalone.sol";
import {IRuleEngine} from "CMTATv3.0.0/interfaces/engine/IRuleEngine.sol";
import {RuleEngine} from "src/deployment/accessControl/RuleEngine.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {CMTATDeploymentV3} from "../../utils/CMTATDeploymentV3.sol";
import {RuleCodeProbe} from "../../utils/RuleCodeProbe.sol";

/**
 * @title Transfer, transferFrom, mint and burn of a CMTAT v3.0.0 token through the RuleEngine
 * @notice Pins which `transferred` overload each operation reaches, on the engine and on the rule, with the exact
 * arguments, and that a rule rejecting that overload blocks the operation.
 * @dev CMTAT v3.0.0 (`0_CMTATBaseCommon.sol`) passes a spender only for `transferFrom`. Mint and burn call
 * `_checkTransferred(address(0), ...)`, so they take the 3-argument overload with no operator: unlike CMTAT
 * >= v3.3.0, a rule keyed on the 4-argument path (a per-minter allowance) never sees a mint or a burn.
 */
contract RuleEngineCMTATOperationRoutingV3Test is Test {
    address internal constant TOKEN_ADMIN = address(1); // admin of CMTATDeploymentV3, holds every token role
    address internal constant ENGINE_ADMIN = address(0xE1);
    address internal constant HOLDER = address(0xA1);
    address internal constant RECEIVER = address(0xA2);
    address internal constant SPENDER = address(0xA3);
    uint256 internal constant INITIAL_BALANCE = 100;
    uint256 internal constant VALUE = 20;
    uint8 internal constant CODE = 42;

    bytes4 internal constant TRANSFERRED_3 = bytes4(keccak256("transferred(address,address,uint256)"));
    bytes4 internal constant TRANSFERRED_4 = bytes4(keccak256("transferred(address,address,address,uint256)"));

    CMTATStandalone internal token;
    RuleEngine internal engine;
    RuleCodeProbe internal probe;

    function setUp() public {
        token = new CMTATDeploymentV3().cmtat();
        vm.prank(TOKEN_ADMIN);
        token.mint(HOLDER, INITIAL_BALANCE);

        engine = new RuleEngine(ENGINE_ADMIN, address(token));
        probe = new RuleCodeProbe(CODE, "rejected");
        vm.prank(ENGINE_ADMIN);
        engine.addRule(IRule(address(probe)));

        vm.prank(TOKEN_ADMIN);
        token.setRuleEngine(IRuleEngine(address(engine)));
    }

    /* ============ Helpers ============ */

    /// @dev Expects exactly one 3-argument call on the engine and on the rule, and no 4-argument call.
    function _expectThreeArgumentPath(address from, address to, uint256 value) internal {
        bytes memory call3 = abi.encodeWithSelector(TRANSFERRED_3, from, to, value);
        vm.expectCall(address(engine), call3, 1);
        vm.expectCall(address(probe), call3, 1);
        vm.expectCall(address(engine), abi.encodeWithSelector(TRANSFERRED_4), 0);
        vm.expectCall(address(probe), abi.encodeWithSelector(TRANSFERRED_4), 0);
    }

    /* ============ Transfer ============ */

    function testTransferUsesThreeArgumentOverload() public {
        _expectThreeArgumentPath(HOLDER, RECEIVER, VALUE);
        vm.prank(HOLDER);
        assertTrue(token.transfer(RECEIVER, VALUE));

        assertEq(token.balanceOf(HOLDER), INITIAL_BALANCE - VALUE);
        assertEq(token.balanceOf(RECEIVER), VALUE);
    }

    function testRuleCanBlockTransfer() public {
        probe.setCodes(CODE, 0);
        vm.prank(HOLDER);
        vm.expectRevert(abi.encodeWithSelector(RuleCodeProbe.RuleCodeProbe_Rejected.selector, CODE));
        token.transfer(RECEIVER, VALUE);
    }

    /* ============ TransferFrom ============ */

    function testTransferFromUsesFourArgumentOverloadWithSpender() public {
        vm.prank(HOLDER);
        token.approve(SPENDER, VALUE);

        bytes memory call4 = abi.encodeWithSelector(TRANSFERRED_4, SPENDER, HOLDER, RECEIVER, VALUE);
        vm.expectCall(address(engine), call4, 1);
        vm.expectCall(address(probe), call4, 1);
        vm.expectCall(address(engine), abi.encodeWithSelector(TRANSFERRED_3), 0);
        vm.expectCall(address(probe), abi.encodeWithSelector(TRANSFERRED_3), 0);
        vm.prank(SPENDER);
        assertTrue(token.transferFrom(HOLDER, RECEIVER, VALUE));

        assertEq(token.balanceOf(HOLDER), INITIAL_BALANCE - VALUE);
        assertEq(token.balanceOf(RECEIVER), VALUE);
        assertEq(token.allowance(HOLDER, SPENDER), 0);
    }

    function testRuleCanBlockTransferFrom() public {
        vm.prank(HOLDER);
        token.approve(SPENDER, VALUE);
        probe.setCodes(0, CODE);
        vm.prank(SPENDER);
        vm.expectRevert(abi.encodeWithSelector(RuleCodeProbe.RuleCodeProbe_Rejected.selector, CODE));
        token.transferFrom(HOLDER, RECEIVER, VALUE);
    }

    /* ============ Mint ============ */

    function testMintUsesThreeArgumentOverloadWithoutMinter() public {
        _expectThreeArgumentPath(address(0), RECEIVER, VALUE);
        vm.prank(TOKEN_ADMIN);
        token.mint(RECEIVER, VALUE);

        assertEq(token.balanceOf(RECEIVER), VALUE);
        assertEq(token.totalSupply(), INITIAL_BALANCE + VALUE);
    }

    function testRuleCanBlockMint() public {
        probe.setCodes(CODE, 0);
        vm.prank(TOKEN_ADMIN);
        vm.expectRevert(abi.encodeWithSelector(RuleCodeProbe.RuleCodeProbe_Rejected.selector, CODE));
        token.mint(RECEIVER, VALUE);
    }

    /// @notice A rule enforced only on the 4-argument path (a spender-keyed rule) does not see a v3.0.0 mint.
    function testFourArgumentOnlyRuleDoesNotBlockMint() public {
        probe.setCodes(0, CODE);
        vm.prank(TOKEN_ADMIN);
        token.mint(RECEIVER, VALUE);

        assertEq(token.balanceOf(RECEIVER), VALUE);
    }

    /* ============ Burn ============ */

    function testBurnUsesThreeArgumentOverloadWithoutBurner() public {
        _expectThreeArgumentPath(HOLDER, address(0), VALUE);
        vm.prank(TOKEN_ADMIN);
        token.burn(HOLDER, VALUE);

        assertEq(token.balanceOf(HOLDER), INITIAL_BALANCE - VALUE);
        assertEq(token.totalSupply(), INITIAL_BALANCE - VALUE);
    }

    function testRuleCanBlockBurn() public {
        probe.setCodes(CODE, 0);
        vm.prank(TOKEN_ADMIN);
        vm.expectRevert(abi.encodeWithSelector(RuleCodeProbe.RuleCodeProbe_Rejected.selector, CODE));
        token.burn(HOLDER, VALUE);
    }

    /// @notice A rule enforced only on the 4-argument path does not see a v3.0.0 burn.
    function testFourArgumentOnlyRuleDoesNotBlockBurn() public {
        probe.setCodes(0, CODE);
        vm.prank(TOKEN_ADMIN);
        token.burn(HOLDER, VALUE);

        assertEq(token.balanceOf(HOLDER), INITIAL_BALANCE - VALUE);
    }
}
