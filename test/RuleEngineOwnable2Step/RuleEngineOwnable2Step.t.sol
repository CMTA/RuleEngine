// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MinimalForwarderMock} from "CMTAT/mocks/MinimalForwarderMock.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
import {ICompliance} from "src/mocks/ICompliance.sol";
import {IERC3643ComplianceExtendedSubset} from "src/mocks/IERC3643ComplianceExtendedSubset.sol";
import {IERC173Subset} from "src/mocks/IERC173Subset.sol";
import {IOwnable2StepSubset} from "src/mocks/IOwnable2StepSubset.sol";
import {IERC1404Subset} from "src/mocks/IERC1404Subset.sol";
import {IERC7551ComplianceSubset} from "src/mocks/IERC7551ComplianceSubset.sol";
import {ComplianceInterfaceId} from "src/modules/library/ComplianceInterfaceId.sol";
import {ERC1404InterfaceId} from "src/modules/library/ERC1404InterfaceId.sol";
import {OwnableInterfaceId} from "src/modules/library/OwnableInterfaceId.sol";
import {Ownable2StepInterfaceId} from "src/modules/library/Ownable2StepInterfaceId.sol";
import {ERC3643ComplianceModule} from "src/modules/ERC3643ComplianceModule.sol";
import {RulesManagementModuleInvariantStorage} from "src/modules/library/RulesManagementModuleInvariantStorage.sol";
import {RuleEngineOwnable2StepExposed} from "src/mocks/RuleEngineExposed.sol";
// forge-lint: disable-next-line(unaliased-plain-import)
import "../HelperContractOwnable2Step.sol";

/**
 * @title Deployment and ownership tests for RuleEngineOwnable2Step
 */
