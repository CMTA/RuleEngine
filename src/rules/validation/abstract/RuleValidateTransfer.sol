// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../interfaces/IRuleValidation.sol";

abstract contract RuleValidateTransfer is IRuleValidation{
    /** 
    * @notice Validate a transfer
    * @param _from the origin address
    * @param _to the destination address
    * @param _amount to transfer
    * @return isValid => true if the transfer is valid, false otherwise
    **/
    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool isValid) {
        // does not work without this keyword "Undeclared identifier"
        return
            this.detectTransferRestriction(_from, _to, _amount) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }
}
