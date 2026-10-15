// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title LegacyIRuleIdProbe
 * @notice Test-only contract that advertises the pre-narrowing `IRule` ID `0x2497d6cb` (with `canTransfer` and
 * `canTransferFrom`) and not the current one, like a rule built against v3.0.0-rc6 or earlier. The engine
 * accepts only the current ID, so adding it must revert (rc7 code-quality review `I-1`).
 */
contract LegacyIRuleIdProbe is ERC165 {
    bytes4 public constant LEGACY_IRULE_INTERFACE_ID = 0x2497d6cb;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == LEGACY_IRULE_INTERFACE_ID || ERC165.supportsInterface(interfaceId);
    }
}
