//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";

/**
 * @dev Meta transaction (gasless) module.
 */
abstract contract ERC2771ModuleStandalone is ERC2771Context {
    /**
     * @notice Sets the trusted ERC-2771 forwarder.
     * @dev The forwarder is immutable: it cannot be changed after construction.
     * @param trustedForwarder Address of the trusted forwarder.
     */
    constructor(address trustedForwarder) ERC2771Context(trustedForwarder) {
        // Nothing to do
    }
}
