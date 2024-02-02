// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

//import "CMTAT/mocks/RuleEngine/interfaces/IRule.sol";
import "./modules/MetaTxModuleStandalone.sol";
import "./modules/AccessControlExternalModule.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

/**
@title Implementation of a ruleEngine defined by the CMTAT
*/
contract AuthorizationEngine is AccessControl, MetaTxModuleStandalone,AccessControlExternalModule {
    error AuthorizationEngine_AdminWithAddressZeroNotAllowed();
    /// @dev Role to manage the ruleEngine
    bytes32 public constant CMTAT_CONTRACT_ROLE = keccak256("CMTAT_CONTRACT_ROLE");

    /**
    * @param admin Address of the contract (Access Control)
    * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
    */
    constructor(
        address admin,
        address forwarderIrrevocable,
        uint48 initialDelay, 
        address CMTAT_contract
    ) MetaTxModuleStandalone(forwarderIrrevocable) AccessControlExternalModule(initialDelay) {
        if(admin == address(0))
        {
            revert AuthorizationEngine_AdminWithAddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(AUTHORIZATION_ENGINE_ROLE, admin);
        _grantRole(CMTAT_CONTRACT_ROLE, CMTAT_contract);
    }

   

    /** 
    * @notice Validate a transfer
    * @return True if the operation is valid, false otherwise
    **/
    function operateOnAuthorization(
         bytes32 role, address account
    ) public view onlyRole(CMTAT_CONTRACT_ROLE) returns (bool)  {
        return checkTransferAdmin(role, account);
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
