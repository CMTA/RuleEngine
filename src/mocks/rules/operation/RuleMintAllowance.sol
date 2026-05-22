// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IRule} from "../../../interfaces/IRule.sol";
import {RuleInterfaceId} from "../../../modules/library/RuleInterfaceId.sol";
import {RuleMintAllowanceInvariantStorage} from "./abstract/RuleMintAllowanceInvariantStorage.sol";

/**
 * @title RuleMintAllowance
 * @notice Rule that enforces per-minter mint allowances set by the contract admin.
 *         The admin grants each minter address a maximum amount they may mint in total.
 *         Each mint deducts from the minter's remaining allowance.
 *         Burns and regular transfers are unrestricted by this rule.
 */
contract RuleMintAllowance is AccessControl, RuleMintAllowanceInvariantStorage, IRule {
    bytes4 private constant RULE_ENGINE_INTERFACE_ID = 0x20c49ce7;
    bytes4 private constant ERC1404EXTEND_INTERFACE_ID = 0x78a8de7d;

    mapping(address minter => uint256 allowance) public mintAllowance;

    /**
     * @param admin Address granted DEFAULT_ADMIN_ROLE
     */
    constructor(address admin) {
        require(admin != address(0), "RuleMintAllowance: zero admin");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /* ============ ERC-165 ============ */

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, IERC165) returns (bool) {
        return interfaceId == RULE_ENGINE_INTERFACE_ID || interfaceId == ERC1404EXTEND_INTERFACE_ID
            || interfaceId == RuleInterfaceId.IRULE_INTERFACE_ID || AccessControl.supportsInterface(interfaceId);
    }

    /* ============ Admin ============ */

    /**
     * @notice Set the mint allowance for a minter.
     * @param minter  Address of the minter.
     * @param amount  Maximum amount the minter is allowed to mint.
     */
    function setMintAllowance(address minter, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintAllowance[minter] = amount;
        emit MintAllowanceSet(minter, amount);
    }

    /* ============ IRule — state-changing ============ */

    /**
     * @notice Called for transfers where no spender context is available.
     *         Mint allowance cannot be enforced without a spender; passes through.
     */
    function transferred(address from, address to, uint256 value) public view {
        // no-op: spender unknown, enforcement requires transferred(spender,...)
    }

    /**
     * @notice Called for every token operation (transfer, mint, burn) with spender context.
     *         Deducts from the minter's allowance for mints; passes through for burns and transfers.
     */
    function transferred(address spender, address from, address /* to */, uint256 value) public {
        if (from == address(0)) {
            uint256 allowance = mintAllowance[spender];
            if (allowance < value) {
                revert RuleMintAllowance_InsufficientAllowance(spender, allowance, value);
            }
            mintAllowance[spender] = allowance - value;
            emit MintAllowanceConsumed(spender, value, mintAllowance[spender]);
        }
    }

    /* ============ IRule — view ============ */

    /**
     * @notice Returns TRANSFER_OK; without spender context mint allowance cannot be evaluated.
     */
    function detectTransferRestriction(address, address, uint256) public pure override returns (uint8) {
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @notice Returns CODE_MINTER_INSUFFICIENT_ALLOWANCE when a minter's allowance would be
     *         exceeded. Burns and regular transfers always return TRANSFER_OK.
     */
    function detectTransferRestrictionFrom(address spender, address from, address, uint256 value)
        public
        view
        override
        returns (uint8)
    {
        if (from == address(0) && mintAllowance[spender] < value) {
            return CODE_MINTER_INSUFFICIENT_ALLOWANCE;
        }
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function canTransfer(address from, address to, uint256 value) public pure override returns (bool) {
        return detectTransferRestriction(from, to, value) == uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function canTransferFrom(address spender, address from, address to, uint256 value)
        public
        view
        override
        returns (bool)
    {
        return detectTransferRestrictionFrom(spender, from, to, value) == uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function canReturnTransferRestrictionCode(uint8 restrictionCode) external pure override returns (bool) {
        return restrictionCode == CODE_MINTER_INSUFFICIENT_ALLOWANCE;
    }

    function messageForTransferRestriction(uint8 restrictionCode) external pure override returns (string memory) {
        if (restrictionCode == CODE_MINTER_INSUFFICIENT_ALLOWANCE) {
            return TEXT_MINTER_INSUFFICIENT_ALLOWANCE;
        }
        return TEXT_CODE_NOT_FOUND;
    }
}
