// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "CMTAT/mocks/MinimalForwarderMock.sol";
import "../utils/SanctionListOracle.sol";
import {RuleSanctionList, SanctionsList} from "src/rules/validation/RuleSanctionList.sol";
/**
 * @title General functions of the ruleSanctionList
 */
contract RuleSanctionListDeploymentTest is Test, HelperContract {
    RuleSanctionList ruleSanctionList;
    SanctionListOracle sanctionlistOracle;
    event Testa();

    // Arrange
    function setUp() public {}

    function testRightDeployment() public {
        // Arrange
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock();
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        ruleSanctionList = new RuleSanctionList(
            SANCTIONLIST_OPERATOR_ADDRESS,
            address(forwarder),
            ZERO_ADDRESS
        );

        // assert
        resBool = ruleSanctionList.hasRole(
            SANCTIONLIST_ROLE,
            SANCTIONLIST_OPERATOR_ADDRESS
        );
        assertEq(resBool, true);
        resBool = ruleSanctionList.isTrustedForwarder(address(forwarder));
        assertEq(resBool, true);
    }

    function testCannotDeployContractIfAdminAddressIsZero() public {
        // Arrange
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock();
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.expectRevert(
            RuleSanctionList_AdminWithAddressZeroNotAllowed.selector
        );
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        ruleSanctionList = new RuleSanctionList(
            address(0),
            address(forwarder),
            ZERO_ADDRESS
        );
    }

    function testCanSetAnOracleAtDeployment() public {
        sanctionlistOracle = new SanctionListOracle();
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        // TODO: Event seems not checked by Foundry at deployment
        emit SetSanctionListOracle(address(sanctionlistOracle));

        ruleSanctionList = new RuleSanctionList(
            SANCTIONLIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            address(sanctionlistOracle)
        );
        assertEq(
            address(ruleSanctionList.sanctionsList()),
            address(sanctionlistOracle)
        );
    }
}
