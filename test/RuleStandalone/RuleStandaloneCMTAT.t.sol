// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {CMTATStandardStandalone} from "CMTAT/deployment/CMTATStandardStandalone.sol";
import {IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {CMTATDeployment} from "../utils/CMTATDeployment.sol";
import {RuleWhitelistMock} from "src/mocks/rules/validation/RuleWhitelistMock.sol";
import {RuleConditionalTransferLightMock} from "src/mocks/rules/operation/RuleConditionalTransferLightMock.sol";
import {RuleMintAllowanceMock} from "src/mocks/rules/operation/RuleMintAllowanceMock.sol";
import {RuleOperationRevertMock} from "src/mocks/rules/operation/RuleOperationRevertMock.sol";
import {
    RuleConditionalTransferLightInvariantStorage
} from "src/mocks/rules/operation/abstract/RuleConditionalTransferLightInvariantStorage.sol";
import {
    RuleMintAllowanceInvariantStorage
} from "src/mocks/rules/operation/abstract/RuleMintAllowanceInvariantStorage.sol";

/**
 * @title RuleStandaloneCMTATTest
 * @notice A reference rule attached directly to a CMTAT token as its rule engine, with no RuleEngine in
 * between (rc7 code-quality review `I-2`). Every reference rule advertises `RULE_ENGINE_INTERFACE_ID` and
 * implements the whole engine-facing surface; these tests check that the role works: the token calls the
 * rule's `transferred`, `canTransfer` and ERC-1404 views directly, and the rule's codes and messages reach
 * the token unchanged. CMTAT only: an ERC-3643 token calls `created` / `destroyed`, which a rule does not have.
 */
contract RuleStandaloneCMTATTest is Test {
    address internal constant ADMIN = address(1); // CMTATDeployment admin
    address internal constant ALICE = address(0xA11CE);
    address internal constant BOB = address(0xB0B);
    address internal constant CAROL = address(0xCA201);

    uint8 internal constant CODE_TO_NOT_WHITELISTED = 22;
    string internal constant TEXT_TO_NOT_WHITELISTED = "The recipient is not in the whitelist";
    uint8 internal constant CODE_NOT_APPROVED = 71;
    string internal constant TEXT_NOT_APPROVED = "ConditionalTransferLight: The request is not approved";

    CMTATStandardStandalone internal token;

    function setUp() public {
        token = new CMTATDeployment().cmtat();
        // Fund ALICE before any rule is attached.
        vm.prank(ADMIN);
        token.mint(ALICE, 100);
    }

    function _attach(address rule) internal {
        vm.prank(ADMIN);
        token.setRuleEngine(IRuleEngine(rule));
        assertEq(address(token.ruleEngine()), rule);
    }

    /* ============ ERC-165 ============ */

    /// @notice Every reference rule advertises the engine role, using CMTAT's constant.
    function testReferenceRulesAdvertiseTheRuleEngineInterface() public {
        address[4] memory rules = [
            address(new RuleWhitelistMock(ADMIN, address(0))),
            address(new RuleConditionalTransferLightMock(ADMIN, IRuleEngine(address(0)))),
            address(new RuleMintAllowanceMock(ADMIN)),
            address(new RuleOperationRevertMock())
        ];
        for (uint256 i = 0; i < rules.length; ++i) {
            assertTrue(IERC165(rules[i]).supportsInterface(RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID));
        }
    }

    /* ============ Whitelist ============ */

    function _whitelistAttached() internal returns (RuleWhitelistMock rule) {
        rule = new RuleWhitelistMock(ADMIN, address(0));
        address[] memory listed = new address[](2);
        listed[0] = ALICE;
        listed[1] = BOB;
        vm.prank(ADMIN);
        rule.addAddressesToTheList(listed);
        _attach(address(rule));
    }

    function testWhitelistStandaloneAllowsListedTransfer() public {
        _whitelistAttached();
        assertTrue(token.canTransfer(ALICE, BOB, 10));
        assertEq(token.detectTransferRestriction(ALICE, BOB, 10), 0);

        vm.prank(ALICE);
        token.transfer(BOB, 10);
        assertEq(token.balanceOf(BOB), 10);
    }

    function testWhitelistStandaloneRefusesUnlistedTransferWithItsCodeAndMessage() public {
        _whitelistAttached();
        assertFalse(token.canTransfer(ALICE, CAROL, 10));
        assertEq(token.detectTransferRestriction(ALICE, CAROL, 10), CODE_TO_NOT_WHITELISTED);
        assertEq(token.messageForTransferRestriction(CODE_TO_NOT_WHITELISTED), TEXT_TO_NOT_WHITELISTED);

        vm.prank(ALICE);
        vm.expectRevert(
            abi.encodeWithSelector(
                RuleWhitelistMock.RuleWhitelist_InvalidTransfer.selector, ALICE, CAROL, 10, CODE_TO_NOT_WHITELISTED
            )
        );
        token.transfer(CAROL, 10);
    }

    /// @notice `transferFrom` reaches the rule through the 4-argument `transferred`, with the spender.
    function testWhitelistStandaloneChecksTheSpender() public {
        _whitelistAttached();
        vm.prank(ALICE);
        token.approve(CAROL, 10);
        assertEq(token.detectTransferRestrictionFrom(CAROL, ALICE, BOB, 10), 23);

        vm.prank(CAROL);
        vm.expectRevert(
            abi.encodeWithSelector(RuleWhitelistMock.RuleWhitelist_InvalidTransfer.selector, ALICE, BOB, 10, 23)
        );
        token.transferFrom(ALICE, BOB, 10);
    }

    /* ============ Conditional transfer ============ */

    function _conditionalAttached() internal returns (RuleConditionalTransferLightMock rule) {
        rule = new RuleConditionalTransferLightMock(ADMIN, IRuleEngine(address(0)));
        _attach(address(rule));
    }

    function testConditionalTransferStandaloneRefusesUnapprovedTransfer() public {
        _conditionalAttached();
        assertFalse(token.canTransfer(ALICE, BOB, 10));
        assertEq(token.detectTransferRestriction(ALICE, BOB, 10), CODE_NOT_APPROVED);
        assertEq(token.messageForTransferRestriction(CODE_NOT_APPROVED), TEXT_NOT_APPROVED);

        vm.prank(ALICE);
        vm.expectRevert(RuleConditionalTransferLightInvariantStorage.TransferNotApproved.selector);
        token.transfer(BOB, 10);
    }

    /// @notice The token's call to `transferred` consumes the approval, so it can be used once.
    function testConditionalTransferStandaloneConsumesTheApproval() public {
        RuleConditionalTransferLightMock rule = _conditionalAttached();
        vm.prank(ADMIN);
        rule.approveTransfer(ALICE, BOB, 10);
        assertTrue(token.canTransfer(ALICE, BOB, 10));

        vm.prank(ALICE);
        token.transfer(BOB, 10);
        assertEq(token.balanceOf(BOB), 10);
        // forge-lint: disable-next-line(asm-keccak256)
        assertEq(rule.approvalCounts(keccak256(abi.encodePacked(ALICE, BOB, uint256(10)))), 0);

        vm.prank(ALICE);
        vm.expectRevert(RuleConditionalTransferLightInvariantStorage.TransferNotApproved.selector);
        token.transfer(BOB, 10);
    }

    /* ============ Mint allowance ============ */

    /// @notice CMTAT mints through the 4-argument `transferred` with the minter as spender.
    function testMintAllowanceStandaloneConsumesTheMinterAllowance() public {
        RuleMintAllowanceMock rule = new RuleMintAllowanceMock(ADMIN);
        vm.prank(ADMIN);
        rule.setMintAllowance(ADMIN, 50);
        _attach(address(rule));

        vm.prank(ADMIN);
        token.mint(BOB, 30);
        assertEq(token.balanceOf(BOB), 30);
        assertEq(rule.mintAllowance(ADMIN), 20);

        vm.prank(ADMIN);
        vm.expectRevert(
            abi.encodeWithSelector(
                RuleMintAllowanceInvariantStorage.RuleMintAllowance_InsufficientAllowance.selector, ADMIN, 20, 21
            )
        );
        token.mint(BOB, 21);
    }

    /// @notice The rule restricts only mints: an ordinary transfer passes.
    function testMintAllowanceStandaloneLetsTransfersThrough() public {
        _attach(address(new RuleMintAllowanceMock(ADMIN)));
        vm.prank(ALICE);
        token.transfer(BOB, 10);
        assertEq(token.balanceOf(BOB), 10);
    }

    /* ============ Reverting rule ============ */

    /// @notice A rule that reverts in `transferred` blocks the token operation with the rule's own error.
    function testRevertingRuleStandaloneBlocksTheTransfer() public {
        _attach(address(new RuleOperationRevertMock()));
        vm.prank(ALICE);
        vm.expectRevert(RuleOperationRevertMock.RuleConditionalTransferLight_InvalidTransfer.selector);
        token.transfer(BOB, 10);
    }
}
