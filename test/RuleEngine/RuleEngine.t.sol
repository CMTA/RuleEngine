//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";


contract RuleEngineTest is Test, HelperContract, RuleWhitelist {
    RuleEngine ruleEngineMock;
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
        ruleWhitelist = new RuleWhitelist();
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(ruleWhitelist);
        resUint256 = ruleEngineMock.ruleLength();

        // Assert
        assertEq(resUint256, 1);
    }

    function testCanSetRules() public { 
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        
        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab));
        
        // Assert
        assertEq(success, true);
        resUint256 = ruleEngineMock.ruleLength(); 
        assertEq(resUint256, 2);
    }

    function testCanClearRules() public{
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);

        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab));
        
        // Assert - Arrange
        assertEq(success, true);
        resUint256 = ruleEngineMock.ruleLength(); 
        assertEq(resUint256, 2);

        // Act
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRules();

        // Assert
        resUint256 = ruleEngineMock.ruleLength(); 
        assertEq(resUint256, 0);
    }

    function testRuleLength() public {
        // Act
        resUint256 = ruleEngineMock.ruleLength();

        // Assert
        assertEq(resUint256, 1);
        
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool success, ) = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab));
        
        // Arrange - Assert
        assertEq(success, true);

        // Act
        resUint256 = ruleEngineMock.ruleLength(); 
        
        // Assert
        assertEq(resUint256, 2);
    }

    function testGetRule() public {
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab));
        // Arrange - Assert
        assertEq(success, true);
        
        // Act
        IRule rule = ruleEngineMock.rule(0);
        
        // Assert
        assertEq(address(rule), address(ruleWhitelist1));
    }

     function testGetRules() public {
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngine.setRules, ruleWhitelistTab));
        // Arrange - Assert
        assertEq(success, true);
        
        // Act
        IRule[] memory rules = ruleEngineMock.rules();
        
        // Assert
        assertEq(ruleWhitelistTab.length, rules.length);
        for(uint256 i = 0; i < rules.length; ++i){
            assertEq(address(ruleWhitelistTab[i]), address(rules[i]));
        }
        
    }

}