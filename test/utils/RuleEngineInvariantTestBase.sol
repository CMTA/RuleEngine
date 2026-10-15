// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IRule} from "src/interfaces/IRule.sol";
import {RuleEngineBase} from "src/RuleEngineBase.sol";
import {RuleInterfaceId} from "src/modules/library/RuleInterfaceId.sol";
import {RuleInvalidMock} from "src/mocks/RuleInvalidMock.sol";
import {RuleCodeProbe} from "./RuleCodeProbe.sol";
import {LegacyIRuleIdProbe} from "./LegacyIRuleIdProbe.sol";

/**
 * @title RuleEngineHandler
 * @notice Drives random sequences of administrative calls on one engine, as its admin/owner, and keeps a
 * model of the rule set and of the bound tokens. The model is updated from the semantics of each call that
 * succeeded, never by reading the engine, so the invariants compare two independent sources.
 * @dev Inputs are indices into fixed pools, so the fuzzer hits duplicates, already-bound tokens, invalid
 * rules and `address(0)` often. Every call is wrapped in try/catch: a revert must leave the state unchanged,
 * and the model is only touched on success.
 */
contract RuleEngineHandler is Test {
    RuleEngineBase internal immutable ENGINE;
    address internal immutable ADMIN;

    /// @dev Candidate rules: valid probes, one legacy-ID probe, one contract without the rule ID, address(0).
    address[] public rulePool;
    /// @dev Candidate tokens, including address(0).
    address[] public tokenPool;

    mapping(address => bool) public modelHasRule;
    mapping(address => bool) public modelIsBound;
    uint256 public modelRuleCount;
    uint256 public modelBoundCount;
    uint256 public modelMaxRules;

    /// @dev Number of calls that succeeded, per kind; lets a test check the fuzzer exercised the paths.
    mapping(bytes32 => uint256) public successes;

    constructor(RuleEngineBase engine_, address admin_) {
        ENGINE = engine_;
        ADMIN = admin_;
        for (uint8 i = 0; i < 4; ++i) {
            rulePool.push(address(new RuleCodeProbe(10 + i, "probe")));
        }
        rulePool.push(address(new LegacyIRuleIdProbe()));
        rulePool.push(address(new RuleInvalidMock()));
        rulePool.push(address(0));
        tokenPool.push(address(0x7071));
        tokenPool.push(address(0x7072));
        tokenPool.push(address(0x7073));
        tokenPool.push(address(0x7074));
        tokenPool.push(address(0));
        modelMaxRules = engine_.maxRules();
    }

    /* ============ Pool helpers ============ */

    function rulePoolLength() external view returns (uint256) {
        return rulePool.length;
    }

    function tokenPoolLength() external view returns (uint256) {
        return tokenPool.length;
    }

    function _rule(uint256 seed) internal view returns (address) {
        return rulePool[seed % rulePool.length];
    }

    /// @dev One draw in three is a rule-pool address, so the fuzzer also tries to bind rules (F-3).
    function _token(uint256 seed) internal view returns (address) {
        if (seed % 3 == 0) {
            return rulePool[(seed / 3) % rulePool.length];
        }
        return tokenPool[seed % tokenPool.length];
    }

    function _isAcceptedRule(address r) internal view returns (bool) {
        return r != address(0) && r != rulePool[rulePool.length - 2];
    }

    /* ============ Rule set ============ */

    function addRule(uint256 seed) external {
        address r = _rule(seed);
        vm.prank(ADMIN);
        try ENGINE.addRule(IRule(r)) {
            modelHasRule[r] = true;
            ++modelRuleCount;
            ++successes["addRule"];
        } catch {}
    }

    function removeRule(uint256 seed) external {
        address r = _rule(seed);
        vm.prank(ADMIN);
        try ENGINE.removeRule(IRule(r)) {
            modelHasRule[r] = false;
            --modelRuleCount;
            ++successes["removeRule"];
        } catch {}
    }

    function setRules(uint256 seedA, uint256 seedB, uint256 length) external {
        length = bound(length, 0, 2);
        IRule[] memory rs = new IRule[](length);
        if (length > 0) rs[0] = IRule(_rule(seedA));
        if (length > 1) rs[1] = IRule(_rule(seedB));
        vm.prank(ADMIN);
        try ENGINE.setRules(rs) {
            _clearModelRules();
            for (uint256 i = 0; i < length; ++i) {
                modelHasRule[address(rs[i])] = true;
                ++modelRuleCount;
            }
            ++successes["setRules"];
        } catch {}
    }

    function clearRules() external {
        vm.prank(ADMIN);
        try ENGINE.clearRules() {
            _clearModelRules();
            ++successes["clearRules"];
        } catch {}
    }

    function setMaxRules(uint256 maxRules_) external {
        maxRules_ = bound(maxRules_, 0, 6);
        vm.prank(ADMIN);
        try ENGINE.setMaxRules(maxRules_) {
            modelMaxRules = maxRules_;
            ++successes["setMaxRules"];
        } catch {}
    }

    function _clearModelRules() internal {
        for (uint256 i = 0; i < rulePool.length; ++i) {
            modelHasRule[rulePool[i]] = false;
        }
        modelRuleCount = 0;
    }

    /* ============ Token binding ============ */

    function bindToken(uint256 seed) external {
        address t = _token(seed);
        vm.prank(ADMIN);
        try ENGINE.bindToken(t) {
            modelIsBound[t] = true;
            ++modelBoundCount;
            ++successes["bindToken"];
        } catch {}
    }

    function unbindToken(uint256 seed) external {
        address t = _token(seed);
        vm.prank(ADMIN);
        try ENGINE.unbindToken(t) {
            modelIsBound[t] = false;
            --modelBoundCount;
            ++successes["unbindToken"];
        } catch {}
    }

    function bindTokens(uint256 seedA, uint256 seedB) external {
        address[] memory ts = new address[](2);
        ts[0] = _token(seedA);
        ts[1] = _token(seedB);
        vm.prank(ADMIN);
        try ENGINE.bindTokens(ts) {
            for (uint256 i = 0; i < 2; ++i) {
                modelIsBound[ts[i]] = true;
                ++modelBoundCount;
            }
            ++successes["bindTokens"];
        } catch {}
    }

    function unbindTokens(uint256 seedA, uint256 seedB) external {
        address[] memory ts = new address[](2);
        ts[0] = _token(seedA);
        ts[1] = _token(seedB);
        vm.prank(ADMIN);
        try ENGINE.unbindTokens(ts) {
            for (uint256 i = 0; i < 2; ++i) {
                modelIsBound[ts[i]] = false;
                --modelBoundCount;
            }
            ++successes["unbindTokens"];
        } catch {}
    }

    /// @dev Exposes the private pool rule for the gate invariant.
    function isAcceptedRule(address r) external view returns (bool) {
        return _isAcceptedRule(r);
    }
}

