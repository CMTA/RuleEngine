// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../HelperContract.sol";
import "OZ/token/ERC20/IERC20.sol";

/**
 * @title tests concerning the restrictions and  for the transfers
 */
contract RuleEngineRestrictionTest is Test, HelperContract {
    RuleWhitelist ruleWhitelist1;

    // Arrange
    function setUp() public {
        ruleWhitelist = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            ZERO_ADDRESS,
            ZERO_ADDRESS
        );
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.addRule(ruleWhitelist);
        // Arrange - Assert
        resUint256 = ruleEngineMock.rulesCount();
        assertEq(resUint256, 1);

        // Arrange
        ruleWhitelist1 = new RuleWhitelist(
            WHITELIST_OPERATOR_ADDRESS,
            ZERO_ADDRESS
        );
        IRule[] memory ruleWhitelistTab = new IRule[](1);
        ruleWhitelistTab[0] = ruleWhitelist1;
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        (bool success, ) = address(ruleEngineMock).call(
            abi.encodeCall(ruleEngineMock.setRules, ruleWhitelistTab)
        );

        // Arrange - Assert
        assertEq(success, true);
    }

    function testCanDetectTransferRestrictionOK() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist1.addAddressToTheList(ADDRESS1);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist1.addAddressToTheList(ADDRESS2);

        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, 0);

        // ruleEngine

        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, 0);
    }

    function testCanDetectTransferRestrictionWithSpender() public {
        // Act
        resUint8 = ruleEngineMock.detectTransferRestrictionFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_ADDRESS_SPENDER_NOT_WHITELISTED);

        // ruleEngine

        // Act
        resBool = ruleEngineMock.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );
        // Assert
        assertFalse(resBool);
    }

    function testCanDetectTransferRestrictionWithFrom() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist1.addAddressToTheList(ADDRESS3);
        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_ADDRESS_FROM_NOT_WHITELISTED);

        // Act
        resUint8 = ruleEngineMock.detectTransferRestrictionFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_ADDRESS_FROM_NOT_WHITELISTED);

        // ruleEngine

        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_ADDRESS_FROM_NOT_WHITELISTED);

        // Act
        resBool = ruleEngineMock.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );
        // Assert
        assertFalse(resBool);

        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);
        // Assert
        assertFalse(resBool);
    }

    function testCanDetectTransferRestrictionWithTo() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist1.addAddressToTheList(ADDRESS1);

        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_ADDRESS_TO_NOT_WHITELISTED);

        // ruleEngine

        // Act
        resUint8 = ruleEngineMock.detectTransferRestriction(
            ADDRESS1,
            ADDRESS2,
            20
        );

        // Assert
        assertEq(resUint8, CODE_ADDRESS_TO_NOT_WHITELISTED);

        // Assert
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);
        // Assert
        assertFalse(resBool);

        resBool = ruleEngineMock.canTransferFrom(
            ADDRESS3,
            ADDRESS1,
            ADDRESS2,
            20
        );
        // Assert
        assertFalse(resBool);
    }

    function testMessageForTransferRestrictionWithValidRC() public {
        // Act
        resString = ruleEngineMock.messageForTransferRestriction(
            CODE_ADDRESS_FROM_NOT_WHITELISTED
        );

        // Assert
        assertEq(resString, TEXT_ADDRESS_FROM_NOT_WHITELISTED);
    }

    function testMessageForTransferRestrictionNoRule() public {
        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        ruleEngineMock.clearRules();

        // Act
        resString = ruleEngineMock.messageForTransferRestriction(50);

        // Assert
        assertEq(resString, "Unknown restriction code");
    }

    function testMessageForTransferRestrictionWithUnknownRestrictionCode()
        public
    {
        // Act
        resString = ruleEngineMock.messageForTransferRestriction(50);

        // Assert
        assertEq(resString, "Unknown restriction code");
    }

    function testcanTransferOK() public {
        // Arrange
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist1.addAddressToTheList(ADDRESS1);
        vm.prank(WHITELIST_OPERATOR_ADDRESS);
        ruleWhitelist1.addAddressToTheList(ADDRESS2);

        // Act
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertEq(resBool, true);

        // ruleEngine

        // Act
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertEq(resBool, true);
    }

    function testcanTransferRestricted() public {
        // Act
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertFalse(resBool);

        // ruleEngine

        // Act
        resBool = ruleEngineMock.canTransfer(ADDRESS1, ADDRESS2, 20);

        // Assert
        assertFalse(resBool);
    }
}
