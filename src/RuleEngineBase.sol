// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
/* ==== CMTAT interface IDs === */
import {ERC1404ExtendInterfaceId} from "CMTAT/library/ERC1404ExtendInterfaceId.sol";
import {RuleEngineInterfaceId} from "CMTAT/library/RuleEngineInterfaceId.sol";
/* ==== CMTAT === */
import {IRuleEngine, IRuleEngineERC1404} from "CMTAT/interfaces/engine/IRuleEngine.sol";
import {IERC1404, IERC1404Extend} from "CMTAT/interfaces/tokenization/draft-IERC1404.sol";
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "CMTAT/interfaces/tokenization/draft-IERC7551.sol";

/* ==== Modules === */
import {ERC3643ComplianceModule} from "./modules/ERC3643ComplianceModule.sol";
import {VersionModule} from "./modules/VersionModule.sol";
import {RulesManagementModule} from "./modules/RulesManagementModule.sol";

/* ==== Interface and other library === */
import {IERC3643Compliance} from "./interfaces/IERC3643Compliance.sol";
import {IRule} from "./interfaces/IRule.sol";
import {ComplianceInterfaceId} from "./modules/library/ComplianceInterfaceId.sol";
import {ERC1404InterfaceId} from "./modules/library/ERC1404InterfaceId.sol";
import {RuleEngineInvariantStorage} from "./modules/library/RuleEngineInvariantStorage.sol";
import {RuleInterfaceId} from "./modules/library/RuleInterfaceId.sol";

/**
 * @title Implementation of a ruleEngine as defined by the CMTAT
 */
abstract contract RuleEngineBase is
    VersionModule,
    RulesManagementModule,
    ERC3643ComplianceModule,
    RuleEngineInvariantStorage,
    IRuleEngineERC1404
{
    /* ============ State functions ============ */
    /*
     * @inheritdoc IRuleEngine
     */
    function transferred(address spender, address from, address to, uint256 value)
        public
        virtual
        override(IRuleEngine)
        onlyBoundToken
    {
        // Apply  on RuleEngine
        RulesManagementModule._transferred(spender, from, to, value);
    }

    /**
     * @inheritdoc IERC3643IComplianceContract
     */
    function transferred(address from, address to, uint256 value)
        public
        virtual
        override(IERC3643IComplianceContract)
        onlyBoundToken
    {
        _transferred(from, to, value);
    }

    /// @inheritdoc IERC3643Compliance
    function created(address to, uint256 value) public virtual override(IERC3643Compliance) onlyBoundToken {
        _transferred(address(0), to, value);
    }

    /// @inheritdoc IERC3643Compliance
    function destroyed(address from, uint256 value) public virtual override(IERC3643Compliance) onlyBoundToken {
        _transferred(from, address(0), value);
    }

    /* ============ View functions ============ */
    /**
     * @notice Go through all the rule to know if a restriction exists on the transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK (0) if the transfer is valid
     *
     */
    function detectTransferRestriction(address from, address to, uint256 value)
        public
        view
        virtual
        override(IERC1404)
        returns (uint8)
    {
        return _detectTransferRestriction(from, to, value);
    }

    /**
     * @inheritdoc IERC1404Extend
     */
    function detectTransferRestrictionFrom(address spender, address from, address to, uint256 value)
        public
        view
        virtual
        override(IERC1404Extend)
        returns (uint8)
    {
        return _detectTransferRestrictionFrom(spender, from, to, value);
    }

    /**
     * @inheritdoc IERC1404
     */
    function messageForTransferRestriction(uint8 restrictionCode)
        public
        view
        virtual
        override(IERC1404)
        returns (string memory)
    {
        return _messageForTransferRestriction(restrictionCode);
    }

    /**
     * @inheritdoc IERC3643ComplianceRead
     */
    function canTransfer(address from, address to, uint256 value)
        public
        view
        virtual
        override(IERC3643ComplianceRead)
        returns (bool)
    {
        return detectTransferRestriction(from, to, value) == uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @inheritdoc IERC7551Compliance
     */
    function canTransferFrom(address spender, address from, address to, uint256 value)
        public
        view
        virtual
        override(IERC7551Compliance)
        returns (bool)
    {
        return detectTransferRestrictionFrom(spender, from, to, value) == uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _detectTransferRestriction(address from, address to, uint256 value) internal view virtual returns (uint8) {
        uint256 rulesLength = rulesCount();
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRule(rule(i)).detectTransferRestriction(from, to, value);
            if (restriction > 0) {
                return restriction;
            }
        }
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function _detectTransferRestrictionFrom(address spender, address from, address to, uint256 value)
        internal
        view
        virtual
        returns (uint8)
    {
        uint256 rulesLength = rulesCount();
        for (uint256 i = 0; i < rulesLength; ++i) {
            uint8 restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender, from, to, value);
            if (restriction > 0) {
                return restriction;
            }
        }
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /**
     * @dev This function returns the message from the first rule claiming the code.
     * Rule designers should keep restriction codes unique across rules.
     * If a code is shared intentionally, all rules using that code should return
     * the same message to avoid ambiguous operator feedback.
     */
    function _messageForTransferRestriction(uint8 restrictionCode) internal view virtual returns (string memory) {
        uint256 rulesLength = rulesCount();
        for (uint256 i = 0; i < rulesLength; ++i) {
            if (IRule(rule(i)).canReturnTransferRestrictionCode(restrictionCode)) {
                return IRule(rule(i)).messageForTransferRestriction(restrictionCode);
            }
        }
        return "Unknown restriction code";
    }

    /**
     * @dev Override to add ERC-165 interface check for the full IRule hierarchy.
     */
    function _checkRule(address rule_) internal view virtual override {
        RulesManagementModule._checkRule(rule_);
        if (!ERC165Checker.supportsInterface(rule_, RuleInterfaceId.IRULE_INTERFACE_ID)) {
            revert RuleEngine_RuleInvalidInterface();
        }
    }

    /**
     * @dev Shared ERC-165 checks common to all RuleEngine deployment variants.
     * Concrete deployments can extend this with access-control-specific interfaces.
     */
    function _supportsRuleEngineBaseInterface(bytes4 interfaceId) internal pure returns (bool) {
        return interfaceId == RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID
            || interfaceId == ERC1404InterfaceId.IERC1404_INTERFACE_ID
            || interfaceId == ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID
            || interfaceId == ComplianceInterfaceId.ERC3643_COMPLIANCE_INTERFACE_ID
            || interfaceId == ComplianceInterfaceId.ERC3643_COMPLIANCE_EXTENDED_INTERFACE_ID
            || interfaceId == ComplianceInterfaceId.IERC7551_COMPLIANCE_INTERFACE_ID;
    }
}
