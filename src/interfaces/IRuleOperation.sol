//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

interface IRuleOperation {

    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     */
    function operateOnTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool isValid);
}