contract RuleEngineOwnable2StepTest is Test, HelperContractOwnable2Step {
    address internal constant TOKEN_1 = address(0x1111);
    address internal constant TOKEN_2 = address(0x2222);
    RuleEngineOwnable2StepExposed internal ruleEngineOwnable2StepExposed;

    function setUp() public {
        ruleEngineMock = new RuleEngineOwnable2Step(OWNER_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS);
        ruleEngineOwnable2StepExposed = new RuleEngineOwnable2StepExposed(OWNER_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS);
        ruleConditionalTransferLight =
            new RuleConditionalTransferLight(CONDITIONAL_TRANSFER_OPERATOR_ADDRESS, ruleEngineMock);
    }

    function testDeploymentSetsOwner() public view {
        assertEq(ruleEngineMock.owner(), OWNER_ADDRESS);
    }

    function testCannotDeployContractIfOwnerAddressIsZero() public {
        vm.expectRevert(abi.encodeWithSignature("OwnableInvalidOwner(address)", ZERO_ADDRESS));
        new RuleEngineOwnable2Step(ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS);
    }

    function testTrustedForwarderSetAtDeployment() public {
        MinimalForwarderMock forwarder = new MinimalForwarderMock();
        forwarder.initialize(ERC2771_FORWARDER_DOMAIN);

        RuleEngineOwnable2Step ruleEngineWithForwarder =
            new RuleEngineOwnable2Step(OWNER_ADDRESS, address(forwarder), ZERO_ADDRESS);
        assertTrue(ruleEngineWithForwarder.isTrustedForwarder(address(forwarder)));
    }

    function testSupportsOwnableAndComplianceInterfaces() public view {
        assertTrue(ruleEngineMock.supportsInterface(type(IERC165).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(ERC1404InterfaceId.IERC1404_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC1404Subset).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(OwnableInterfaceId.IERC173_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC173Subset).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(Ownable2StepInterfaceId.IOWNABLE2STEP_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(IOwnable2StepSubset).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(ICompliance).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(ComplianceInterfaceId.ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC3643ComplianceExtendedSubset).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC7551ComplianceSubset).interfaceId));
    }

    function testOwnerCanAddRule() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);
        assertEq(ruleEngineMock.rulesCount(), 1);
    }

    function testDefaultMaxRulesIsTen() public view {
        assertEq(ruleEngineMock.maxRules(), 10);
    }

    function testOwnerCanSetMaxRules() public {
        vm.expectEmit(false, false, false, true);
        emit RulesManagementModuleInvariantStorage.SetMaxRules(12);
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.setMaxRules(12);
        assertEq(ruleEngineMock.maxRules(), 12);
    }

    function testNonOwnerCannotAddRule() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ATTACKER));
        vm.prank(ATTACKER);
        ruleEngineMock.addRule(ruleConditionalTransferLight);
    }

    function testNonOwnerCannotSetMaxRules() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ATTACKER));
        vm.prank(ATTACKER);
        ruleEngineMock.setMaxRules(12);
    }

    function testTransferOwnershipSetsPendingOwner() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.transferOwnership(NEW_OWNER_ADDRESS);

        assertEq(ruleEngineMock.owner(), OWNER_ADDRESS);
        assertEq(ruleEngineMock.pendingOwner(), NEW_OWNER_ADDRESS);
    }

    function testPendingOwnerCanAcceptOwnership() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.transferOwnership(NEW_OWNER_ADDRESS);

        vm.prank(NEW_OWNER_ADDRESS);
        ruleEngineMock.acceptOwnership();

        assertEq(ruleEngineMock.owner(), NEW_OWNER_ADDRESS);
        assertEq(ruleEngineMock.pendingOwner(), ZERO_ADDRESS);
    }

    function testNonPendingOwnerCannotAcceptOwnership() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.transferOwnership(NEW_OWNER_ADDRESS);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ATTACKER));
        vm.prank(ATTACKER);
        ruleEngineMock.acceptOwnership();
    }

    function testOwnerCannotTransferOwnershipToRuleAddress() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);

        vm.expectRevert(
            RulesManagementModuleInvariantStorage.RuleEngine_RulesManagementModule_RuleAccountCannotReceivePrivileges
                .selector
        );
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.transferOwnership(address(ruleConditionalTransferLight));
    }

    function testOwnerKeepsRightsUntilAcceptOwnership() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.transferOwnership(NEW_OWNER_ADDRESS);

        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);

        assertEq(ruleEngineMock.rulesCount(), 1);
    }

    function testOldOwnerLosesRightsAfterAcceptOwnership() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.transferOwnership(NEW_OWNER_ADDRESS);

        vm.prank(NEW_OWNER_ADDRESS);
        ruleEngineMock.acceptOwnership();

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, OWNER_ADDRESS));
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.clearRules();
    }

    function testApprovedTokenCanBindItself() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.setTokenSelfBindingApproval(TOKEN_1, true);

        vm.prank(TOKEN_1);
        ruleEngineMock.bindToken(TOKEN_1);

        assertTrue(ruleEngineMock.isTokenBound(TOKEN_1));
    }

    function testApprovedBoundTokenCanUnbindItself() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.setTokenSelfBindingApproval(TOKEN_1, true);

        vm.prank(TOKEN_1);
        ruleEngineMock.bindToken(TOKEN_1);

        vm.prank(TOKEN_1);
        ruleEngineMock.unbindToken(TOKEN_1);

        assertFalse(ruleEngineMock.isTokenBound(TOKEN_1));
    }

    function testTokenCannotBindItselfWithoutApproval() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, TOKEN_1));
        vm.prank(TOKEN_1);
        ruleEngineMock.bindToken(TOKEN_1);
    }

    function testTokenCannotUnbindItselfWithoutApproval() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(TOKEN_1);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, TOKEN_1));
        vm.prank(TOKEN_1);
        ruleEngineMock.unbindToken(TOKEN_1);
    }

    function testTokenCannotBindAnotherToken() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, TOKEN_1));
        vm.prank(TOKEN_1);
        ruleEngineMock.bindToken(TOKEN_2);
    }

    function testTokenCannotUnbindAnotherToken() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(TOKEN_2);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, TOKEN_1));
        vm.prank(TOKEN_1);
        ruleEngineMock.unbindToken(TOKEN_2);
    }

    function testOnlyOwnerCanSetTokenSelfBindingApproval() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, TOKEN_1));
        vm.prank(TOKEN_1);
        ruleEngineMock.setTokenSelfBindingApproval(TOKEN_1, true);
    }

    function testCannotSetTokenSelfBindingApprovalForZeroAddress() public {
        vm.expectRevert(ERC3643ComplianceModule.RuleEngine_ERC3643Compliance_InvalidTokenAddress.selector);
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.setTokenSelfBindingApproval(address(0), true);
    }

    function testCanSetTokenSelfBindingApprovalBatch() public {
        address[] memory tokens = new address[](2);
        tokens[0] = TOKEN_1;
        tokens[1] = TOKEN_2;

        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.setTokenSelfBindingApprovalBatch(tokens, true);

        assertTrue(ruleEngineMock.isTokenSelfBindingApproved(TOKEN_1));
        assertTrue(ruleEngineMock.isTokenSelfBindingApproved(TOKEN_2));
    }

    function testSetTokenSelfBindingApprovalBatchEmitsSingleBatchEvent() public {
        address[] memory tokens = new address[](2);
        tokens[0] = TOKEN_1;
        tokens[1] = TOKEN_2;

        vm.recordLogs();
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.setTokenSelfBindingApprovalBatch(tokens, true);
        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], keccak256("TokenSelfBindingApprovalBatchSet(address[],bool)"));
    }

    function testOnlyOwnerCanSetTokenSelfBindingApprovalBatch() public {
        address[] memory tokens = new address[](1);
        tokens[0] = TOKEN_1;

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, TOKEN_1));
        vm.prank(TOKEN_1);
        ruleEngineMock.setTokenSelfBindingApprovalBatch(tokens, true);
    }

    function testCannotSetTokenSelfBindingApprovalBatchWithZeroAddress() public {
        address[] memory tokens = new address[](2);
        tokens[0] = TOKEN_1;
        tokens[1] = address(0);

        vm.expectRevert(ERC3643ComplianceModule.RuleEngine_ERC3643Compliance_InvalidTokenAddress.selector);
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.setTokenSelfBindingApprovalBatch(tokens, true);
    }

    function testCanBindTokensBatch() public {
        address[] memory tokens = new address[](2);
        tokens[0] = TOKEN_1;
        tokens[1] = TOKEN_2;

        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindTokens(tokens);

        assertTrue(ruleEngineMock.isTokenBound(TOKEN_1));
        assertTrue(ruleEngineMock.isTokenBound(TOKEN_2));
    }

    function testCanUnbindTokensBatch() public {
        address[] memory tokens = new address[](2);
        tokens[0] = TOKEN_1;
        tokens[1] = TOKEN_2;

        vm.startPrank(OWNER_ADDRESS);
        ruleEngineMock.bindTokens(tokens);
        ruleEngineMock.unbindTokens(tokens);
        vm.stopPrank();

        assertFalse(ruleEngineMock.isTokenBound(TOKEN_1));
        assertFalse(ruleEngineMock.isTokenBound(TOKEN_2));
    }

    function testOnlyOwnerCanBindTokensBatch() public {
        address[] memory tokens = new address[](1);
        tokens[0] = TOKEN_1;

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, TOKEN_1));
        vm.prank(TOKEN_1);
        ruleEngineMock.bindTokens(tokens);
    }

    function testOnlyOwnerCanUnbindTokensBatch() public {
        address[] memory tokens = new address[](1);
        tokens[0] = TOKEN_1;

        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindTokens(tokens);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, TOKEN_1));
        vm.prank(TOKEN_1);
        ruleEngineMock.unbindTokens(tokens);
    }

    function testCannotBindTokensBatchWithZeroAddress() public {
        address[] memory tokens = new address[](2);
        tokens[0] = TOKEN_1;
        tokens[1] = address(0);

        vm.expectRevert(ERC3643ComplianceModule.RuleEngine_ERC3643Compliance_InvalidTokenAddress.selector);
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindTokens(tokens);
    }

    function testCannotBindTokensBatchWithAlreadyBoundToken() public {
        address[] memory tokens = new address[](2);
        tokens[0] = TOKEN_1;
        tokens[1] = TOKEN_2;

        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(TOKEN_1);

        vm.expectRevert(ERC3643ComplianceModule.RuleEngine_ERC3643Compliance_TokenAlreadyBound.selector);
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindTokens(tokens);
    }

    function testCannotUnbindTokensBatchWithTokenNotBound() public {
        address[] memory tokens = new address[](2);
        tokens[0] = TOKEN_1;
        tokens[1] = TOKEN_2;

        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.bindToken(TOKEN_1);

        vm.expectRevert(ERC3643ComplianceModule.RuleEngine_ERC3643Compliance_TokenNotBound.selector);
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.unbindTokens(tokens);
    }

    function testMsgDataReturnsCalldata() public view {
        bytes memory data = ruleEngineOwnable2StepExposed.exposedMsgData();
        assertEq(data.length, 4);
        // forge-lint: disable-next-line(unsafe-typecast)
        assertEq(bytes4(data), ruleEngineOwnable2StepExposed.exposedMsgData.selector);
    }
}
