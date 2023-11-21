// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import "../../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "../../lib/CMTAT/contracts/mocks/RuleEngine/interfaces/IRule.sol";
import "../modules/MetaTxModuleStandalone.sol";
import "./abstract/RuleSanctionListInvariantStorage.sol";
interface SanctionsList {
    function isSanctioned(address addr) external view returns (bool);
}

contract RuleSanctionList is IRule, AccessControl, MetaTxModuleStandalone,  RuleSanctionlistInvariantStorage {
    SanctionsList  public sanctionsList;

    /**
    * @param admin Address of the contract (Access Control)
    * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
    */
    constructor(
        address admin,
        address forwarderIrrevocable
    ) MetaTxModuleStandalone(forwarderIrrevocable) {
        if(admin == address(0)){
            revert RuleSanctionsList_AdminWithAddressZeroNotAllowed();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(SANCTIONLIST_ROLE, admin);
    }

    /**
     * @notice Set all the rules, will overwrite all the previous rules. \n
     * Revert if one rule is a zero address or if the rule is already present
     *
     */
    function setOracle(
       address sanctionContractOracle_
    ) public onlyRole(SANCTIONLIST_ROLE) {
        sanctionsList = SanctionsList(sanctionContractOracle_);
    }

    /** 
    * @notice Validate a transfer
    * @param _from the origin address
    * @param _to the destination address
    * @param _amount to transfer
    * @return isValid => true if the transfer is valid, false otherwise
    **/
    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool isValid) {
        return
            detectTransferRestriction(_from, _to, _amount) ==
            uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /** 
    * @notice Check if an addres is in the whitelist or not
    * @param _from the origin address
    * @param _to the destination address
    * @return The restricion code or REJECTED_CODE_BASE.TRANSFER_OK
    **/
    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 /*_amount */
    ) public view override returns (uint8) {
        if(address(sanctionsList) != address(0)){
            if (sanctionsList.isSanctioned(_from)) {
                return CODE_ADDRESS_FROM_IS_SANCTIONED;
            } else if (sanctionsList.isSanctioned(_to)) {
                return  CODE_ADDRESS_TO_IS_SANCTIONED;
            }
        }
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    /** 
    * @notice To know if the restriction code is valid for this rule or not.
    * @param _restrictionCode The target restriction code
    * @return true if the restriction code is known, false otherwise
    **/
    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external pure override returns (bool) {
        return
            _restrictionCode ==  CODE_ADDRESS_FROM_IS_SANCTIONED ||
            _restrictionCode == CODE_ADDRESS_TO_IS_SANCTIONED;
    }

    /** 
    * @notice Return the corresponding message
    * @param _restrictionCode The target restriction code
    * @return true if the transfer is valid, false otherwise
    **/
    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external pure override returns (string memory) {
        if (_restrictionCode == CODE_ADDRESS_FROM_IS_SANCTIONED) {
            return TEXT_ADDRESS_FROM_IS_SANCTIONED;
        } else if (_restrictionCode == CODE_ADDRESS_TO_IS_SANCTIONED) {
            return TEXT_ADDRESS_TO_IS_SANCTIONED;
        } else {
            return TEXT_CODE_NOT_FOUND;
        }
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