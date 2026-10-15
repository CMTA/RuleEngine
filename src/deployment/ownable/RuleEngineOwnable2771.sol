// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.27;

/* ==== OpenZeppelin === */
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
/* ==== Modules === */
import {ERC2771ModuleStandalone, ERC2771Context} from "../../modules/ERC2771ModuleStandalone.sol";
/* ==== Base contract === */
import {RuleEngineOwnable} from "./RuleEngineOwnable.sol";

/**
 * @title Implementation of a ruleEngine with ERC-173 Ownable access control and ERC-2771
 * @dev {RuleEngineOwnable} plus an immutable trusted forwarder: administrative calls (owner-only functions) may be
 * relayed by the forwarder (gasless transactions). Token identity is never resolved through the
 * forwarder: the bound-token gate and token self-binding compare the raw `msg.sender`.
 */
contract RuleEngineOwnable2771 is ERC2771ModuleStandalone, RuleEngineOwnable {
    /**
     * @notice Deploys a RuleEngine with ERC-173 Ownable access control and a trusted forwarder.
     * @param owner_ Address of the initial contract owner (ERC-173).
     * @param forwarderIrrevocable Address of the trusted ERC-2771 forwarder, immutable after construction.
     * @param tokenContract Token to bind at deployment, or the zero address to bind none.
     */
    constructor(address owner_, address forwarderIrrevocable, address tokenContract)
        ERC2771ModuleStandalone(forwarderIrrevocable)
        RuleEngineOwnable(owner_, tokenContract)
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
