**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [calls-loop](#calls-loop) (3 results) (Low)
 - [dead-code](#dead-code) (4 results) (Informational)
 - [solc-version](#solc-version) (16 results) (Informational)
 - [naming-convention](#naming-convention) (30 results) (Informational)
 - [similar-names](#similar-names) (3 results) (Informational)
## calls-loop
Impact: Low
Confidence: Medium
 - [ ] ID-0
[RuleEngineValidation.messageForTransferRestriction(uint8)](src/modules/RuleEngineValidation.sol#L176-L190) has external calls inside a loop: [IRuleValidation(_rules[i]).messageForTransferRestriction(_restrictionCode)](src/modules/RuleEngineValidation.sol#L182-L183)

src/modules/RuleEngineValidation.sol#L176-L190


 - [ ] ID-1
[RuleEngineValidation.messageForTransferRestriction(uint8)](src/modules/RuleEngineValidation.sol#L176-L190) has external calls inside a loop: [IRuleValidation(_rules[i]).canReturnTransferRestrictionCode(_restrictionCode)](src/modules/RuleEngineValidation.sol#L181)

src/modules/RuleEngineValidation.sol#L176-L190


 - [ ] ID-2
[RuleEngineValidation.detectTransferRestriction(address,address,uint256)](src/modules/RuleEngineValidation.sol#L130-L153) has external calls inside a loop: [restriction = IRuleValidation(_rules[i]).detectTransferRestriction(_from,_to,_amount)](src/modules/RuleEngineValidation.sol#L137-L141)

src/modules/RuleEngineValidation.sol#L130-L153


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-3
[RuleSanctionList._msgData()](src/rules/RuleSanctionList.sol#L130-L137) is never used and should be removed

src/rules/RuleSanctionList.sol#L130-L137


 - [ ] ID-4
[MetaTxModuleStandalone._msgData()](src/modules/MetaTxModuleStandalone.sol#L25-L33) is never used and should be removed

src/modules/MetaTxModuleStandalone.sol#L25-L33


 - [ ] ID-5
[RuleEngine._msgData()](src/RuleEngine.sol#L62-L69) is never used and should be removed

src/RuleEngine.sol#L62-L69


 - [ ] ID-6
[RuleWhitelist._msgData()](src/rules/RuleWhitelist.sol#L212-L219) is never used and should be removed

src/rules/RuleWhitelist.sol#L212-L219


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-7
Pragma version[^0.8.20](src/RuleEngine.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/RuleEngine.sol#L3


 - [ ] ID-8
Pragma version[^0.8.20](src/rules/abstract/RuleWhitelistInvariantStorage.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/rules/abstract/RuleWhitelistInvariantStorage.sol#L3


 - [ ] ID-9
Pragma version[^0.8.0](src/interfaces/IRuleEngineOperation.sol#L3) allows old versions

src/interfaces/IRuleEngineOperation.sol#L3


 - [ ] ID-10
Pragma version[^0.8.20](src/modules/RuleEngineInvariantStorage.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/modules/RuleEngineInvariantStorage.sol#L3


 - [ ] ID-11
Pragma version[^0.8.20](src/modules/RuleEngineValidation.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/modules/RuleEngineValidation.sol#L3


 - [ ] ID-12
Pragma version[^0.8.20](src/rules/abstract/RuleCommonInvariantStorage.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/rules/abstract/RuleCommonInvariantStorage.sol#L2


 - [ ] ID-13
solc-0.8.20 is not recommended for deployment

 - [ ] ID-14
Pragma version[^0.8.20](src/rules/RuleWhitelist.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/rules/RuleWhitelist.sol#L3


 - [ ] ID-15
Pragma version[^0.8.20](src/modules/MetaTxModuleStandalone.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/modules/MetaTxModuleStandalone.sol#L3


 - [ ] ID-16
Pragma version[^0.8.20](src/modules/RuleInternal.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/modules/RuleInternal.sol#L3


 - [ ] ID-17
Pragma version[^0.8.20](src/rules/RuleSanctionList.sol#L9) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/rules/RuleSanctionList.sol#L9


 - [ ] ID-18
Pragma version[^0.8.20](src/rules/abstract/RuleSanctionListInvariantStorage.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/rules/abstract/RuleSanctionListInvariantStorage.sol#L3


 - [ ] ID-19
Pragma version[^0.8.0](src/interfaces/IRuleEngineValidation.sol#L3) allows old versions

src/interfaces/IRuleEngineValidation.sol#L3


 - [ ] ID-20
Pragma version[^0.8.0](src/interfaces/IRuleValidation.sol#L3) allows old versions

src/interfaces/IRuleValidation.sol#L3


 - [ ] ID-21
Pragma version[^0.8.20](src/modules/RuleEngineOperation.sol#L3) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/modules/RuleEngineOperation.sol#L3


 - [ ] ID-22
Pragma version[^0.8.0](src/interfaces/IRuleOperation.sol#L3) allows old versions

src/interfaces/IRuleOperation.sol#L3


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-23
Parameter [RuleWhitelist.addressIsWhitelisted(address)._targetAddress](src/rules/RuleWhitelist.sol#L125) is not in mixedCase

src/rules/RuleWhitelist.sol#L125


 - [ ] ID-24
Parameter [RuleInternal.removeRule(address[],address,uint256)._rules](src/modules/RuleInternal.sol#L81) is not in mixedCase

src/modules/RuleInternal.sol#L81


 - [ ] ID-25
Variable [RuleEngineValidation._rules](src/modules/RuleEngineValidation.sol#L14) is not in mixedCase

src/modules/RuleEngineValidation.sol#L14


 - [ ] ID-26
Variable [RuleInternal._ruleIsPresent](src/modules/RuleInternal.sol#L13) is not in mixedCase

src/modules/RuleInternal.sol#L13


 - [ ] ID-27
Parameter [RuleSanctionList.detectTransferRestriction(address,address,uint256)._to](src/rules/RuleSanctionList.sol#L72) is not in mixedCase

src/rules/RuleSanctionList.sol#L72


 - [ ] ID-28
Parameter [RuleEngineValidation.validateTransfer(address,address,uint256)._to](src/modules/RuleEngineValidation.sol#L164) is not in mixedCase

src/modules/RuleEngineValidation.sol#L164


 - [ ] ID-29
Parameter [RuleWhitelist.removeAddressFromTheWhitelist(address)._removeWhitelistAddress](src/rules/RuleWhitelist.sol#L100) is not in mixedCase

src/rules/RuleWhitelist.sol#L100


 - [ ] ID-30
Parameter [RuleEngineValidation.detectTransferRestriction(address,address,uint256)._from](src/modules/RuleEngineValidation.sol#L131) is not in mixedCase

src/modules/RuleEngineValidation.sol#L131


 - [ ] ID-31
Parameter [RuleWhitelist.validateTransfer(address,address,uint256)._to](src/rules/RuleWhitelist.sol#L139) is not in mixedCase

src/rules/RuleWhitelist.sol#L139


 - [ ] ID-32
Parameter [RuleSanctionList.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/RuleSanctionList.sol#L91) is not in mixedCase

src/rules/RuleSanctionList.sol#L91


 - [ ] ID-33
Parameter [RuleSanctionList.validateTransfer(address,address,uint256)._from](src/rules/RuleSanctionList.sol#L55) is not in mixedCase

src/rules/RuleSanctionList.sol#L55


 - [ ] ID-34
Parameter [RuleSanctionList.validateTransfer(address,address,uint256)._amount](src/rules/RuleSanctionList.sol#L57) is not in mixedCase

src/rules/RuleSanctionList.sol#L57


 - [ ] ID-35
Parameter [RuleEngineValidation.detectTransferRestriction(address,address,uint256)._amount](src/modules/RuleEngineValidation.sol#L133) is not in mixedCase

src/modules/RuleEngineValidation.sol#L133


 - [ ] ID-36
Parameter [RuleSanctionList.validateTransfer(address,address,uint256)._to](src/rules/RuleSanctionList.sol#L56) is not in mixedCase

src/rules/RuleSanctionList.sol#L56


 - [ ] ID-37
Parameter [RuleWhitelist.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/RuleWhitelist.sol#L173) is not in mixedCase

src/rules/RuleWhitelist.sol#L173


 - [ ] ID-38
Parameter [RuleEngineValidation.detectTransferRestriction(address,address,uint256)._to](src/modules/RuleEngineValidation.sol#L132) is not in mixedCase

src/modules/RuleEngineValidation.sol#L132


 - [ ] ID-39
Parameter [RuleInternal.addRule(address[],address)._rules](src/modules/RuleInternal.sol#L56) is not in mixedCase

src/modules/RuleInternal.sol#L56


 - [ ] ID-40
Parameter [RuleEngineValidation.validateTransfer(address,address,uint256)._from](src/modules/RuleEngineValidation.sol#L163) is not in mixedCase

src/modules/RuleEngineValidation.sol#L163


 - [ ] ID-41
Parameter [RuleSanctionList.detectTransferRestriction(address,address,uint256)._from](src/rules/RuleSanctionList.sol#L71) is not in mixedCase

src/rules/RuleSanctionList.sol#L71


 - [ ] ID-42
Parameter [RuleWhitelist.detectTransferRestriction(address,address,uint256)._to](src/rules/RuleWhitelist.sol#L155) is not in mixedCase

src/rules/RuleWhitelist.sol#L155


 - [ ] ID-43
Parameter [RuleWhitelist.messageForTransferRestriction(uint8)._restrictionCode](src/rules/RuleWhitelist.sol#L186) is not in mixedCase

src/rules/RuleWhitelist.sol#L186


 - [ ] ID-44
Parameter [RuleInternal.getRuleIndex(address[],address)._rules](src/modules/RuleInternal.sol#L101) is not in mixedCase

src/modules/RuleInternal.sol#L101


 - [ ] ID-45
Parameter [RuleWhitelist.detectTransferRestriction(address,address,uint256)._from](src/rules/RuleWhitelist.sol#L154) is not in mixedCase

src/rules/RuleWhitelist.sol#L154


 - [ ] ID-46
Parameter [RuleWhitelist.validateTransfer(address,address,uint256)._from](src/rules/RuleWhitelist.sol#L138) is not in mixedCase

src/rules/RuleWhitelist.sol#L138


 - [ ] ID-47
Parameter [RuleEngineValidation.validateTransfer(address,address,uint256)._amount](src/modules/RuleEngineValidation.sol#L165) is not in mixedCase

src/modules/RuleEngineValidation.sol#L165


 - [ ] ID-48
Variable [RuleEngineOperation._rulesOperation](src/modules/RuleEngineOperation.sol#L14) is not in mixedCase

src/modules/RuleEngineOperation.sol#L14


 - [ ] ID-49
Parameter [RuleWhitelist.addAddressToTheWhitelist(address)._newWhitelistAddress](src/rules/RuleWhitelist.sol#L83) is not in mixedCase

src/rules/RuleWhitelist.sol#L83


 - [ ] ID-50
Parameter [RuleSanctionList.messageForTransferRestriction(uint8)._restrictionCode](src/rules/RuleSanctionList.sol#L104) is not in mixedCase

src/rules/RuleSanctionList.sol#L104


 - [ ] ID-51
Parameter [RuleEngineValidation.messageForTransferRestriction(uint8)._restrictionCode](src/modules/RuleEngineValidation.sol#L177) is not in mixedCase

src/modules/RuleEngineValidation.sol#L177


 - [ ] ID-52
Parameter [RuleWhitelist.validateTransfer(address,address,uint256)._amount](src/rules/RuleWhitelist.sol#L140) is not in mixedCase

src/rules/RuleWhitelist.sol#L140


## similar-names
Impact: Informational
Confidence: Medium
 - [ ] ID-53
Variable [RuleSanctionlistInvariantStorage.CODE_ADDRESS_FROM_IS_SANCTIONED](src/rules/abstract/RuleSanctionListInvariantStorage.sol#L23) is too similar to [RuleSanctionlistInvariantStorage.TEXT_ADDRESS_FROM_IS_SANCTIONED](src/rules/abstract/RuleSanctionListInvariantStorage.sol#L15-L16)

src/rules/abstract/RuleSanctionListInvariantStorage.sol#L23


 - [ ] ID-54
Variable [RuleWhitelistInvariantStorage.CODE_ADDRESS_TO_NOT_WHITELISTED](src/rules/abstract/RuleWhitelistInvariantStorage.sol#L24) is too similar to [RuleWhitelistInvariantStorage.TEXT_ADDRESS_TO_NOT_WHITELISTED](src/rules/abstract/RuleWhitelistInvariantStorage.sol#L18-L19)

src/rules/abstract/RuleWhitelistInvariantStorage.sol#L24


 - [ ] ID-55
Variable [RuleWhitelistInvariantStorage.CODE_ADDRESS_FROM_NOT_WHITELISTED](src/rules/abstract/RuleWhitelistInvariantStorage.sol#L23) is too similar to [RuleWhitelistInvariantStorage.TEXT_ADDRESS_FROM_NOT_WHITELISTED](src/rules/abstract/RuleWhitelistInvariantStorage.sol#L16-L17)

src/rules/abstract/RuleWhitelistInvariantStorage.sol#L23


