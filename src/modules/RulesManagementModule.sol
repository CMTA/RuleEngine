// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {EnumerableSet} from "OZ/utils/structs/EnumerableSet.sol";
import {AccessControl} from "OZ/access/AccessControl.sol";
/* ==== Interface and other library === */
import {IRulesManagementModule} from "../interfaces/IRulesManagementModule.sol";
import {IRule} from "../interfaces/IRule.sol";
import {RulesManagementModuleInvariantStorage} from "./library/RulesManagementModuleInvariantStorage.sol";

/**
 * @title RuleEngine -  part
 */
abstract contract RulesManagementModule is
    AccessControl,
    RulesManagementModuleInvariantStorage,
    IRulesManagementModule
{
    /* ==== Type declaration === */
    using EnumerableSet for EnumerableSet.AddressSet;

    /* ==== State Variables === */
    /// @dev Array of rules
    EnumerableSet.AddressSet internal _rules;

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State functions ============ */

    /**
     * @inheritdoc IRulesManagementModule
     */
    function setRules(
        IRule[] calldata rules_
    )
        public
        virtual
        override(IRulesManagementModule)
        onlyRole(RULES_MANAGEMENT_ROLE)
    {
        if (rules_.length == 0) {
            revert RuleEngine_RulesManagementModule_ArrayIsEmpty();
        }
        if (_rules.length() > 0) {
            _clearRules();
        }
        for (uint256 i = 0; i < rules_.length; ++i) {
            _checkRule(address(rules_[i]));
            // Should never revert because we check the presence of the rule before
            require(
                _rules.add(address(rules_[i])),
                RuleEngine_RulesManagementModule_OperationNotSuccessful()
            );
            emit AddRule(rules_[i]);
        }
    }

    /**
     * @inheritdoc IRulesManagementModule
     */
    function clearRules()
        public
        virtual
        override(IRulesManagementModule)
        onlyRole(RULES_MANAGEMENT_ROLE)
    {
        _clearRules();
    }

    /**
     * @inheritdoc IRulesManagementModule
     */
    function addRule(
        IRule rule_
    )
        public
        virtual
        override(IRulesManagementModule)
        onlyRole(RULES_MANAGEMENT_ROLE)
    {
        _checkRule(address(rule_));
        require(
            _rules.add(address(rule_)),
            RuleEngine_RulesManagementModule_OperationNotSuccessful()
        );
        emit AddRule(rule_);
    }

    /**
     * @inheritdoc IRulesManagementModule
     */
    function removeRule(
        IRule rule_
    )
        public
        virtual
        override(IRulesManagementModule)
        onlyRole(RULES_MANAGEMENT_ROLE)
    {
        require(
            _rules.contains(address(rule_)),
            RuleEngine_RulesManagementModule_RuleDoNotMatch()
        );
        _removeRule(rule_);
    }

    /* ============ View functions ============ */

    /**
     * @inheritdoc IRulesManagementModule
     */
    function rulesCount()
        public
        view
        virtual
        override(IRulesManagementModule)
        returns (uint256)
    {
        return _rules.length();
    }

    /**
     * @inheritdoc IRulesManagementModule
     */
    function containsRule(
        IRule rule_
    ) public view virtual override(IRulesManagementModule) returns (bool) {
        return _rules.contains(address(rule_));
    }

    /**
     * @inheritdoc IRulesManagementModule
     */
    function rule(
        uint256 ruleId
    ) public view virtual override(IRulesManagementModule) returns (address) {
        if (ruleId < _rules.length()) {
            // Note that there are no guarantees on the ordering of values inside the array,
            // and it may change when more values are added or removed.
            return _rules.at(ruleId);
        } else {
            return address(0);
        }
    }

    /**
     * @inheritdoc IRulesManagementModule
     */
    function rules()
        public
        view
        virtual
        override(IRulesManagementModule)
        returns (address[] memory)
    {
        return _rules.values();
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Clear all the rules of the array of rules
     *
     */
    function _clearRules() internal virtual {
        emit ClearRules();
        _rules.clear();
    }

    /**
     * @notice Remove a rule from the array of rules
     * Revert if the rule found at the specified index does not match the rule in argument
     * @param rule_ address of the target rule
     *
     *
     */
    function _removeRule(IRule rule_) internal virtual {
        // Should never revert because we check the presence of the rule before
        require(
            _rules.remove(address(rule_)),
            RuleEngine_RulesManagementModule_OperationNotSuccessful()
        );
        emit RemoveRule(rule_);
    }

    /**
     * @dev check if a rule is valid, revert otherwise
     */
    function _checkRule(address rule_) internal view {
        if (rule_ == address(0x0)) {
            revert RuleEngine_RulesManagementModule_RuleAddressZeroNotAllowed();
        }
        if (_rules.contains(rule_)) {
            revert RuleEngine_RulesManagementModule_RuleAlreadyExists();
        }
    }

    /* ============ Transferred functions ============ */

    /**
     * @notice Go through all the rule to know if a restriction exists on the transfer
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     **/
    function _transferred(
        address from,
        address to,
        uint256 value
    ) internal virtual {
        uint256 rulesLength = _rules.length();
        for (uint256 i = 0; i < rulesLength; ++i) {
            IRule(_rules.at(i)).transferred(from, to, value);
        }
    }

    /**
     * @notice Go through all the rule to know if a restriction exists on the transfer
     * @param spender the spender address (transferFrom)
     * @param from the origin address
     * @param to the destination address
     * @param value to transfer
     **/
    function _transferred(
        address spender,
        address from,
        address to,
        uint256 value
    ) internal virtual {
        uint256 rulesLength = _rules.length();
        for (uint256 i = 0; i < rulesLength; ++i) {
            IRule(_rules.at(i)).transferred(spender, from, to, value);
        }
    }
}
