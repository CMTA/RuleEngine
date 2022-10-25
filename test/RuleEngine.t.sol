//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "CMTAT/modules/PauseModule.sol";
import "./HelperContract.sol";
import "src/RuleEngine.sol";


contract RuleEngineTest is Test, HelperContract, ValidationModule, RuleWhitelist {
    RuleEngineMock ruleEngineMock;
    RuleWhitelist ruleWhitelist = new RuleWhitelist();
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
        vm.prank(OWNER);
        ruleEngineMock = new RuleEngineMock(ruleWhitelist);
        resUint256 = ruleEngineMock.ruleLength();

        // Assert
        assertEq(resUint256, 1);
    }

    function testCanSetRules() public { 
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        RuleWhitelist ruleWhitelist2 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](2);
        ruleWhitelistTab[0] = IRule(ruleWhitelist1);
        ruleWhitelistTab[1] = IRule(ruleWhitelist2);
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngineMock.setRules, ruleWhitelistTab));
        
        // Arrange - Assert
        assertEq(success, true);

        // Assert
        resUint256 = ruleEngineMock.ruleLength(); 
        assertEq(resUint256, 2);
    }

    function testCanDetectTransferRestrictionOK() public { 
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](1);
        ruleWhitelistTab[0] = ruleWhitelist1;
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngineMock.setRules, ruleWhitelistTab));
        
        // Arrange - Assert
        assertEq(success, true);
        ruleWhitelist1.addAddressToTheWhitelist(ADDRESS1);
        ruleWhitelist1.addAddressToTheWhitelist(ADDRESS2);
        
        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(ADDRESS1, ADDRESS2, 20);
        
        // Assert 
        assertEq(resUint8, 0);
    }

    function testCanDetectTransferRestrictionWithFrom() public { 
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](1);
        ruleWhitelistTab[0] = ruleWhitelist1;
         (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngineMock.setRules, ruleWhitelistTab));

        // Arrange - Assert
        assertEq(success, true);

        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(ADDRESS1, ADDRESS2, 20);
        
        // Assert 
        assertEq(resUint8, CODE_ADDRESS_FROM_NOT_WHITELISTED);
    }

    function testCanDetectTransferRestrictionWithTo() public { 
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](1);
        ruleWhitelistTab[0] = ruleWhitelist1;
        ruleWhitelist1.addAddressToTheWhitelist(ADDRESS1);
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngineMock.setRules, ruleWhitelistTab));
        
        // Arrange - Assert
        assertEq(success, true);
        
        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(ADDRESS1, ADDRESS2, 20);
        
        // Assert 
        assertEq(resUint8, CODE_ADDRESS_TO_NOT_WHITELISTED);
    } 


     function testMessageForTransferRestrictionWithValidRC() public{
        // Act
        resString = ruleEngineMock.messageForTransferRestriction(CODE_ADDRESS_FROM_NOT_WHITELISTED);
        
        // Assert 
        assertEq(resString, TEXT_ADDRESS_FROM_NOT_WHITELISTED);
    }

    function testMessageForTransferRestrictionNoRule() public{
        // Act
        resString = ruleEngineMock.messageForTransferRestriction(50);
        
        // Assert 
        assertEq(resString, "Unknown restriction code");
    }


    function testMessageForTransferRestrictionWUnknownRestrictionCode() public{
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](1);
        ruleWhitelistTab[0] = ruleWhitelist1;
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngineMock.setRules, ruleWhitelistTab));
        // Arrange - Assert
        assertEq(success, true);
        
        // Act
        resString = ruleEngineMock.messageForTransferRestriction(50);
        
        // Assert 
        assertEq(resString, "Unknown restriction code");
    }

    function testValidateTransferOK() public{
         // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](1);
        ruleWhitelistTab[0] = ruleWhitelist1;
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngineMock.setRules, ruleWhitelistTab));
        
        // Arrange - Assert
        assertEq(success, true);
        ruleWhitelist1.addAddressToTheWhitelist(ADDRESS1);
        ruleWhitelist1.addAddressToTheWhitelist(ADDRESS2);
        
        // Act
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
        
        // Assert 
        assertEq(resBool, true);
    }

    function testValidateTransferRestricted() public {
        // Arrange
        RuleWhitelist ruleWhitelist1 = new RuleWhitelist();
        IRule[] memory ruleWhitelistTab = new IRule[](1);
        ruleWhitelistTab[0] = ruleWhitelist1;
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngineMock.setRules, ruleWhitelistTab));
        
        // Arrange - Assert
        assertEq(success, true);
        
        // Act
        resBool = ruleEngineMock.validateTransfer(ADDRESS1, ADDRESS2, 20);
        
        // Assert 
        assertFalse(resBool);
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
        (bool success, ) = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngineMock.setRules, ruleWhitelistTab));
        
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
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngineMock.setRules, ruleWhitelistTab));
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
        (bool success, )  = address(ruleEngineMock).call(
        abi.encodeCall(RuleEngineMock.setRules, ruleWhitelistTab));
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