// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "CMTAT/deployment/CMTATStandalone.sol";
import "../HelperContract.sol";

/**
 * @title Integration test with the CMTAT
 */
contract CMTATIntegration is Test, HelperContract {
    uint256 ADDRESS1_BALANCE_INIT = 31;
    uint256 ADDRESS2_BALANCE_INIT = 32;
    uint256 ADDRESS3_BALANCE_INIT = 33;

    uint256 FLAG = 5;

    // Arrange
    function setUp() public {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist = new RuleWhitelist(DEFAULT_ADMIN_ADDRESS, ZERO_ADDRESS);
        // global arrange
        cmtatDeployment = new CMTATDeployment();
        CMTAT_CONTRACT = cmtatDeployment.cmtat();

        // specific arrange
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleEngineMock = new RuleEngine(
            DEFAULT_ADMIN_ADDRESS,
            ZERO_ADDRESS,
            address(CMTAT_CONTRACT)
        );
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist);

        // Assert
        assertEq(ruleEngineMock.containsRule(ruleWhitelist), true);

        // CMTAT
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS1, ADDRESS1_BALANCE_INIT);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS2, ADDRESS2_BALANCE_INIT);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS3, ADDRESS3_BALANCE_INIT);

        // We set the Rule Engine
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.setRuleEngine(ruleEngineMock);
    }

    /******* Transfer *******/
    function testCannotTransferWithoutAddressWhitelisted() public {
        uint8 code = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            21
        );
        // Arrange
        vm.prank(ADDRESS1);
        vm.expectRevert(
            abi.encodeWithSelector(
                RuleWhitelist.RuleWhitelist_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                21,
                code
            )
        );
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    function testCannotTransferWithoutFromAddressWhitelisted() public {
        // Arrange
        uint256 amount = 21;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS2);

        uint8 code = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            amount
        );
        vm.prank(ADDRESS1);
        vm.expectRevert(
            abi.encodeWithSelector(
                RuleWhitelist.RuleWhitelist_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                amount,
                code
            )
        );
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, amount);
    }

    function testCannotTransferWithoutToAddressWhitelisted() public {
        // Arrange
        uint256 amount = 21;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);

        uint8 code = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            amount
        );
        vm.prank(ADDRESS1);
        vm.expectRevert(
            abi.encodeWithSelector(
                RuleWhitelist.RuleWhitelist_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                amount,
                code
            )
        );
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, amount);
    }

    function testCannotTransferWithoutSpenderAddressWhitelisted() public {
        // Arrange
        uint256 amount = 21;
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.approve(ADDRESS3, amount);

        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS2);

        uint8 code = CMTAT_CONTRACT.detectTransferRestrictionFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            amount
        );
        vm.prank(ADDRESS3);
        vm.expectRevert(
            abi.encodeWithSelector(
                RuleWhitelist.RuleWhitelist_InvalidTransfer.selector,
                ADDRESS1,
                ADDRESS2,
                amount,
                code
            )
        );
        // Act
        CMTAT_CONTRACT.transferFrom(ADDRESS1, ADDRESS2, amount);
    }

    function testCanMakeATransfer() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        (bool success, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheList(address[])",
                whitelist
            )
        );
        require(success);
        vm.prank(ADDRESS1);

        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 11);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, 20);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
        assertEq(resUint256, 43);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
        assertEq(resUint256, 33);
    }

    /******* detectTransferRestriction & messageForTransferRestriction *******/
    function testDetectAndMessageWithFromNotWhitelisted() public {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS2);
        resBool = ruleWhitelist.addressIsListed(ADDRESS2);
        // Assert
        assertEq(resBool, true);
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );
        // Assert
        assertEq(res1, CODE_ADDRESS_FROM_NOT_WHITELISTED);
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            res1
        );
        // Assert
        assertEq(message1, TEXT_ADDRESS_FROM_NOT_WHITELISTED);
    }

    function testDetectAndMessageWithToNotWhitelisted() public {
        // Arrange
        // We add the sender to the whitelist
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsListed(ADDRESS1);
        assertEq(resBool, true);
        // Act
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );
        // Assert
        assertEq(res1, CODE_ADDRESS_TO_NOT_WHITELISTED);
        // Act
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            res1
        );
        // Assert
        assertEq(message1, TEXT_ADDRESS_TO_NOT_WHITELISTED);

        // res1
        res1 = ruleEngineMock.detectTransferRestriction(ADDRESS1, ADDRESS2, 11);
        // Assert
        assertEq(res1, CODE_ADDRESS_TO_NOT_WHITELISTED);

        message1 = ruleEngineMock.messageForTransferRestriction(res1);

        // Assert
        assertEq(message1, TEXT_ADDRESS_TO_NOT_WHITELISTED);
    }

    function testDetectAndMessageWithFromAndToNotWhitelisted() public view {
        // Act
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );

        // Assert
        assertEq(res1, CODE_ADDRESS_FROM_NOT_WHITELISTED);
        // Act
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            res1
        );

        // Assert
        assertEq(message1, TEXT_ADDRESS_FROM_NOT_WHITELISTED);

        // RuleEngine
        res1 = ruleEngineMock.detectTransferRestriction(ADDRESS1, ADDRESS2, 11);
        // Assert
        assertEq(res1, CODE_ADDRESS_FROM_NOT_WHITELISTED);

        message1 = ruleEngineMock.messageForTransferRestriction(res1);

        // Assert
        assertEq(message1, TEXT_ADDRESS_FROM_NOT_WHITELISTED);
    }

    function testDetectAndMessageWithAValidTransfer() public {
        // Arrange
        // We add the sender and the recipient to the whitelist.
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        (bool success, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheList(address[])",
                whitelist
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
        assertEq(res1, TRANSFER_OK);
        // Act
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            res1
        );
        // Assert
        assertEq(message1, TEXT_TRANSFER_OK);
    }

    function testDetectAndMessageWithInvalidTransferFrom() public {
        // Arrange
        // We add the sender and the recipient to the whitelist.
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        (bool success, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheList(address[])",
                whitelist
            )
        );
        require(success);
        // Act
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestrictionFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            11
        );
        // Assert
        assertEq(res1, CODE_ADDRESS_SPENDER_NOT_WHITELISTED);

        res1 = ruleEngineMock.detectTransferRestrictionFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            11
        );
        // Assert
        assertEq(res1, CODE_ADDRESS_SPENDER_NOT_WHITELISTED);

        resBool = CMTAT_CONTRACT.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            11
        );
        // Assert
        assertFalse(resBool);

        resBool = ruleEngineMock.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            11
        );
        // Assert
        assertFalse(resBool);

        resBool = ruleEngineMock.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            11
        );
        // Assert
        assertFalse(resBool);
        // Act
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            res1
        );
        // Assert
        assertEq(message1, TEXT_ADDRESS_SPENDER_NOT_WHITELISTED);
    }

    function testCanMint() public {
        // Arrange
        // Add address zero to the whitelist
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ZERO_ADDRESS);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheList(ADDRESS1);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsListed(ZERO_ADDRESS);
        assertEq(resBool, true);

        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS1, 11);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT + 11);
    }
}
