//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "CMTAT/modules/PauseModule.sol";
import "./HelperContract.sol";
import "src/RuleEngine.sol";


contract RuleWhiteListTest is Test, HelperContract, ValidationModule, RuleWhitelist {
    //Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";
    
    RuleEngineMock ruleEngineMock;
    RuleWhitelist ruleWhitelist = new RuleWhitelist();
    uint256 resUint256;
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

    function testReturnFalseIfAddressNotWhitelisted() public {
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        // Assert
        assertFalse(resBool);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        // Assert
        assertFalse(resBool);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS3);
        // Assert
        assertFalse(resBool);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(address(0x0));
        // Assert
        assertFalse(resBool);
    }

         function testAddressIsIndicatedAsWhitelisted() public {
        // Arrange
        ruleWhitelist.addOneAddressToTheWhitelist(ADDRESS1);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        // Assert
        assertEq(resBool, true);
    }

    
    
    function testReturnTrueIfAddressIsWhitelisted() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        (bool success, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addListAddressToTheWhitelist(address[])", whitelist)
        );
        require(success);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS3);
        // Assert
        assertFalse(resBool);
    }

    function testAddOneAddressToTheWhitelist() public {
        // Arrange
        ruleWhitelist.addOneAddressToTheWhitelist(ADDRESS1);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        // Assert
        assertEq(resBool, true);
    }


    function testAddListAddressToTheWhitelist() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        (bool success, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addListAddressToTheWhitelist(address[])", whitelist)
        );
        require(success);
        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS3);
        assertFalse(resBool);
    }

    function testRemoveListAddressToTheWhitelist() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        (bool success, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addListAddressToTheWhitelist(address[])", whitelist)
        );
        require(success);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);

        // Act
        (success, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("removeListAddressToTheWhitelist(address[])", whitelist)
        );

        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertFalse(resBool);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertFalse(resBool);
    }

    function testCanReturnTransferRestrictionCode() public{
        // Act
        resBool = canReturnTransferRestrictionCode(CODE_ADDRESS_FROM_NOT_WHITELISTED);
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = canReturnTransferRestrictionCode(CODE_ADDRESS_TO_NOT_WHITELISTED);
        // Assert
        assertEq(resBool, true);
        // Act
        resBool = canReturnTransferRestrictionCode(CODE_NONEXISTENT);
        // Assert
        assertFalse(resBool);
    }

    function testReturnTheRightMessageForAGivenCode() public {
        // Assert
        resString = ruleWhitelist.messageForTransferRestriction(
                CODE_ADDRESS_FROM_NOT_WHITELISTED
        );
        // Assert
        assertEq(resString, TEXT_ADDRESS_FROM_NOT_WHITELISTED);
        // Act
        resString = ruleWhitelist.messageForTransferRestriction(
                CODE_ADDRESS_TO_NOT_WHITELISTED);
        // Assert
        assertEq(resString, TEXT_ADDRESS_TO_NOT_WHITELISTED);
        // Act
        resString = ruleWhitelist.messageForTransferRestriction(
                CODE_NONEXISTENT
        );
        // Assert
        assertEq(resString, TEXT_CODE_NOT_FOUND);
    }

    function testIsTransferValid() public {
         // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        (bool success, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addListAddressToTheWhitelist(address[])", whitelist)
        );
        require(success);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);
        
        // Act
        // ADDRESS1 -> ADDRESS2
        resBool = ruleWhitelist.isTransferValid(ADDRESS1, ADDRESS2, 20);
        assertEq(resBool, true);
        // ADDRESS2 -> ADDRESS1
        resBool = ruleWhitelist.isTransferValid(ADDRESS2, ADDRESS1, 20);
        assertEq(resBool, true);
    }

    function testTransferDetectedAsInvalid() public{
        // Act
        resBool = isTransferValid(ADDRESS1, ADDRESS2, 20);
        // Assert
        assertFalse(resBool);
    }

}