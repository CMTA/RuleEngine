// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
/* ==== Modules === */
import {ERC2771ModuleStandalone, ERC2771Context} from "../modules/ERC2771ModuleStandalone.sol";
/* ==== Base contract === */
import {RuleEngineAccessControlShared} from "../RuleEngineAccessControlShared.sol";

/**
 * @title Implementation of a ruleEngine as defined by the CMTAT, with RBAC access control and ERC-2771
 * @dev Administrative calls may be relayed by the immutable trusted forwarder (gasless transactions).
 * Token identity is never resolved through the forwarder: the bound-token gate and token self-binding
 * compare the raw `msg.sender`.
 */
contract RuleEngine2771 is ERC2771ModuleStandalone, RuleEngineAccessControlShared {
    /**
     * @notice Deploys the RBAC RuleEngine with a trusted forwarder.
     * @param admin Address receiving `DEFAULT_ADMIN_ROLE`; must not be the zero address.
     * @param forwarderIrrevocable Address of the trusted ERC-2771 forwarder, immutable after construction.
     * @param tokenContract Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address admin, address forwarderIrrevocable, address tokenContract)
        ERC2771ModuleStandalone(forwarderIrrevocable)
        RuleEngineAccessControlShared(admin, tokenContract)
    {}

    /*//////////////////////////////////////////////////////////////
                           ERC-2771
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Resolves the sender through ERC-2771 when the call comes from the trusted forwarder.
     * @return sender The transaction sender, unwrapped from the forwarder calldata when relayed.
     */
    function _msgSender() internal view virtual override(ERC2771Context, Context) returns (address sender) {
        return ERC2771Context._msgSender();
    }

    /**
     * @dev Resolves the calldata through ERC-2771 when the call comes from the trusted forwarder.
     * @return The transaction calldata, with the appended sender stripped when relayed.
     */
    function _msgData() internal view virtual override(ERC2771Context, Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    /**
     * @dev Length of the sender suffix appended by the trusted forwarder.
     * @return The length of the ERC-2771 calldata suffix.
     */
    function _contextSuffixLength() internal view virtual override(ERC2771Context, Context) returns (uint256) {
        return ERC2771Context._contextSuffixLength();
    }
}
