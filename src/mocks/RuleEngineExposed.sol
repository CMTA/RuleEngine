// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {RuleEngine} from "../deployment/RuleEngine.sol";
import {RuleEngineOwnable} from "../deployment/RuleEngineOwnable.sol";
import {RuleEngineOwnable2Step} from "../deployment/RuleEngineOwnable2Step.sol";

/**
 * @title RuleEngineExposed
 * @dev Exposes internal functions for testing coverage
 */
contract RuleEngineExposed is RuleEngine {
    /**
     * @notice Deploys the exposed engine.
     * @param admin Address receiving the initial privileges.
     * @param forwarder Address of the trusted ERC-2771 forwarder.
     * @param token Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address admin, address forwarder, address token) RuleEngine(admin, forwarder, token) {}

    /**
     * @notice Exposes the internal {_msgData} for testing.
     * @return The transaction calldata as seen by the engine.
     */
    function exposedMsgData() external view returns (bytes memory) {
        return _msgData();
    }
}

/**
 * @title RuleEngineOwnableExposed
 * @dev Exposes internal functions for testing coverage
 */
contract RuleEngineOwnableExposed is RuleEngineOwnable {
    /**
     * @notice Deploys the exposed engine.
     * @param owner_ Address receiving the initial privileges.
     * @param forwarder Address of the trusted ERC-2771 forwarder.
     * @param token Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address owner_, address forwarder, address token) RuleEngineOwnable(owner_, forwarder, token) {}

    /**
     * @notice Exposes the internal {_msgData} for testing.
     * @return The transaction calldata as seen by the engine.
     */
    function exposedMsgData() external view returns (bytes memory) {
        return _msgData();
    }
}

/**
 * @title RuleEngineOwnable2StepExposed
 * @dev Exposes internal functions for testing coverage
 */
contract RuleEngineOwnable2StepExposed is RuleEngineOwnable2Step {
    /**
     * @notice Deploys the exposed engine.
     * @param owner_ Address receiving the initial privileges.
     * @param forwarder Address of the trusted ERC-2771 forwarder.
     * @param token Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address owner_, address forwarder, address token) RuleEngineOwnable2Step(owner_, forwarder, token) {}

    /**
     * @notice Exposes the internal {_msgData} for testing.
     * @return The transaction calldata as seen by the engine.
     */
    function exposedMsgData() external view returns (bytes memory) {
        return _msgData();
    }
}
