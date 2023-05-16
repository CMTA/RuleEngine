// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
//import "CMTAT/CMTAT_STANDALONE.sol";
import "../../HelperContract.sol";
import "src/RuleEngine.sol";

/**
@title Tests on the Access Control
*/
contract RuleEngineAccessControlTest is Test, HelperContract{
    RuleEngine ruleEngineMock;
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
        ruleWhitelist = new RuleWhitelist(WHITELIST_OPERATOR_ADDRESS, ZERO_ADDRESS);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(RULE_ENGINE_OPERATOR_ADDRESS, ZERO_ADDRESS);
        resUint256 = ruleEngineMock.rulesCount();

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannnotAttackerSetRules() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist(WHITELIST_OPERATOR_ADDRESS, ZERO_ADDRESS);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist(WHITELIST_OPERATOR_ADDRESS, ZERO_ADDRESS);
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);

        // Act
        vm.prank(ATTACKER);
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ATTACKER),
                " is missing role ",
                RULE_ENGINE_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
        (bool success, ) = address(ruleEngineMock).call(
            abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab)
        );

        // Assert
        assertEq(success, true);
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannnotAttackerClearRules() public {
        // Act
        vm.prank(ATTACKER);
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ATTACKER),
                " is missing role ",
                RULE_ENGINE_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
        ruleEngineMock.clearRules();

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerAddRule() public {
        // Act
        vm.prank(ATTACKER);
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ATTACKER),
                " is missing role ",
                RULE_ENGINE_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
        ruleEngineMock.addRule(ruleWhitelist);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

    function testCannotAttackerRemoveRule() public {
        // Act
        vm.prank(ATTACKER);
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ATTACKER),
                " is missing role ",
                RULE_ENGINE_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
        ruleEngineMock.removeRule(ruleWhitelist, 0);

        // Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);
    }

}
