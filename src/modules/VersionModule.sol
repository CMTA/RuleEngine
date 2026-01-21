// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {IERC3643Version} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";

abstract contract VersionModule is IERC3643Version {
    /* ============ State Variables ============ */
    /**
     * @dev
     * Get the current version of the smart contract
     */
    string private constant VERSION = "3.0.0";

    /* ============ Events ============ */
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @inheritdoc IERC3643Version
     */
    function version()
        public
        view
        virtual
        override(IERC3643Version)
        returns (string memory version_)
    {
        return VERSION;
    }
}
