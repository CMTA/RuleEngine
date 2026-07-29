// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

abstract contract RuleCommonInvariantStorage {
    // Text
    string constant TEXT_CODE_NOT_FOUND = "Unknown restriction code";
    // ERC-1404 reserves the code 0 as the "no restriction" sentinel
    // Same message as the one returned by CMTAT (ValidationModuleERC1404)
    string constant TEXT_TRANSFER_OK = "NoRestriction";
}
