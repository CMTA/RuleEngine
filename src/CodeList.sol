// SPDX-License-Identifier: MPL-2.0

pragma solidity 0.8.17;

abstract contract CodeList {
    // Used by RuleWhiteList.sol
    uint8 constant CODE_ADDRESS_FROM_NOT_WHITELISTED = 20;
    uint8 constant CODE_ADDRESS_TO_NOT_WHITELISTED = 30;
    uint8 constant NO_ERROR = 0;
}
