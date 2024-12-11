// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "OZ/access/AccessControl.sol";
import "../../modules/MetaTxModuleStandalone.sol";
import "./abstract/RuleSanctionListInvariantStorage.sol";
import "./abstract/RuleValidateTransfer.sol";

interface SanctionsList {
    function isSanctioned(address addr) external view returns (bool);
}

contract RuleSanctionList is
    AccessControl,
    MetaTxModuleStandalone,
    RuleValidateTransfer,
    RuleSanctionlistInvariantStorage
{
    SanctionsList public sanctionsList;

    /**
     * @param admin Address of the contract (Access Control)
     * @param forwarderIrrevocable Address of the forwarder, required for the gasless support
     */
    constructor(
        address admin,
        address forwarderIrrevocable,
        address sanctionContractOracle_
    ) MetaTxModuleStandalone(forwarderIrrevocable) {
        if (admin == address(0)) {
            revert RuleSanctionList_AdminWithAddressZeroNotAllowed();
        }
        if (sanctionContractOracle_ != address(0)) {
            _setSanctionListOracle(sanctionContractOracle_);
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /**
     * @notice Set the oracle contract
     * @param sanctionContractOracle_ address of your oracle contract
     * @dev zero address is authorized to authorize all transfers
     */
    function setSanctionListOracle(
        address sanctionContractOracle_
    ) public onlyRole(SANCTIONLIST_ROLE) {
        _setSanctionListOracle(sanctionContractOracle_);
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
        if (address(sanctionsList) != address(0)) {
            if (sanctionsList.isSanctioned(_from)) {
                return CODE_ADDRESS_FROM_IS_SANCTIONED;
            } else if (sanctionsList.isSanctioned(_to)) {
                return CODE_ADDRESS_TO_IS_SANCTIONED;
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
            _restrictionCode == CODE_ADDRESS_FROM_IS_SANCTIONED ||
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

    /* ============ ACCESS CONTROL ============ */
    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControl) returns (bool) {
        // The Default Admin has all roles
        if (AccessControl.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        }
        return AccessControl.hasRole(role, account);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _setSanctionListOracle(address sanctionContractOracle_) internal {
        sanctionsList = SanctionsList(sanctionContractOracle_);
        emit SetSanctionListOracle(address(sanctionContractOracle_));
    }

    /*//////////////////////////////////////////////////////////////
                           ERC-2771
    //////////////////////////////////////////////////////////////*/

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
    function _contextSuffixLength()
        internal
        view
        override(ERC2771Context, Context)
        returns (uint256)
    {
        return ERC2771Context._contextSuffixLength();
    }
}
