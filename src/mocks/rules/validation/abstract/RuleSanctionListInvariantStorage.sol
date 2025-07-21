// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./RuleCommonInvariantStorage.sol";

abstract contract RuleSanctionlistInvariantStorage is
    RuleCommonInvariantStorage
{
    /* ============ Event ============ */
    event SetSanctionListOracle(address newOracle);
    /* ============ Custom errors ============ */
    error RuleSanctionList_AdminWithAddressZeroNotAllowed();
    error RuleSanctionList_AddressAlreadyWhitelisted();

    /* ============ Role ============ */
    bytes32 public constant SANCTIONLIST_ROLE = keccak256("SANCTIONLIST_ROLE");

    /* ============ String message ============ */
    string constant TEXT_ADDRESS_FROM_IS_SANCTIONED =
        "The sender is sanctioned";
    string constant TEXT_ADDRESS_TO_IS_SANCTIONED =
        "The recipient is sanctioned";
    string constant TEXT_ADDRESS_SPENDER_IS_SANCTIONED =
        "The spender is sanctioned";

    /* ============ Code ============ */
    // It is very important that each rule uses an unique code
    uint8 public constant CODE_ADDRESS_FROM_IS_SANCTIONED = 31;
    uint8 public constant CODE_ADDRESS_TO_IS_SANCTIONED = 32;
    uint8 public constant CODE_ADDRESS_SPENDER_IS_SANCTIONED = 33;
}
