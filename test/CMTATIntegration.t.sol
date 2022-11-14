// SPDX-License-Identifier: MPL-2.0
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "CMTAT/modules/PauseModule.sol";
import "./HelperContract.sol";
import "src/RuleEngine.sol";

contract CMTATIntegration is Test, HelperContract, RuleWhitelist {
    // Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";

    RuleEngine ruleEngineMock;
    uint256 resUint256;
    bool resBool;

    uint256 ADDRESS1_BALANCE_INIT = 31;
    uint256 ADDRESS2_BALANCE_INIT = 32;
    uint256 ADDRESS3_BALANCE_INIT = 33;

    // Arrange
    function setUp() public {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist = new RuleWhitelist();
        // global arrange
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT = new CMTAT(ZERO_ADDRESS);
        CMTAT_CONTRACT.initialize(
            DEFAULT_ADMIN_ADDRESS,
            "CMTA Token",
            "CMTAT",
            "CMTAT_ISIN",
            "https://cmta.ch"
        );

        // specific arrange
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleEngineMock = new RuleEngine(ruleWhitelist);
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

    function testCannotTransferWithoutAddressWhitelisted() public {
        // Arrange
        vm.prank(ADDRESS1);
        vm.expectRevert(bytes("CMTAT: transfer rejected by validation module"));
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

    // allows ADDRESS1 to transfer tokens to ADDRESS2
    function testAllowTransfer() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        (bool success, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheWhitelist(address[])",
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

    function testCannotTranferIfFromIsNotWhitelisted() public {
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS2);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
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

    function testCannotTranferIfToIsNotWhitelisted() public {
        // Arrange
        // We add the sender to the whitelist
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
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
    }

    function testCannotTranferIf_From_To_NOT_Whitelisted() public {
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
    }

    function testCanCheckTransferIsValid() public {
        // Arrange
        // We add the sender and the recipient to the whitelist.
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        (bool success, ) = address(ruleWhitelist).call(
            abi.encodeWithSignature(
                "addAddressesToTheWhitelist(address[])",
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

    function testCanMint() public {
        // Arrange
        // Add address zero to the whitelist
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ZERO_ADDRESS);
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS1);
        // Arrange - Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ZERO_ADDRESS);
        assertEq(resBool, true);

        // Act
        vm.prank(DEFAULT_ADMIN_ADDRESS);
        CMTAT_CONTRACT.mint(ADDRESS1, 11);

        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, ADDRESS1_BALANCE_INIT + 11);
    }
}
