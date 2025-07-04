//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404Extend} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";
import {IERC7551Compliance} from "CMTAT/interfaces//tokenization/draft-IERC7551.sol";
interface IRuleValidation is IERC1404Extend, IERC7551Compliance {
    /**
     * @dev Returns true if the restriction code exists, and false otherwise.
     */
    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external view returns (bool);

    function detectTransferRestrictionFrom(
        address spender,
        address _from,
        address _to,
        uint256 _amount
    ) external view override returns (uint8);

}
