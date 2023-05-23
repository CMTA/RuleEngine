// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../HelperContract.sol";
import "CMTAT/mocks/MinimalForwarderMock.sol";
import "src/RuleEngine.sol";
import "src/RuleEngine.sol";
/**
@title General functions of the RuleEngine
*/
contract RuleEngineTest is Test, HelperContract {
    RuleEngine ruleEngineMock;
    uint8 resUint8;
    uint256 resUint256;
    bool resBool;
    string resString;
    uint8 CODE_NONEXISTENT = 255;

    // Arrange
    function setUp() public {
       
    }

    function testRightDeployment() public {
        // Arrange
        vm.prank(RULE_ENGINE_OPERATOR_ADDRESS);
        MinimalForwarderMock forwarder = new MinimalForwarderMock(
        );
        forwarder.initialize();

        // Act
        ruleEngineMock = new RuleEngine(
            RULE_ENGINE_OPERATOR_ADDRESS,
            address(forwarder)
        );

        // assert
        resBool = ruleEngineMock.hasRole(RULE_ENGINE_ROLE, RULE_ENGINE_OPERATOR_ADDRESS);
        assertEq(resBool, true);
        resBool = ruleEngineMock.isTrustedForwarder(address(forwarder));
        assertEq(resBool, true);
    }
}
