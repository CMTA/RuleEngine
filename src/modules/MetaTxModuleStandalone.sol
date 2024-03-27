//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/metatx/ERC2771Context.sol";

/**
 * @dev Meta transaction (gasless) module.
 */
abstract contract MetaTxModuleStandalone is ERC2771Context {
    constructor(address trustedForwarder) ERC2771Context(trustedForwarder) {
        // Nothing to do
    }
}
