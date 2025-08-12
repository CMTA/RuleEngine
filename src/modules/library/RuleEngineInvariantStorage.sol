// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

abstract contract RuleEngineInvariantStorage {
    error RuleEngine_AdminWithAddressZeroNotAllowed();
    error RuleEngine_InvalidTransfer(address from, address to, uint256 value);
}
