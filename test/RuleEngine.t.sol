//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "CMTAT/modules/PauseModule.sol";
import "./HelperContract.sol";
import "src/RuleEngine.sol";


contract RuleEngineTest is Test, HelperContract, ValidationModule, RuleWhitelist {
    //Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";
    
    RuleEngineMock ruleEngineMock;
    RuleWhitelist ruleWhitelist = new RuleWhitelist();
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;
    
    // Arrange
    function setUp() public {
        // global arrange
        vm.prank(OWNER);
        CMTAT_CONTRACT = new CMTAT();
        CMTAT_CONTRACT.initialize(
            OWNER,
            ZERO_ADDRESS,
            "CMTA Token",
            "CMTAT",
            "CMTAT_ISIN",
            "https://cmta.ch"
        );
        // specific arrange
        vm.prank(OWNER);
        ruleEngineMock = new RuleEngineMock(ruleWhitelist);
        vm.prank(OWNER);
        CMTAT_CONTRACT.mint(ADDRESS1, 31);
        vm.prank(OWNER);
        CMTAT_CONTRACT.mint(ADDRESS2, 32);
        vm.prank(OWNER);
        CMTAT_CONTRACT.mint(ADDRESS3, 33);
        vm.prank(OWNER);

        CMTAT_CONTRACT.setRuleEngine(ruleEngineMock);
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
}