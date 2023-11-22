//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../lib/openzeppelin-contracts/contracts/metatx/ERC2771Context.sol";

/**
 * @dev Meta transaction (gasless) module.
 */
abstract contract MetaTxModuleStandalone is ERC2771Context {
    constructor(address trustedForwarder) ERC2771Context(trustedForwarder) {
        // Nothing to do
    }

    function _msgSender()
        internal
        view
        virtual
        override
        returns (address sender)
    {
        return ERC2771Context._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }
}
