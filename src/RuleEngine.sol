// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "CMTAT/interfaces/engine/IRuleEngine.sol";
import "./modules/MetaTxModuleStandalone.sol";
import "./modules/RuleEngineOperation.sol";
import "./modules/RuleEngineValidation.sol";


/**
* @title Implementation of a ruleEngine as defined by the CMTAT
*/
contract RuleEngine is IRuleEngine, RuleEngineOperation, RuleEngineValidation, MetaTxModuleStandalone {
    error RuleEngine_TransferInvalid();
    /**
    * @param admin Address of the contract (Access Control)
    * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
    */
    constructor(
        address admin,
        address forwarderIrrevocable
    ) MetaTxModuleStandalone(forwarderIrrevocable) {
        if(admin == address(0))
        {
            revert RuleEngine_AdminWithAddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RULE_ENGINE_ROLE, admin);
    }

    /*
    * @todo: add access control
    */
    function operateOnTransfer(address from, address to, uint256 amount) external override returns (bool isValid)  {
        // Validate the transfer
        if(!RuleEngineValidation.validateTransfer(from, to, amount)){
            return false; 
        }
        // Apply operation on RuleEngine
        return RuleEngineOperation._operateOnTransfer(from, to, amount);
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgSender()
        internal
        view
        override(ERC2771Context, Context)
        returns (address sender)
    {
        return ERC2771Context._msgSender();
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgData()
        internal
        view
        override(ERC2771Context, Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _contextSuffixLength() internal view override(ERC2771Context, Context) returns (uint256) {
        return ERC2771Context._contextSuffixLength();
    }
}
