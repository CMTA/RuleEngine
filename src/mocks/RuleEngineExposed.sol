// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.27;

import {RuleEngine2771} from "../deployment/RuleEngine2771.sol";
import {RuleEngineOwnable2771} from "../deployment/RuleEngineOwnable2771.sol";
import {RuleEngineOwnable2Step2771} from "../deployment/RuleEngineOwnable2Step2771.sol";

/**
 * @title RuleEngine2771Exposed
 * @dev Exposes internal functions for testing coverage
 */
contract RuleEngine2771Exposed is RuleEngine2771 {
    /**
     * @notice Deploys the exposed engine.
     * @param admin Address receiving the initial privileges.
     * @param forwarder Address of the trusted ERC-2771 forwarder.
     * @param token Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address admin, address forwarder, address token) RuleEngine2771(admin, forwarder, token) {}

    /**
     * @notice Exposes the internal {_msgData} for testing.
     * @return The transaction calldata as seen by the engine.
     */
    function exposedMsgData() external view returns (bytes memory) {
        return _msgData();
    }
}

/**
 * @title RuleEngineOwnable2771Exposed
 * @dev Exposes internal functions for testing coverage
 */
contract RuleEngineOwnable2771Exposed is RuleEngineOwnable2771 {
    /**
     * @notice Deploys the exposed engine.
     * @param owner_ Address receiving the initial privileges.
     * @param forwarder Address of the trusted ERC-2771 forwarder.
     * @param token Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address owner_, address forwarder, address token) RuleEngineOwnable2771(owner_, forwarder, token) {}

    /**
     * @notice Exposes the internal {_msgData} for testing.
     * @return The transaction calldata as seen by the engine.
     */
    function exposedMsgData() external view returns (bytes memory) {
        return _msgData();
    }
}

/**
 * @title RuleEngineOwnable2Step2771Exposed
 * @dev Exposes internal functions for testing coverage
 */
contract RuleEngineOwnable2Step2771Exposed is RuleEngineOwnable2Step2771 {
    /**
     * @notice Deploys the exposed engine.
     * @param owner_ Address receiving the initial privileges.
     * @param forwarder Address of the trusted ERC-2771 forwarder.
     * @param token Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address owner_, address forwarder, address token)
        RuleEngineOwnable2Step2771(owner_, forwarder, token)
    {}

    /**
     * @notice Exposes the internal {_msgData} for testing.
     * @return The transaction calldata as seen by the engine.
     */
    function exposedMsgData() external view returns (bytes memory) {
        return _msgData();
    }
}
