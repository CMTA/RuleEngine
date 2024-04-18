// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/CMTAT_STANDALONE.sol";
import "../HelperContract.sol";
import "src/RuleEngine.sol";

/**
* @title Integration test with the CMTAT
*/
contract CMTATIntegration is Test, HelperContract {
    // Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";

    RuleEngine ruleEngineMock;
    uint256 resUint256;
    bool resBool;

    uint256 ADDRESS1_BALANCE_INIT = 31;
    uint256 ADDRESS2_BALANCE_INIT = 32;
    uint256 ADDRESS3_BALANCE_INIT = 33;

    uint256 FLAG = 5;

    // Arrange
    function setUp() public {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleBlacklist = new RuleBlacklist(DEFAULT_ADMIN_ADDRESS, ZERO_ADDRESS);
        // global arrange
        uint8 decimals = 0;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT = new CMTAT_STANDALONE(
            ZERO_ADDRESS,
            DEFAULT_ADMIN_ADDRESS,
            IAuthorizationEngine(address(0)),
            "CMTA Token",
            "CMTAT",
            decimals,
            "CMTAT_ISIN",
            "https://cmta.ch",
            IRuleEngine(address(0)),
            "CMTAT_info",
            FLAG
        );

        // specific arrange
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleEngineMock = new RuleEngine(DEFAULT_ADMIN_ADDRESS, ZERO_ADDRESS, address(CMTAT_CONTRACT));
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleEngineMock.addRuleValidation(ruleBlacklist);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS1, ADDRESS1_BALANCE_INIT);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS2, ADDRESS2_BALANCE_INIT);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS3, ADDRESS3_BALANCE_INIT);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        // We set the Rule Engine
        CMTAT_CONTRACT.setRuleEngine(ruleEngineMock);
    }

    /******* Transfer *******/
    function testCanTransferIfAddressNotBlacklisted() public {
        // Arrange
        /*vm.prank(ADDRESS1);
        vm.expectRevert(
        abi.encodeWithSelector(Errors.CMTAT_InvalidTransfer.selector, ADDRESS1, ADDRESS2, 21));   */
        // Act
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    function testCannotTransferIfAddressToIsBlacklisted() public {
        // Arrange
        uint256 amount = 21;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleBlacklist.addAddressToTheList(ADDRESS2);

        vm.prank(ADDRESS1);
        vm.expectRevert(
        abi.encodeWithSelector(Errors.CMTAT_InvalidTransfer.selector, ADDRESS1, ADDRESS2, amount));   
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, amount);
    }

    function testCannotTransferIfAddressFronIsBlacklisted() public {
        // Arrange
        uint256 amount = 21;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleBlacklist.addAddressToTheList(ADDRESS1);

        vm.prank(ADDRESS1);
        vm.expectRevert(
        abi.encodeWithSelector(Errors.CMTAT_InvalidTransfer.selector, ADDRESS1, ADDRESS2, amount));   
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, amount);
    }

    function testCannotTransferIfBothAddressesAreBlacklisted() public {
        uint256 amount = 21;
        // Arrange
        address[] memory blacklist = new address[](2);
        blacklist[0] = ADDRESS1;
        blacklist[1] = ADDRESS2;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        (bool success, ) = address(ruleBlacklist).call(
            abi.encodeWithSignature(
                "addAddressesToTheList(address[])",
                blacklist
            )
        );
        require(success);
     

        // Act
        vm.prank(ADDRESS1);
        vm.expectRevert(
        abi.encodeWithSelector(Errors.CMTAT_InvalidTransfer.selector, ADDRESS1, ADDRESS2, amount));   
        CMTAT_CONTRACT.transfer(ADDRESS2, amount);
    }

    /******* detectTransferRestriction & messageForTransferRestriction *******/
    function testDetectAndMessageWithToBlacklisted() public {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleBlacklist.addAddressToTheList(ADDRESS2);
        resBool = ruleBlacklist.addressIsListed(ADDRESS2);
        // Assert
        assertEq(resBool, true);
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );
        // Assert
        assertEq(res1, CODE_ADDRESS_TO_IS_BLACKLISTED);
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            res1
        );
        // Assert
        assertEq(message1, TEXT_ADDRESS_TO_IS_BLACKLISTED);
    }

    function testDetectAndMessageWithFromBlacklisted() public {
        // Arrange
        // We add the sender to the whitelist
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleBlacklist.addAddressToTheList(ADDRESS1);
        // Arrange - Assert
        resBool = ruleBlacklist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        // Act
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );
        // Assert
        assertEq(res1, CODE_ADDRESS_FROM_IS_BLACKLISTED);
        // Act
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            res1
        );
        // Assert
        assertEq(message1, TEXT_ADDRESS_FROM_IS_BLACKLISTED);
    }

    function testDetectAndMessageWithFromAndToNotBlacklisted() public view {
        // Act
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );

        // Assert
        assertEq(res1, TRANSFER_OK);
        // Act
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            res1
        );
        // Assert
        assertEq(message1, TEXT_TRANSFER_OK);
    }

    function testDetectAndMessageWithFromAndToBlacklisted() public {
        // Arrange
        // We add the sender and the recipient to the whitelist.
        address[] memory blacklist = new address[](2);
        blacklist[0] = ADDRESS1;
        blacklist[1] = ADDRESS2;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        (bool success, ) = address(ruleBlacklist).call(
            abi.encodeWithSignature(
                "addAddressesToTheList(address[])",
                blacklist
            )
        );
        require(success);
        // Act
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );
        // Assert
        assertEq(res1, CODE_ADDRESS_FROM_IS_BLACKLISTED);
        // Act
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            res1
        );
        // Assert
        assertEq(message1, TEXT_ADDRESS_FROM_IS_BLACKLISTED);
    }

    function testCanMintIfAddressNotInTheBlacklist() public {
        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS1, 11);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT + 11);
    }

    function testCannotMintIfAddressIsInTheBlacklist() public {
        uint256 amount = 11;
        // Arrange
        // Add address zero to the blacklist
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleBlacklist.addAddressToTheList(ZERO_ADDRESS);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleBlacklist.addAddressToTheList(ADDRESS1);
        // Arrange - Assert
        resBool = ruleBlacklist.addressIsListed(ZERO_ADDRESS);
        assertEq(resBool, true);

        // Act
        vm.expectRevert(
        abi.encodeWithSelector(Errors.CMTAT_InvalidTransfer.selector, ZERO_ADDRESS, ADDRESS1, amount));   
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS1, amount);
    }

    function testCanReturnMessageNotFoundWithUnknownCodeId() public view {
        // Act
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            255
        );

        // Assert
        assertEq(message1, TEXT_CODE_NOT_FOUND);
    }
}
