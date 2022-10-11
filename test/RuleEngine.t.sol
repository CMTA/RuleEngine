//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "CMTAT/modules/PauseModule.sol";
import "./HelperContract.sol";
import "src/RuleEngine.sol";

contract CMTATRuleEngineTest is Test, HelperContract, ValidationModule, RuleWhitelist {
    RuleWhitelist ruleWhitelist = new RuleWhitelist();
    RuleEngineMock fakeRuleEngine = new RuleEngineMock(ruleWhitelist);
    uint256 resUint256;

    // Arrange
    function setUp() public {
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
    }

    function testCanBeChangedByOwner() public {
        // Arrange
        vm.prank(OWNER);
        vm.expectEmit(true, false, false, false);
        emit RuleEngineSet(address(fakeRuleEngine));
        // Act
        CMTAT_CONTRACT.setRuleEngine(fakeRuleEngine);
    }

    function testCannotCallByNonOwner() public {
        // Arrange
        vm.prank(ADDRESS1);
        string memory message = string(
            abi.encodePacked(
                "AccessControl: account ",
                vm.toString(ADDRESS1),
                " is missing role ",
                DEFAULT_ADMIN_ROLE_HASH
            )
        );
        vm.expectRevert(bytes(message));
        // Act
        CMTAT_CONTRACT.setRuleEngine(fakeRuleEngine);
    }
}


contract RuleEngineCommonTest is Test, HelperContract, ValidationModule, RuleWhitelist {
     // Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";
    
    RuleEngineMock ruleEngineMock;
    RuleWhitelist ruleWhitelist = new RuleWhitelist();
    uint256 resUint256;
    bool resBool;

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
        // We set the Rule Engine
        CMTAT_CONTRACT.setRuleEngine(ruleEngineMock);
    }

     function testAddressIsIndicatedAsWhitelisted() public {
        // Arrange
        ruleWhitelist.addOneAddressToTheWhitelist(ADDRESS1);
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        // Assert
        assertEq(resBool, true);
    }

    function testAddressIsNotIndicatedAsWhitelisted() public {
        // Act
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        // Assert
        assertFalse(resBool);
    }

    // reverts if ADDRESS1 and ADDRESS2 are not whitelisted
    function testCannotTransferWithoutAddressWhitelisted() public {
        // Arrange
        vm.prank(ADDRESS1);
        vm.expectRevert(bytes("CMTAT: transfer rejected by validation module"));
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }

}


contract RuleEngineTestOneAddress is Test, HelperContract, ValidationModule, RuleWhitelist {
    // Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";
    
    RuleEngineMock ruleEngineMock;
    RuleWhitelist ruleWhitelist = new RuleWhitelist();
    uint256 resUint256;
    bool resBool;

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
        // We set the Rule Engine
        CMTAT_CONTRACT.setRuleEngine(ruleEngineMock);
    }

   
    function testCannotTranferIfToIsNotWhitelisted() public {
        // Act
        // We add the sender to the whitelist
        ruleWhitelist.addOneAddressToTheWhitelist(ADDRESS1);
        // Assert
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
           CODE_ADDRESS_TO_NOT_WHITELISTED
        );
        // Assert
        assertEq(message1, TEXT_ADDRESS_TO_NOT_WHITELISTED);
    }

    function testCannotTranferIfFromIsNotWhitelisted() public {
        // We add the recipient to the whitelist
        ruleWhitelist.addOneAddressToTheWhitelist(ADDRESS2);
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

     function testCannotTranferIf_From_To_NOT_Whitelisted() public {
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );

        // Assert
        assertEq(res1, CODE_ADDRESS_FROM_NOT_WHITELISTED);
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
           CODE_ADDRESS_FROM_NOT_WHITELISTED
        );

        // Assert
        assertEq(message1, TEXT_ADDRESS_FROM_NOT_WHITELISTED);
    }

    // can check if transfer is valid
    function testCanCheckTransferIsValid() public {
        // Act
        // We add the sender and the recipient to the whitelist.
        ruleWhitelist.addOneAddressToTheWhitelist(ADDRESS1);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        // Assert
        assertEq(resBool, true);
        // Act
        ruleWhitelist.addOneAddressToTheWhitelist(ADDRESS2);
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        // Assert
        assertEq(resBool, true);
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

    // allows ADDRESS1 to transfer tokens to ADDRESS2
    function testAllowTransfer() public {
        // Act
        ruleWhitelist.addOneAddressToTheWhitelist(ADDRESS1);
        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS1);
        assertEq(resBool, true);
        // Act
        ruleWhitelist.addOneAddressToTheWhitelist(ADDRESS2);
        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS2);
        assertEq(resBool, true);
        // Act
        ruleWhitelist.addOneAddressToTheWhitelist (ADDRESS3);
        // Assert
        resBool = ruleWhitelist.addressIsWhitelisted(ADDRESS3);
        assertEq(resBool, true);
        // Arrange
        vm.prank(ADDRESS1);
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 11);
        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, 20);
        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
        assertEq(resUint256, 43);
        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
        assertEq(resUint256, 33);
    }

   
}

contract RuleEngineArrayAddressTest is Test, HelperContract, ValidationModule, RuleWhitelist {
    //Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";
    
    RuleEngineMock ruleEngineMock;
    RuleWhitelist ruleWhitelist = new RuleWhitelist();
    uint256 resUint256;
    bool resBool;


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

    // can check if transfer is valid
    function testCanCheckTransferIsValid() public {
        // Arrange
        // We add the sender and the recipient to the whitelist.
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        (bool success, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addListAddressToTheWhitelist(address[])", whitelist)
        );
        require(success);
        //uint256[] calldata whitelistCalldata = whitelist;
        //RuleWhitelist.addListAddressToTheWhitelist(whitelistCalldata);
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


    // allows ADDRESS1 to transfer tokens to ADDRESS2
    function testAllowTransfer() public {
        // Arrange
        address[] memory whitelist = new address[](2);
        whitelist[0] = ADDRESS1;
        whitelist[1] = ADDRESS2;
        (bool success, )  = address(ruleWhitelist).call(
            abi.encodeWithSignature("addListAddressToTheWhitelist(address[])", whitelist)
        );
        require(success);
        vm.prank(ADDRESS1);
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 11);
        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, 20);
        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
        assertEq(resUint256, 43);
        // Assert
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
        assertEq(resUint256, 33);
    }

    // reverts if ADDRESS1 transfers more tokens than rule allows
    function testCannotTransferRuleAllows() public {
        // Arrange
        vm.prank(ADDRESS1);
        vm.expectRevert(bytes("CMTAT: transfer rejected by validation module"));
        // Act
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }
}



