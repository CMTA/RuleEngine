// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {IERC3643Compliance} from "src/interfaces/IERC3643Compliance.sol";
import {IRulesManagementModule} from "src/interfaces/IRulesManagementModule.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {RuleEngineBase} from "src/RuleEngineBase.sol";
import {RuleCodeProbe} from "./RuleCodeProbe.sol";
import {LegacyIRuleIdProbe} from "./LegacyIRuleIdProbe.sol";
import {RuleEngineInvariantStorage} from "src/modules/library/RuleEngineInvariantStorage.sol";
import {RuleInterfaceId} from "src/modules/library/RuleInterfaceId.sol";

/**
 * @title RuleAggregationTestBase
 * @notice Shared tests pinning how the engine aggregates the answers of several rules, run for every
 * deployable variant.
 * @dev Two `RuleCodeProbe` rules are added in order (`first`, then `second`), with no removal, so the
 * engine iterates them in insertion order. The probes' answers are set per test, which lets the
 * assertions use independently known values rather than recomputing the engine's logic.
 */
abstract contract RuleAggregationTestBase is Test {
    address internal constant ADMIN = address(0xA11CE);
    address internal constant TOKEN = address(0x7070);
    address internal constant SPENDER = address(0x5555);
    address internal constant FROM = address(0x1111);
    address internal constant TO = address(0x2222);

    uint8 internal constant FIRST_CLAIMED = 10;
    uint8 internal constant SECOND_CLAIMED = 20;

    RuleEngineBase internal engine;
    RuleCodeProbe internal first;
    RuleCodeProbe internal second;

    /* ============ Variant hook ============ */

    /// @dev Deploys the variant with `admin` as admin/owner, no forwarder and `token` bound.
    function _deployEngine(address admin, address token) internal virtual returns (address);

    /* ============ Setup ============ */

    function setUp() public virtual {
        engine = RuleEngineBase(_deployEngine(ADMIN, TOKEN));
        first = new RuleCodeProbe(FIRST_CLAIMED, "first rule message");
        second = new RuleCodeProbe(SECOND_CLAIMED, "second rule message");
        vm.startPrank(ADMIN);
        IRulesManagementModule(address(engine)).addRule(IRule(address(first)));
        IRulesManagementModule(address(engine)).addRule(IRule(address(second)));
        vm.stopPrank();
        assertEq(engine.rule(0), address(first));
        assertEq(engine.rule(1), address(second));
    }

    /* ============ IRule interface gate ============ */

    /// @notice An engine-only rule is accepted: the probes implement `IRule` without `canTransfer` /
    /// `canTransferFrom` (both added in `setUp`), and the engine never needs them.
    function testEngineOnlyRuleWithoutComplianceReadsIsAccepted() public {
        assertTrue(first.supportsInterface(RuleInterfaceId.IRULE_INTERFACE_ID));
        (bool ok,) = address(first).call(abi.encodeWithSignature("canTransfer(address,address,uint256)", FROM, TO, 1));
        assertFalse(ok, "the probe has no canTransfer");
        assertTrue(IRulesManagementModule(address(engine)).containsRule(IRule(address(first))));
    }

    /// @notice A rule advertising only the legacy ID `0x2497d6cb` (the interface before rc7, a superset of the
    /// current one) is still accepted.
    function testRuleAdvertisingOnlyTheLegacyIdIsAccepted() public {
        LegacyIRuleIdProbe legacy = new LegacyIRuleIdProbe();
        assertFalse(legacy.supportsInterface(RuleInterfaceId.IRULE_INTERFACE_ID));
        vm.prank(ADMIN);
        IRulesManagementModule(address(engine)).addRule(IRule(address(legacy)));
        assertTrue(IRulesManagementModule(address(engine)).containsRule(IRule(address(legacy))));
    }

    /// @notice A contract that implements ERC-165 but advertises neither rule ID is rejected.
    function testRuleAdvertisingNoRuleIdIsRejected() public {
        RuleCodeProbe probe = new RuleCodeProbe(1, "m");
        vm.mockCall(
            address(probe),
            abi.encodeWithSignature("supportsInterface(bytes4)", RuleInterfaceId.IRULE_INTERFACE_ID),
            abi.encode(false)
        );
        vm.prank(ADMIN);
        vm.expectRevert(RuleEngineInvariantStorage.RuleEngine_RuleInvalidInterface.selector);
        IRulesManagementModule(address(engine)).addRule(IRule(address(probe)));
    }

    /// @notice A contract that answers `true` to every interface ID, including the invalid `0xffffffff`, does not
    /// implement ERC-165 correctly and is rejected, although it claims both rule IDs.
    function testRuleClaimingEveryInterfaceIsRejected() public {
        RuleCodeProbe probe = new RuleCodeProbe(1, "m");
        vm.mockCall(address(probe), abi.encodeWithSignature("supportsInterface(bytes4)"), abi.encode(true));
        vm.mockCall(address(probe), abi.encodeWithSelector(bytes4(0x01ffc9a7)), abi.encode(true));
        vm.prank(ADMIN);
        vm.expectRevert(RuleEngineInvariantStorage.RuleEngine_RuleInvalidInterface.selector);
        IRulesManagementModule(address(engine)).addRule(IRule(address(probe)));
    }

    /// @notice An account with no ERC-165 support (here an EOA) is rejected before any rule ID is queried.
    function testRuleWithoutErc165IsRejected() public {
        vm.prank(ADMIN);
        vm.expectRevert(RuleEngineInvariantStorage.RuleEngine_RuleInvalidInterface.selector);
        IRulesManagementModule(address(engine)).addRule(IRule(address(0xBEEF)));
    }

    /* ============ detectTransferRestriction / canTransfer ============ */

    /// @notice The 3-argument view returns the first non-zero code in rule order, or 0 when every rule allows.
    function testFuzz_DetectReturnsFirstNonZeroCode(uint8 codeFirst, uint8 codeSecond) public {
        first.setCodes(codeFirst, 0);
        second.setCodes(codeSecond, 0);
        uint8 expected = codeFirst != 0 ? codeFirst : codeSecond;

        assertEq(engine.detectTransferRestriction(FROM, TO, 1), expected);
        assertEq(engine.canTransfer(FROM, TO, 1), expected == 0);
    }

    /// @notice The 4-argument view consults the rules' 4-argument answers, not their 3-argument ones.
    function testFuzz_DetectFromReturnsFirstNonZeroCode(uint8 codeFirst, uint8 codeSecond) public {
        // The 3-argument answers are the opposite, so using the wrong path changes the result.
        first.setCodes(codeFirst == 0 ? 99 : 0, codeFirst);
        second.setCodes(codeSecond == 0 ? 99 : 0, codeSecond);
        uint8 expected = codeFirst != 0 ? codeFirst : codeSecond;

        assertEq(engine.detectTransferRestrictionFrom(SPENDER, FROM, TO, 1), expected);
        assertEq(engine.canTransferFrom(SPENDER, FROM, TO, 1), expected == 0);
    }

    /// @notice Boundary codes: the smallest non-zero code (1) and the largest (255) are both reported.
    function testBoundaryCodesAreReported() public {
        first.setCodes(1, 1);
        assertEq(engine.detectTransferRestriction(FROM, TO, 1), 1);
        assertEq(engine.detectTransferRestrictionFrom(SPENDER, FROM, TO, 1), 1);
        assertFalse(engine.canTransfer(FROM, TO, 1));

        first.setCodes(0, 0);
        second.setCodes(255, 255);
        assertEq(engine.detectTransferRestriction(FROM, TO, 1), 255);
        assertEq(engine.detectTransferRestrictionFrom(SPENDER, FROM, TO, 1), 255);
        assertFalse(engine.canTransferFrom(SPENDER, FROM, TO, 1));
    }

    /* ============ messageForTransferRestriction ============ */

    /// @notice The message comes from the rule that claims the code, wherever it sits in the rule set.
    function testMessageComesFromTheClaimingRule() public view {
        assertEq(engine.messageForTransferRestriction(FIRST_CLAIMED), "first rule message");
        assertEq(engine.messageForTransferRestriction(SECOND_CLAIMED), "second rule message");
        assertEq(engine.messageForTransferRestriction(0), "NoRestriction");
        assertEq(engine.messageForTransferRestriction(77), "Unknown restriction code");
    }

    /* ============ transferred: every rule runs ============ */

    /// @notice Each callback runs every rule: a rejection by the second rule reverts the 3-argument path.
    function testTransferredRunsTheSecondRule() public {
        second.setCodes(42, 0);
        vm.startPrank(TOKEN);
        vm.expectRevert(abi.encodeWithSelector(RuleCodeProbe.RuleCodeProbe_Rejected.selector, 42));
        IRuleEngine(address(engine)).transferred(FROM, TO, 1);
        vm.expectRevert(abi.encodeWithSelector(RuleCodeProbe.RuleCodeProbe_Rejected.selector, 42));
        IERC3643Compliance(address(engine)).created(TO, 1);
        vm.expectRevert(abi.encodeWithSelector(RuleCodeProbe.RuleCodeProbe_Rejected.selector, 42));
        IERC3643Compliance(address(engine)).destroyed(FROM, 1);
        // The 4-argument path uses the rules' 4-argument hook, whose code is still 0.
        IRuleEngine(address(engine)).transferred(SPENDER, FROM, TO, 1);
        vm.stopPrank();
    }

    /// @notice A rejection by the second rule reverts the 4-argument path.
    function testTransferredFromRunsTheSecondRule() public {
        second.setCodes(0, 43);
        vm.prank(TOKEN);
        vm.expectRevert(abi.encodeWithSelector(RuleCodeProbe.RuleCodeProbe_Rejected.selector, 43));
        IRuleEngine(address(engine)).transferred(SPENDER, FROM, TO, 1);
    }

    /// @notice `created` and `destroyed` forward the zero address on the correct side.
    function testCreatedAndDestroyedForwardTheZeroAddressOnTheRightSide() public {
        vm.startPrank(TOKEN);
        vm.expectCall(
            address(first), abi.encodeWithSignature("transferred(address,address,uint256)", address(0), TO, 5)
        );
        IERC3643Compliance(address(engine)).created(TO, 5);
        vm.expectCall(
            address(first), abi.encodeWithSignature("transferred(address,address,uint256)", FROM, address(0), 7)
        );
        IERC3643Compliance(address(engine)).destroyed(FROM, 7);
        vm.stopPrank();
    }
}
