//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";


contract RuleWhitelistRemoveTest is Test, HelperContract, ValidationModule, RuleWhitelist {
    //Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";
    
    RuleWhitelist ruleWhitelist = new RuleWhitelist();
    uint256 resUint256;
    uint8 resUint8;
    bool resBool;
    bool resCallBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
      // no need setUp
    }

    function testRemoveAddressFromTheWhitelist() public {
        // Arrange
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);
        
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        
        // Act
        ruleWhitelist.removeAddressFromTheWhitelist(ADDRESS1);
        
        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertFalse(resBool);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 0);
    }

        function testRemoveAddressesFromTheWhitelist() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addAddressesToTheWhitelist(address[])", whitelist)
        );
        assertEq(resCallBool, true);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);

        // Act
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("removeAddressesFromTheWhitelist(address[])", whitelist)
        );
        // Assert
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertFalse(resBool);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertFalse(resBool);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 0);
    }

    function testRemoveAddressNotPresentFromTheWhitelist() public {
        // Arrange
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertFalse(resBool);
        vm.expectRevert(bytes("Address is not in the whitelist"));
        
        // Act
        ruleWhitelist.removeAddressFromTheWhitelist(ADDRESS1);
        
        // Assert
        // no change
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertFalse(resBool);
    }

    function testRemoveAddressesNotPresentFromTheWhitelist() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addAddressesToTheWhitelist(address[])", whitelist)
        );
        assertEq(resCallBool, true);
        
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);

        // Arrange
        address[] memory whitelistRemove = new address[](3);
        whitelistRemove[0] = ADDRESS1;
        whitelistRemove[1] = ADDRESS2;
        // Target Address - Not Prsent in the whitelist
        whitelistRemove[2] = ADDRESS3;

        // Act
        (resCallBool, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("removeAddressesFromTheWhitelist(address[])", whitelistRemove)
        );
        // Assert
        assertEq(resCallBool, true);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertFalse(resBool);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertFalse(resBool);
        resUint256 = ruleWhitelist.numberWhitelistedAddress();
        assertEq(resUint256, 0);
    }
}