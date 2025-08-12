//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== CMTAT === */
import {IERC3643ComplianceRead, IERC3643IComplianceContract} from "CMTAT/interfaces/tokenization/IERC3643Partial.sol";
interface IERC3643Compliance is IERC3643ComplianceRead, IERC3643IComplianceContract {

    // events
    event TokenBound(address token);
    event TokenUnbound(address token);

    // functions
    // initialization of the compliance contract
    function bindToken(address token) external;
    function unbindToken(address token) external;

    // check the parameters of the compliance contract
    function isTokenBound(address token) external view returns (bool);
    function getTokenBound() external view returns (address);
    function getTokenBounds() external view returns (address[] memory);

    // compliance check and state update
    function created(address to, uint256 value)external;
    function destroyed(address from, uint256 value) external;
}