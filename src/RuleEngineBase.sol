// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {AccessControl} from "OZ/access/AccessControl.sol";
/* ==== CMTAT === */
import {IRuleEngine} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {IERC1404, IERC1404Extend} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "CMTAT/interfaces/tokenization/draft-IERC7551.sol";

/* ==== Modules === */
import {ERC3643ComplianceModule, IERC3643Compliance} from "./modules/ERC3643ComplianceModule.sol";
import {VersionModule} from "./modules/VersionModule.sol";
import {RulesManagementModule} from "./modules/RulesManagementModule.sol";

/* ==== Interface and other library === */
import {IRule} from "./interfaces/IRule.sol";
import {RuleEngineInvariantStorage} from "./modules/library/RuleEngineInvariantStorage.sol";

/**
 * @title Implementation of a ruleEngine as defined by the CMTAT
 */
abstract contract RuleEngineBase is
    VersionModule,
    RulesManagementModule,
    ERC3643ComplianceModule,
    RuleEngineInvariantStorage,
    IRuleEngine
{
    /* ============ State functions ============ */
    /*
     * @inheritdoc IRuleEngine
     */
    function transferred(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual override(IRuleEngine) onlyBoundToken {
        // Apply  on RuleEngine
        RulesManagementModule._transferred(spender, from, to, value);
    }

    /**
     * @inheritdoc IERC3643IComplianceContract
     */
    function transferred(
        address from,
        address to,
        uint256 value
    ) public virtual override(IERC3643IComplianceContract) onlyBoundToken {
        _transferred(from, to, value);
    }

    /// @inheritdoc IERC3643Compliance
    function created(
        address to,
        uint256 value
    ) public virtual override(IERC3643Compliance) onlyBoundToken {
        _transferred(address(0), to, value);
    }

    /// @inheritdoc IERC3643Compliance
    function destroyed(
        address from,
        uint256 value
    ) public virtual override(IERC3643Compliance) onlyBoundToken {
        _transferred(from, address(0), value);
    }

    /* ============ View functions ============ */
    /**
     * @notice Go through all the rule to know if a restriction exists on the transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK (0) if the transfer is valid
     **/
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) public view virtual override returns (uint8) {
        uint256 rulesLength = rulesCount();
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRule(rule(i)).detectTransferRestriction(
                from,
                to,
                value
            );
            if (restriction > 0) {
                return restriction;
            }
        }
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @inheritdoc IERC1404Extend
     */
    function detectTransferRestrictionFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override(IERC1404Extend) returns (uint8) {
        uint256 rulesLength = rulesCount();
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRule(rule(i)).detectTransferRestrictionFrom(
                spender,
                from,
                to,
                value
            );
            if (restriction > 0) {
                return restriction;
            }
        }

        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @inheritdoc IERC1404
     */
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) public view virtual override(IERC1404) returns (string memory) {
        //
        uint256 rulesLength = rulesCount();
        for (uint256 i = 0; i < rulesLength; ++i) {
            if (
                IRule(rule(i)).canReturnTransferRestrictionCode(restrictionCode)
            ) {
                return
                    IRule(rule(i)).messageForTransferRestriction(
                        restrictionCode
                    );
            }
        }
        return "Unknown restriction code";
    }

    /**
     * @inheritdoc IERC3643ComplianceRead
     */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view virtual override(IERC3643ComplianceRead) returns (bool) {
        return
            detectTransferRestriction(from, to, value) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @inheritdoc IERC7551Compliance
     */
    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override(IERC7551Compliance) returns (bool) {
        return
            detectTransferRestrictionFrom(spender, from, to, value) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /* ============ ACCESS CONTROL ============ */
    /**
     * @notice Returns `true` if `account` has been granted `role`.
     * @dev The Default Admin has all roles
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControl) returns (bool) {
        if (AccessControl.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        } else {
            return AccessControl.hasRole(role, account);
        }
    }
}
