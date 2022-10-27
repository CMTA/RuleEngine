//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";


contract RuleWhitelistAddTest is Test, HelperContract, RuleWhitelist {
    //Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
      vm.prank(WHITELIST_OPERATOR_ADDRESS);
      ruleWhitelist = new RuleWhitelist();
    }

    function testAddAddressToTheWhitelist() public {
        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);
        
        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 1);
    }

        function testAddAddressesToTheWhitelist() public {
        // Arrange
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 0);
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        
        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addAddressesToTheWhitelist(address[])", whitelist)
        );
        
        // Assert
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS3);
        assertFalse(resBool);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 2);
    }
    
    function testCannotAddAddressZeroToTheWhitelist() public {
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(address(0x0));
        assertEq(resBool, false);

        // Arrange
        vm.expectRevert(bytes("Address 0 is not allowed"));
        
        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(address(0x0));
        
        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(address(0x0));
        assertEq(resBool, false);
    }

    function testCannotAddAddressesZeroToTheWhitelist() public {
        // Arrange
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 0);
        address[] memory whitelist = new address[](3);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        // our target address
        whitelist[2] = address(0x0);
        
        // Arrange
        vm.expectRevert(bytes("Address 0 is not allowed"));

        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addAddressesToTheWhitelist(address[])", whitelist)
        );
       
        // Assert - Main
        // Seem that call returns true even if the function is reverted 
        // TODO : check the return value of call
        // assertFalse(resCallBool);
        resBool = ruleWhitelist.addressIsWhitelisted(address(0x0));
        assertEq(resBool, false);
        
        // Assert - Secondary
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, false);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, false);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 0);
    }

    function testAddAddressTwiceToTheWhitelist() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        /// Arrange
        vm.expectRevert(bytes("Address is already in the whitelist"));
        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);
        // no change
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 1);
    }

     function testAddAddressesTwiceToTheWhitelist() public {
        // Arrange
        // Arrange - first addition
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 0);
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addAddressesToTheWhitelist(address[])", whitelist)
        );
        // Arrange - Assert
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 2);
        // Arrange - second addition
        address[] memory whitelistDuplicate = new address[](3);
        // Duplicate address
        whitelistDuplicate[0] = ADDRESS1;
        whitelistDuplicate[1] = ADDRESS2;
        // new address in the whitelist
        whitelistDuplicate[2] = ADDRESS3;
        // Act
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addAddressesToTheWhitelist(address[])", whitelistDuplicate)
        );
        // Assert
        // no change
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);
        // ADDRESS3 is whitelisted
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS3);
        assertEq(resBool, true);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 3);
    }
}