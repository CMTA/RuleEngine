//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";

/* ==== Interfaces === */

interface IRule is IRuleEngine {
    /**
     * @dev Returns true if the restriction code exists, and false otherwise.
     */
    function canReturnTransferRestrictionCode(
        uint8 restrictionCode
    ) external view returns (bool);
}
