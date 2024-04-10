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
        address forwarderIrrevocable,
        address tokenContract
    ) MetaTxModuleStandalone(forwarderIrrevocable) {
        if(admin == address(0))
        {
            revert RuleEngine_AdminWithAddressZeroNotAllowed();
        }
        if(tokenContract != address(0)){
            _grantRole(TOKEN_CONTRACT_ROLE, tokenContract);
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(RULE_ENGINE_ROLE, admin);
    }


        /** 
    * @notice Go through all the rule to know if a restriction exists on the transfer
    * @param _from the origin address
    * @param _to the destination address
    * @param _amount to transfer
    * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
    **/
    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (uint8) {
        // Validation
        uint8 code = RuleEngineValidation.detectTransferRestrictionValidation(_from, _to, _amount);
        if(code != uint8(REJECTED_CODE_BASE.TRANSFER_OK) ){
            return code;
        }

        // Operation
        uint256 rulesLength = _rulesOperation.length;
        for (uint256 i = 0; i < rulesLength; ++i ) {
            uint8 restriction = IRuleValidation(_rulesOperation[i]).detectTransferRestriction(
                _from,
                _to,
                _amount
            );
            if (restriction > 0) {
                return restriction;
            }
        }
        
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /** 
    * @notice Validate a transfer
    * @param _from the origin address
    * @param _to the destination address
    * @param _amount to transfer
    * @return True if the transfer is valid, false otherwise
    **/
    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool) {
        return detectTransferRestriction(_from, _to, _amount) == uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /** 
    * @notice Return the message corresponding to the code
    * @param _restrictionCode The target restriction code
    * @return True if the transfer is valid, false otherwise
    **/
    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external view override returns (string memory) {
        // Validation
        uint256 rulesLength = _rulesValidation.length;
        for (uint256 i = 0; i < rulesLength; ++i) {
            if (IRuleValidation(_rulesValidation[i]).canReturnTransferRestrictionCode(_restrictionCode)) {
                return
                    IRuleValidation(_rulesValidation[i]).messageForTransferRestriction(_restrictionCode);
            }
        }
        // operation
        rulesLength = _rulesOperation.length;
        for (uint256 i = 0; i < rulesLength; ++i) {
            if (IRuleValidation(_rulesOperation[i]).canReturnTransferRestrictionCode(_restrictionCode)) {
                return
                    IRuleValidation(_rulesOperation[i]).messageForTransferRestriction(_restrictionCode);
            }
        }
        return "Unknown restriction code";
    }

    /*
    * @notice function protected by access control
    */
    function operateOnTransfer(address from, address to, uint256 amount) external override onlyRole(TOKEN_CONTRACT_ROLE) returns (bool isValid)  {
        // Validate the transfer
        if(!RuleEngineValidation.validateTransferValidation(from, to, amount)){
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
