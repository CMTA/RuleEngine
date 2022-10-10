//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";
import "CMTAT/modules/PauseModule.sol";
import "./HelperContract.sol";
import "src/RuleEngine.sol";

contract RuleEngineTest is Test, HelperContract, ValidationModule, RuleWhitelist {
    RuleWhitelist ruleWhitelist = new RuleWhitelist();
    
    RuleEngineMock fakeRuleEngine = new RuleEngineMock(ruleWhitelist);
    uint256 resUint256;

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

    // can be changed by the owner
    function testCanBeChangedByOwner() public {
        vm.prank(OWNER);
        vm.expectEmit(true, false, false, false);
        emit RuleEngineSet(address(fakeRuleEngine));
        CMTAT_CONTRACT.setRuleEngine(fakeRuleEngine);
    }

    // reverts when calling from non-owner
    function testCannotCallByNonOwner() public {
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
        CMTAT_CONTRACT.setRuleEngine(fakeRuleEngine);
    }
}

// Transferring with Rule Engine set
contract RuleEngineSetTest is Test, HelperContract, ValidationModule, RuleWhitelist {
    //Defined in CMTAT.sol
    uint8 constant TRANSFER_OK = 0;
    string constant TEXT_TRANSFER_OK = "No restriction";
    
    RuleEngineMock ruleEngineMock;
    uint256 resUint256;

    RuleWhitelist ruleWhitelist = new RuleWhitelist();

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

        // Config perso
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

    function testCannotTranferIfToIsNotWhitelisted() public {
        // We add the sender to the whitelist
        ruleWhitelist.addAddressToTheWhitelist (ADDRESS1);

        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );
        assertEq(res1, CODE_ADDRESS_TO_NOT_WHITELISTED);
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
           CODE_ADDRESS_TO_NOT_WHITELISTED
        );
        assertEq(message1, TEXT_ADDRESS_TO_NOT_WHITELISTED);
    }

    function testCannotTranferIfFromIsNotWhitelisted() public {
        // We add the recipient to the whitelist
        ruleWhitelist.addAddressToTheWhitelist(ADDRESS2);

        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );
        assertEq(res1, CODE_ADDRESS_FROM_NOT_WHITELISTED);
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
           res1
        );
         assertEq(message1, TEXT_ADDRESS_FROM_NOT_WHITELISTED);
    }

     function testCannotTranferIf_From_To_NOT_Whitelisted() public {
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );
        assertEq(res1, CODE_ADDRESS_FROM_NOT_WHITELISTED);
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
           CODE_ADDRESS_FROM_NOT_WHITELISTED
        );
         assertEq(message1, TEXT_ADDRESS_FROM_NOT_WHITELISTED);
    }

    // can check if transfer is valid
    function testCanCheckTransferIsValid() public {
        // We add the sender and the recipient to the whitelist.
        ruleWhitelist.addAddressToTheWhitelist (ADDRESS1);
        ruleWhitelist.addAddressToTheWhitelist (ADDRESS2);
        uint8 res1 = CMTAT_CONTRACT.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            11
        );
        assertEq(res1, TRANSFER_OK);
        string memory message1 = CMTAT_CONTRACT.messageForTransferRestriction(
            res1
        );
        assertEq(message1, TEXT_TRANSFER_OK);
    }

    // allows ADDRESS1 to transfer tokens to ADDRESS2
    function testAllowTransfer() public {
        ruleWhitelist.addAddressToTheWhitelist (ADDRESS1);
        ruleWhitelist.addAddressToTheWhitelist (ADDRESS2);
        ruleWhitelist.addAddressToTheWhitelist (ADDRESS3);
        vm.prank(ADDRESS1);
        CMTAT_CONTRACT.transfer(ADDRESS2, 11);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS1);
        assertEq(resUint256, 20);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS2);
        assertEq(resUint256, 43);
        resUint256 = CMTAT_CONTRACT.balanceOf(ADDRESS3);
        assertEq(resUint256, 33);
    }

    // reverts if ADDRESS1 transfers more tokens than rule allows
    function testCannotTransferRuleAllows() public {
        vm.prank(ADDRESS1);
        vm.expectRevert(bytes("CMTAT: transfer rejected by validation module"));
        CMTAT_CONTRACT.transfer(ADDRESS2, 21);
    }
}