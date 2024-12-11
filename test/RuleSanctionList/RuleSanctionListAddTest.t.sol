// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";
import "../utils/SanctionListOracle.sol";

/**
 * @title General functions of the ruleSanctionList
 */
contract RuleSanctionlistAddTest is Test, HelperContract {
    // Custom error openZeppelin
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    SanctionListOracle sanctionlistOracle;
    RuleSanctionList ruleSanctionList;

    // Arrange
    function setUp() public {
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        sanctionlistOracle = new SanctionListOracle();
        sanctionlistOracle.addToSanctionsList(ATTACKER);
        ruleSanctionList = new RuleSanctionList(
            SANCTIONLIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
    }

    function testCanSetandRemoveOracle() public {
        // ADD
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        emit SetSanctionListOracle(address(sanctionlistOracle));
        ruleSanctionList.setSanctionListOracle(address(sanctionlistOracle));

        SanctionsList sanctionListOracleGet = ruleSanctionList.sanctionsList();
        // Assert
        vm.assertEq(
            address(sanctionListOracleGet),
            address(sanctionlistOracle)
        );
        // Remove
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        emit SetSanctionListOracle(ZERO_ADDRESS);
        ruleSanctionList.setSanctionListOracle(ZERO_ADDRESS);
        // Assert
        sanctionListOracleGet = ruleSanctionList.sanctionsList();
        vm.assertEq(address(sanctionListOracleGet), address(ZERO_ADDRESS));
    }

    function testCannotAttackerSetOracle() public {
        vm.prank(ATTACKER);
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessControlUnauthorizedAccount.selector,
                ATTACKER,
                SANCTIONLIST_ROLE
            )
        );
        ruleSanctionList.setSanctionListOracle(address(sanctionlistOracle));
    }
}
