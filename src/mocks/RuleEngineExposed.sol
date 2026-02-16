// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngine} from "../RuleEngine.sol";
import {RuleEngineOwnable} from "../RuleEngineOwnable.sol";

/**
 * @title RuleEngineExposed
 * @dev Exposes internal functions for testing coverage
 */
contract RuleEngineExposed is RuleEngine {
    constructor(address admin, address forwarder, address token) RuleEngine(admin, forwarder, token) {}

    function exposedMsgData() external view returns (bytes memory) {
        return _msgData();
    }
}

/**
 * @title RuleEngineOwnableExposed
 * @dev Exposes internal functions for testing coverage
 */
contract RuleEngineOwnableExposed is RuleEngineOwnable {
    constructor(address owner_, address forwarder, address token) RuleEngineOwnable(owner_, forwarder, token) {}

    function exposedMsgData() external view returns (bytes memory) {
        return _msgData();
    }
}
