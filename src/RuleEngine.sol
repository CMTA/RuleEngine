// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "CMTAT/interfaces/engine/IRuleEngine.sol";
import "./modules/MetaTxModuleStandalone.sol";
import "./modules/RuleEngineOperation.sol";
import "./modules/RuleEngineValidation.sol";
import "./modules/MetaTxModuleStandalone.sol";


/**
@title Implementation of a ruleEngine defined by the CMTAT
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

   


    function operateOnTransfer(address from, address to, uint256 amount) external override returns (bool isValid)  {
        // Validate the transfer
        if(!RuleEngineValidation.validateTransfer(from, to, amount)){
            return false; 
        }
        // Apply operation on RuleEngine
        // must revert in case of error, no return value
        RuleEngineOperation._operateOnTransfer(from, to, amount);
        return true;
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgSender()
        internal
        view
        override(MetaTxModuleStandalone, Context)
        returns (address sender)
    {
        return MetaTxModuleStandalone._msgSender();
    }

    /** 
    * @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgData()
        internal
        view
        override(MetaTxModuleStandalone, Context)
        returns (bytes calldata)
    {
        return MetaTxModuleStandalone._msgData();
    }
}
