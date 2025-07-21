//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

interface IRuleOperation {
    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     */
    function transferred(
        address from,
        address to,
        uint256 value
    ) external;
}