/**
 * @title RuleEngineInvariantTestBase
 * @notice Handler-based invariant tests over the rule set and the bound-token set, run for every deployable
 * variant (rc7 code-quality review `K-5`).
 * @dev The handler is the only target. After every call of every random sequence, the engine's state must
 * match the handler's model, and the structural properties must hold. `rulesCount() <= maxRules()` is
 * deliberately not an invariant: lowering the cap below the current count is allowed.
 */
abstract contract RuleEngineInvariantTestBase is Test {
    address internal constant ADMIN = address(0xA11CE);

    RuleEngineBase internal engine;
    RuleEngineHandler internal handler;

    /* ============ Variant hook ============ */

    /// @dev Deploys the variant with `admin` as admin/owner, no forwarder and no token bound.
    function _deployEngine(address admin) internal virtual returns (address);

    function setUp() public virtual {
        engine = RuleEngineBase(_deployEngine(ADMIN));
        handler = new RuleEngineHandler(engine, ADMIN);
        targetContract(address(handler));
    }

    /* ============ Rule set ============ */

    /// @notice The engine holds exactly the rules the successful calls imply, with the right count.
    function invariant_RuleSetMatchesModel() public view {
        assertEq(engine.rulesCount(), handler.modelRuleCount(), "rulesCount");
        for (uint256 i = 0; i < handler.rulePoolLength(); ++i) {
            address r = handler.rulePool(i);
            assertEq(engine.containsRule(IRule(r)), handler.modelHasRule(r), "containsRule");
        }
    }

    /// @notice No duplicate, no `address(0)`, only rules the ERC-165 gate accepts; `rules()` and `rule(i)` agree.
    function invariant_RuleSetIsWellFormed() public view {
        address[] memory rs = engine.rules();
        assertEq(rs.length, engine.rulesCount(), "rules().length");
        for (uint256 i = 0; i < rs.length; ++i) {
            assertTrue(rs[i] != address(0), "zero rule");
            assertTrue(handler.isAcceptedRule(rs[i]), "rule rejected by the gate is in the set");
            assertTrue(
                IRule(rs[i]).supportsInterface(RuleInterfaceId.IRULE_INTERFACE_ID)
                    || IRule(rs[i]).supportsInterface(RuleInterfaceId.IRULE_LEGACY_INTERFACE_ID),
                "rule without a rule ID"
            );
            assertEq(engine.rule(i), rs[i], "rule(i)");
            for (uint256 j = i + 1; j < rs.length; ++j) {
                assertTrue(rs[i] != rs[j], "duplicate rule");
            }
        }
    }

    /// @notice The cap is the last value set, and never zero.
    function invariant_MaxRulesMatchesModelAndIsNotZero() public view {
        assertEq(engine.maxRules(), handler.modelMaxRules(), "maxRules");
        assertGt(engine.maxRules(), 0, "maxRules is zero");
    }

    /* ============ Token binding ============ */

    /// @notice F-3. No address is both a rule and a bound token.
    function invariant_RulesAndBoundTokensAreDisjoint() public view {
        address[] memory rs = engine.rules();
        for (uint256 i = 0; i < rs.length; ++i) {
            assertFalse(engine.isTokenBound(rs[i]), "a rule is also a bound token");
        }
    }

    /// @notice A token is bound exactly when the successful calls imply it; `getTokenBounds()` agrees.
    function invariant_BoundTokensMatchModel() public view {
        address[] memory ts = engine.getTokenBounds();
        assertEq(ts.length, handler.modelBoundCount(), "getTokenBounds().length");
        for (uint256 i = 0; i < handler.tokenPoolLength(); ++i) {
            address t = handler.tokenPool(i);
            assertEq(engine.isTokenBound(t), handler.modelIsBound(t), "isTokenBound");
        }
        for (uint256 i = 0; i < handler.rulePoolLength(); ++i) {
            address t = handler.rulePool(i);
            assertEq(engine.isTokenBound(t), handler.modelIsBound(t), "isTokenBound (rule pool)");
        }
        for (uint256 i = 0; i < ts.length; ++i) {
            assertTrue(ts[i] != address(0), "zero token bound");
            assertTrue(engine.isTokenBound(ts[i]), "listed but not bound");
            for (uint256 j = i + 1; j < ts.length; ++j) {
                assertTrue(ts[i] != ts[j], "duplicate token");
            }
        }
    }
}
