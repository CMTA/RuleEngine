// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/rules/RuleSanctionList.sol";
import "CMTAT/mocks/MinimalForwarderMock.sol";
/**
@title General functions of the ruleSanctionList
*/
contract RuleSanctionListDeploymentTest is Test, HelperContract {
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;
    RuleSanctionList ruleSanctionList;
    // Arrange
    function setUp() public {

    }

    function testRightDeployment() public {
        // Arrange
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock(
        );
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        ruleSanctionList = new RuleSanctionList(
            SANCTIONLIST_OPERATOR_ADDRESS,
            address(forwarder)
        );

        // assert
        resBool = ruleSanctionList.hasRole(SANCTIONLIST_ROLE, SANCTIONLIST_OPERATOR_ADDRESS);
        assertEq(resBool, true);
        resBool = ruleSanctionList.isTrustedForwarder(address(forwarder));
        assertEq(resBool, true);
    }

    function testCannotDeployContractIfAdminAddressIsZero() public {
        // Arrange
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock(
        );
        forwarder.initialize(ERC2771ForwarderDomain);
        vm.expectRevert(RuleSanctionList_AdminWithAddressZeroNotAllowed.selector);
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        ruleSanctionList = new RuleSanctionList(
            address(0),
            address(forwarder)
        );
    }
}
