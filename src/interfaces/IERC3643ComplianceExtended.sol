//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC3643Compliance} from "./IERC3643Compliance.sol";
import {ITokenBindingExtended} from "./ITokenBindingExtended.sol";

/**
 * @title IERC3643ComplianceExtended
 * @notice Extends the ERC-3643 compliance interface with the batch binding and token
 * self-binding management provided by {ITokenBindingExtended}.
 * @dev None of the extended functions is part of the original ERC-3643 compliance interface;
 * they belong to the token binding registry and are therefore declared in the standard-agnostic
 * {ITokenBindingExtended}. This interface only ties them to the ERC-3643 compliance contract,
 * where they must be restricted by implementation-specific compliance manager access control.
 */
interface IERC3643ComplianceExtended is IERC3643Compliance, ITokenBindingExtended {}
