// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MinimalForwarderMock} from "CMTAT/mocks/MinimalForwarderMock.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
import {ICompliance} from "src/mocks/ICompliance.sol";
import {IERC7551ComplianceSubset} from "src/mocks/IERC7551ComplianceSubset.sol";
// forge-lint: disable-next-line(unaliased-plain-import)
import "../HelperContractOwnable2Step.sol";

/**
 * @title Deployment and ownership tests for RuleEngineOwnable2Step
 */
contract RuleEngineOwnable2StepTest is Test, HelperContractOwnable2Step {
    bytes4 constant ERC173_ID = 0x7f5828d0;

    function setUp() public {
        ruleEngineMock = new RuleEngineOwnable2Step(OWNER_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS);
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
        forwarder.initialize(ERC2771ForwarderDomain);

        RuleEngineOwnable2Step ruleEngineWithForwarder =
            new RuleEngineOwnable2Step(OWNER_ADDRESS, address(forwarder), ZERO_ADDRESS);
        assertTrue(ruleEngineWithForwarder.isTrustedForwarder(address(forwarder)));
    }

    function testSupportsOwnableAndComplianceInterfaces() public view {
        assertTrue(ruleEngineMock.supportsInterface(type(IERC165).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(ERC173_ID));
        assertTrue(ruleEngineMock.supportsInterface(RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID));
        assertTrue(ruleEngineMock.supportsInterface(type(ICompliance).interfaceId));
        assertTrue(ruleEngineMock.supportsInterface(type(IERC7551ComplianceSubset).interfaceId));
    }

    function testOwnerCanAddRule() public {
        vm.prank(OWNER_ADDRESS);
        ruleEngineMock.addRule(ruleConditionalTransferLight);
        assertEq(ruleEngineMock.rulesCount(), 1);
    }

    function testNonOwnerCannotAddRule() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, ATTACKER));
        vm.prank(ATTACKER);
        ruleEngineMock.addRule(ruleConditionalTransferLight);
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
}
