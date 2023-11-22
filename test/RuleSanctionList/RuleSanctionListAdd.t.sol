// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";
import "src/rules/RuleSanctionList.sol";
import "../utils/SanctionListOracle.sol";
/**
@title General functions of the ruleSanctionList
*/
contract RuleSanctionlistTest is Test, HelperContract {
    // Custom error openZeppelin
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;
    SanctionListOracle sanctionlistOracle;
    RuleSanctionList ruleSanctionList;
    // Arrange
    function setUp() public {
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        sanctionlistOracle = new SanctionListOracle();
        sanctionlistOracle.addToSanctionsList(ATTACKER);
        ruleSanctionList = new RuleSanctionList(
            SANCTIONLIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );

    }

    function testCanSetOracle() public {
        vm.prank(SANCTIONLIST_OPERATOR_ADDRESS);
        ruleSanctionList.setSanctionListOracle(address(sanctionlistOracle));
    }

    function testCannotAttackerSetOracle() public {
        vm.prank(ATTACKER);
        vm.expectRevert(
        abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, ATTACKER, SANCTIONLIST_ROLE));  
        ruleSanctionList.setSanctionListOracle(address(sanctionlistOracle));
    }
}
