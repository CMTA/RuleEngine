// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

interface ICompliance {
    // events
    event TokenBound(address _token);
    event TokenUnbound(address _token);

    // functions
    // initialization of the compliance contract
    function bindToken(address _token) external;
    function unbindToken(address _token) external;

    // check the parameters of the compliance contract
    function isTokenBound(address _token) external view returns (bool);
    function getTokenBound() external view returns (address);

    // compliance check and state update
    function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool);
    function transferred(address _from, address _to, uint256 _amount) external;
    function created(address _to, uint256 _amount) external;
    function destroyed(address _from, uint256 _amount) external;
}
