//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {ICMTATConstructor, CMTATStandalone} from "CMTATv3.0.0/deployment/CMTATStandalone.sol";
import {IRuleEngine} from "CMTATv3.0.0/interfaces/engine/IRuleEngine.sol";
import {ISnapshotEngine} from "CMTATv3.0.0/interfaces/engine/ISnapshotEngine.sol";
import {IDocumentEngine, IERC1643} from "CMTATv3.0.0/interfaces/engine/IDocumentEngine.sol";
import {IERC1643CMTAT} from "CMTATv3.0.0/interfaces/tokenization/draft-IERC1643CMTAT.sol";

contract CMTATDeploymentV3 {
    // Share with helper contract
    address constant ZERO_ADDRESS = address(0);
    address constant DEFAULT_ADMIN_ADDRESS = address(1);

    CMTATStandalone public cmtat;

    constructor() {
        // CMTAT
        ICMTATConstructor.ERC20Attributes
            memory erc20Attributes = ICMTATConstructor.ERC20Attributes(
                "CMTA Token",
                "CMTAT",
                0
            );
        ICMTATConstructor.ExtraInformationAttributes
            memory ExtraInformationAttributes = ICMTATConstructor
                .ExtraInformationAttributes(
                    "CMTAT_ISIN",
                    IERC1643CMTAT.DocumentInfo(
                        "Terms",
                        "https://cmta.ch",
                        0x9ff867f6592aa9d6d039e7aad6bd71f1659720cbc4dd9eae1554f6eab490098b
                    ),
                    "CMTAT_info"
                );
        ICMTATConstructor.Engine memory engines = ICMTATConstructor.Engine(
            IRuleEngine(ZERO_ADDRESS),
            ISnapshotEngine(ZERO_ADDRESS),
            IERC1643(ZERO_ADDRESS)
        );
        cmtat = new CMTATStandalone(
            ZERO_ADDRESS,
            DEFAULT_ADMIN_ADDRESS,
            erc20Attributes,
            ExtraInformationAttributes,
            engines
        );
    }
}
