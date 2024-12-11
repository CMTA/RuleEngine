//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "OZ/access/AccessControl.sol";
import "CMTAT/CMTAT_STANDALONE.sol";

contract CMTATDeployment {
    // Share with helper contract
    address constant ZERO_ADDRESS = address(0);
    address constant DEFAULT_ADMIN_ADDRESS = address(1);

    CMTAT_STANDALONE public cmtat;

    constructor() {
        // CMTAT
        ICMTATConstructor.ERC20Attributes
            memory erc20Attributes = ICMTATConstructor.ERC20Attributes(
                "CMTA Token",
                "CMTAT",
                0
            );
        ICMTATConstructor.BaseModuleAttributes
            memory baseModuleAttributes = ICMTATConstructor
                .BaseModuleAttributes(
                    "CMTAT_ISIN",
                    "https://cmta.ch",
                    "CMTAT_info"
                );
        ICMTATConstructor.Engine memory engines = ICMTATConstructor.Engine(
            IRuleEngine(ZERO_ADDRESS),
            IDebtEngine(ZERO_ADDRESS),
            IAuthorizationEngine(ZERO_ADDRESS),
            IERC1643(ZERO_ADDRESS)
        );
        cmtat = new CMTAT_STANDALONE(
            ZERO_ADDRESS,
            DEFAULT_ADMIN_ADDRESS,
            erc20Attributes,
            baseModuleAttributes,
            engines
        );
    }
}
