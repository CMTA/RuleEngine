//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "CMTAT/CMTAT.sol";

abstract contract HelperContract {
    CMTAT CMTAT_CONTRACT;
    address constant ZERO_ADDRESS = address(0);
    address constant OWNER = address(1);
    address constant ADDRESS1 = address(2);
    address constant ADDRESS2 = address(3);
    address constant ADDRESS3 = address(4);
    string constant PAUSER_ROLE_HASH =
        "0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a"; //keccak256("PAUSER_ROLE");
    string constant DEFAULT_ADMIN_ROLE_HASH =
        "0x0000000000000000000000000000000000000000000000000000000000000000";

    constructor() {}
}