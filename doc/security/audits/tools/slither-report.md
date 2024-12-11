**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [incorrect-equality](#incorrect-equality) (4 results) (Medium)
 - [calls-loop](#calls-loop) (8 results) (Low)
 - [timestamp](#timestamp) (5 results) (Low)
 - [costly-loop](#costly-loop) (2 results) (Informational)
 - [dead-code](#dead-code) (5 results) (Informational)
 - [solc-version](#solc-version) (1 results) (Informational)
 - [naming-convention](#naming-convention) (50 results) (Informational)
 - [similar-names](#similar-names) (7 results) (Informational)
 - [unused-import](#unused-import) (1 results) (Informational)
 - [var-read-using-this](#var-read-using-this) (1 results) (Optimization)
## incorrect-equality

> Strict equality is required to check the request status

Impact: Medium
Confidence: High
 - [ ] ID-0
	[RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)](src/rules/operation/RuleConditionalTransfer.sol#L177-L206) uses a dangerous strict equality:
	- [transferRequests[IdToKey[i_scope_0]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L196)

src/rules/operation/RuleConditionalTransfer.sol#L177-L206


 - [ ] ID-1
	[RuleConditionalTransfer._validateApproval(bytes32)](src/rules/operation/RuleConditionalTransfer.sol#L329-L349) uses a dangerous strict equality:
	- [isTransferApproved = (transferRequests[key].status == STATUS.APPROVED) && (transferRequests[key].maxTime >= block.timestamp)](src/rules/operation/RuleConditionalTransfer.sol#L341-L343)

src/rules/operation/RuleConditionalTransfer.sol#L329-L349


 - [ ] ID-2
	[RuleConditionalTransferOperator._checkRequestStatus(bytes32)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L383-L388) uses a dangerous strict equality:
	- [(transferRequests[key].status == STATUS.NONE) && (transferRequests[key].key == 0x0)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L385-L387)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L383-L388


 - [ ] ID-3
	[RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)](src/rules/operation/RuleConditionalTransfer.sol#L177-L206) uses a dangerous strict equality:
	- [transferRequests[IdToKey[i]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L186)

src/rules/operation/RuleConditionalTransfer.sol#L177-L206

## calls-loop

> Acknowledge

Impact: Low
Confidence: Medium
 - [ ] ID-4
[RuleWhitelistWrapper.detectTransferRestriction(address,address,uint256)](src/rules/validation/RuleWhitelistWrapper.sol#L39-L74) has external calls inside a loop: [isListed = RuleAddressList(_rulesValidation[i]).addressIsListedBatch(targetAddress)](src/rules/validation/RuleWhitelistWrapper.sol#L53-L54)

src/rules/validation/RuleWhitelistWrapper.sol#L39-L74


 - [ ] ID-5
[RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)](src/modules/RuleEngineValidation.sol#L29-L44) has external calls inside a loop: [restriction = IRuleValidation(_rulesValidation[i]).detectTransferRestriction(_from,_to,_amount)](src/modules/RuleEngineValidation.sol#L36-L37)

src/modules/RuleEngineValidation.sol#L29-L44


 - [ ] ID-6
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L100-L128) has external calls inside a loop: [IRuleValidation(_rulesOperation[i_scope_0]).messageForTransferRestriction(_restrictionCode)](src/RuleEngine.sol#L122-L124)

src/RuleEngine.sol#L100-L128


 - [ ] ID-7
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L100-L128) has external calls inside a loop: [IRuleValidation(_rulesValidation[i]).canReturnTransferRestrictionCode(_restrictionCode)](src/RuleEngine.sol#L107-L108)

src/RuleEngine.sol#L100-L128


 - [ ] ID-8
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L100-L128) has external calls inside a loop: [IRuleValidation(_rulesValidation[i]).messageForTransferRestriction(_restrictionCode)](src/RuleEngine.sol#L110-L112)

src/RuleEngine.sol#L100-L128


 - [ ] ID-9
[RuleConditionalTransferOperator._approveRequest(RuleConditionalTransferInvariantStorage.TransferRequest,bool)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L390-L449) has external calls inside a loop: [options.automaticTransfer.cmtat.allowance(transferRequest.keyElement.from,address(this)) >= transferRequest.keyElement.value](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L426-L429)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L390-L449


 - [ ] ID-10
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L100-L128) has external calls inside a loop: [IRuleValidation(_rulesOperation[i_scope_0]).canReturnTransferRestrictionCode(_restrictionCode)](src/RuleEngine.sol#L119-L120)

src/RuleEngine.sol#L100-L128


 - [ ] ID-11
[RuleEngine.detectTransferRestriction(address,address,uint256)](src/RuleEngine.sol#L50-L76) has external calls inside a loop: [restriction = IRuleValidation(_rulesOperation[i]).detectTransferRestriction(_from,_to,_amount)](src/RuleEngine.sol#L68-L69)

src/RuleEngine.sol#L50-L76

## timestamp

> With the Proof of Work, it was possible for a miner to modify the timestamp in a range of about 15 seconds
>
> With the Proof Of Stake, a new block is created every 12 seconds
>
> In all cases, we are not looking for such precision
>
> btw, ID-13 and ID-15 don't use timestamp in their comparison

Impact: Low
Confidence: Medium

 - [ ] ID-12
	[RuleConditionalTransfer._validateApproval(bytes32)](src/rules/operation/RuleConditionalTransfer.sol#L329-L349) uses timestamp for comparisons
	Dangerous comparisons:
	- [automaticApprovalCondition = options.automaticApproval.isActivate && block.timestamp >= (transferRequests[key].askTime + options.automaticApproval.timeLimitBeforeAutomaticApproval)](src/rules/operation/RuleConditionalTransfer.sol#L334-L339)
	- [isTransferApproved = (transferRequests[key].status == STATUS.APPROVED) && (transferRequests[key].maxTime >= block.timestamp)](src/rules/operation/RuleConditionalTransfer.sol#L341-L343)
	- [automaticApprovalCondition || isTransferApproved](src/rules/operation/RuleConditionalTransfer.sol#L344)

src/rules/operation/RuleConditionalTransfer.sol#L329-L349


 - [ ] ID-13
	[RuleConditionalTransferOperator._checkRequestStatus(bytes32)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L383-L388) uses timestamp for comparisons
	Dangerous comparisons:
	- [(transferRequests[key].status == STATUS.NONE) && (transferRequests[key].key == 0x0)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L385-L387)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L383-L388


 - [ ] ID-14
	[RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)](src/rules/operation/RuleConditionalTransfer.sol#L177-L206) uses timestamp for comparisons
	Dangerous comparisons:
	- [transferRequests[IdToKey[i]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L186)
	- [transferRequests[IdToKey[i_scope_0]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L196)

src/rules/operation/RuleConditionalTransfer.sol#L177-L206


 - [ ] ID-15
	[RuleConditionalTransfer._cancelTransferRequest(uint256)](src/rules/operation/RuleConditionalTransfer.sol#L281-L298) uses timestamp for comparisons
	Dangerous comparisons:
	- [transferRequests[key].keyElement.from != _msgSender()](src/rules/operation/RuleConditionalTransfer.sol#L287)

src/rules/operation/RuleConditionalTransfer.sol#L281-L298


 - [ ] ID-16
	[RuleConditionalTransferOperator._approveRequest(RuleConditionalTransferInvariantStorage.TransferRequest,bool)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L390-L449) uses timestamp for comparisons
	Dangerous comparisons:
	- [transferRequest.status != STATUS.WAIT](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L395)
	- [block.timestamp > (transferRequest.askTime + options.timeLimit.timeLimitToApprove)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L401-L402)
	- [options.automaticTransfer.cmtat.allowance(transferRequest.keyElement.from,address(this)) >= transferRequest.keyElement.value](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L426-L429)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L390-L449

## costly-loop

> Acknowledge

Impact: Informational
Confidence: Medium
 - [ ] ID-17
	[RuleConditionalTransfer.createTransferRequest(address,uint256)](src/rules/operation/RuleConditionalTransfer.sol#L79-L118) has costly operations inside a loop:
	- [++ requestId](src/rules/operation/RuleConditionalTransfer.sol#L105)

src/rules/operation/RuleConditionalTransfer.sol#L79-L118


 - [ ] ID-18
	[RuleConditionalTransferOperator._createTransferRequestWithApproval(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L325-L370) has costly operations inside a loop:
	- [++ requestId](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L354)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L325-L370

## dead-code

> - Implemented to be gasless compatible (see MetaTxModule)
>
> - If we remove this function, we will have the following error:
>
>   "Derived contract must override function "_msgData". Two or more base classes define function with same name and parameter types."

Impact: Informational
Confidence: Medium

 - [ ] ID-19
[RuleSanctionList._msgData()](src/rules/validation/RuleSanctionList.sol#L145-L152) is never used and should be removed

src/rules/validation/RuleSanctionList.sol#L145-L152


 - [ ] ID-20
[RuleAddressList._msgData()](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L156-L163) is never used and should be removed

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L156-L163


 - [ ] ID-21
[RuleWhitelistWrapper._msgData()](src/rules/validation/RuleWhitelistWrapper.sol#L110-L117) is never used and should be removed

src/rules/validation/RuleWhitelistWrapper.sol#L110-L117


 - [ ] ID-22
[RuleConditionalTransfer._msgData()](src/rules/operation/RuleConditionalTransfer.sol#L370-L377) is never used and should be removed

src/rules/operation/RuleConditionalTransfer.sol#L370-L377


 - [ ] ID-23
[RuleEngine._msgData()](src/RuleEngine.sol#L182-L189) is never used and should be removed

src/RuleEngine.sol#L182-L189

## solc-version

> The version set in the config file is 0.8.27

Impact: Informational
Confidence: High

 - [ ] ID-24
	Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
	 It is used by:
	- lib/CMTAT/contracts/interfaces/draft-IERC1404/draft-IERC1404.sol#3
	- lib/CMTAT/contracts/interfaces/draft-IERC1404/draft-IERC1404EnumCode.sol#3
	- lib/CMTAT/contracts/interfaces/draft-IERC1404/draft-IERC1404Wrapper.sol#3
	- lib/CMTAT/contracts/interfaces/engine/IRuleEngine.sol#3
	- lib/openzeppelin-contracts/contracts/access/AccessControl.sol#4
	- lib/openzeppelin-contracts/contracts/access/IAccessControl.sol#4
	- lib/openzeppelin-contracts/contracts/metatx/ERC2771Context.sol#4
	- lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#4
	- lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol#4
	- lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#4
	- lib/openzeppelin-contracts/contracts/utils/Address.sol#4
	- lib/openzeppelin-contracts/contracts/utils/Context.sol#4
	- lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#4
	- lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#4
	- src/RuleEngine.sol#3
	- src/interfaces/IRuleEngineOperation.sol#3
	- src/interfaces/IRuleEngineValidation.sol#3
	- src/interfaces/IRuleOperation.sol#3
	- src/interfaces/IRuleValidation.sol#3
	- src/modules/MetaTxModuleStandalone.sol#3
	- src/modules/RuleEngineInvariantStorage.sol#3
	- src/modules/RuleEngineOperation.sol#3
	- src/modules/RuleEngineValidation.sol#3
	- src/modules/RuleEngineValidationCommon.sol#3
	- src/modules/RuleInternal.sol#3
	- src/rules/operation/RuleConditionalTransfer.sol#3
	- src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#3
	- src/rules/operation/abstract/RuleConditionalTransferOperator.sol#3
	- src/rules/validation/RuleBlacklist.sol#3
	- src/rules/validation/RuleSanctionList.sol#3
	- src/rules/validation/RuleWhitelist.sol#3
	- src/rules/validation/RuleWhitelistWrapper.sol#3
	- src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#3
	- src/rules/validation/abstract/RuleAddressList/RuleAddressListInternal.sol#3
	- src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleAddressListInvariantStorage.sol#3
	- src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleBlacklistInvariantStorage.sol#3
	- src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#3
	- src/rules/validation/abstract/RuleCommonInvariantStorage.sol#2
	- src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#3
	- src/rules/validation/abstract/RuleValidateTransfer.sol#3
	- src/rules/validation/abstract/RuleWhitelistCommon.sol#3

## naming-convention

> Acknowledge

Impact: Informational
Confidence: High

 - [ ] ID-25
Event [RuleConditionalTransferInvariantStorage.transferDenied(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L124-L130) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L124-L130


 - [ ] ID-26
Parameter [RuleConditionalTransfer.operateOnTransfer(address,address,uint256)._amount](src/rules/operation/RuleConditionalTransfer.sol#L54) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L54


 - [ ] ID-27
Parameter [RuleWhitelistCommon.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/validation/abstract/RuleWhitelistCommon.sol#L18) is not in mixedCase

src/rules/validation/abstract/RuleWhitelistCommon.sol#L18


 - [ ] ID-28
Parameter [RuleValidateTransfer.validateTransfer(address,address,uint256)._from](src/rules/validation/abstract/RuleValidateTransfer.sol#L16) is not in mixedCase

src/rules/validation/abstract/RuleValidateTransfer.sol#L16


 - [ ] ID-29
Parameter [RuleEngine.detectTransferRestriction(address,address,uint256)._amount](src/RuleEngine.sol#L53) is not in mixedCase

src/RuleEngine.sol#L53


 - [ ] ID-30
Event [RuleConditionalTransferInvariantStorage.transferReset(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L131-L137) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L131-L137


 - [ ] ID-31
Parameter [RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)._amount](src/modules/RuleEngineValidation.sol#L32) is not in mixedCase

src/modules/RuleEngineValidation.sol#L32


 - [ ] ID-32
Parameter [RuleBlacklist.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/validation/RuleBlacklist.sol#L53) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L53


 - [ ] ID-33
Parameter [RuleWhitelistCommon.messageForTransferRestriction(uint8)._restrictionCode](src/rules/validation/abstract/RuleWhitelistCommon.sol#L31) is not in mixedCase

src/rules/validation/abstract/RuleWhitelistCommon.sol#L31


 - [ ] ID-34
Variable [RuleConditionalTransferOperator.IdToKey](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L21) is not in mixedCase

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L21


 - [ ] ID-35
Parameter [RuleSanctionList.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleSanctionList.sol#L59) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L59


 - [ ] ID-36
Parameter [RuleBlacklist.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleBlacklist.sol#L35) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L35


 - [ ] ID-37
Parameter [RuleEngine.detectTransferRestriction(address,address,uint256)._to](src/RuleEngine.sol#L52) is not in mixedCase

src/RuleEngine.sol#L52


 - [ ] ID-38
Parameter [RuleConditionalTransfer.detectTransferRestriction(address,address,uint256)._amount](src/rules/operation/RuleConditionalTransfer.sol#L217) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L217


 - [ ] ID-39
Parameter [RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)._targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L178) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L178


 - [ ] ID-40
Parameter [RuleEngine.detectTransferRestriction(address,address,uint256)._from](src/RuleEngine.sol#L51) is not in mixedCase

src/RuleEngine.sol#L51


 - [ ] ID-41
Parameter [RuleWhitelistWrapper.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleWhitelistWrapper.sol#L41) is not in mixedCase

src/rules/validation/RuleWhitelistWrapper.sol#L41


 - [ ] ID-42
Parameter [RuleConditionalTransfer.operateOnTransfer(address,address,uint256)._from](src/rules/operation/RuleConditionalTransfer.sol#L52) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L52


 - [ ] ID-43
Parameter [RuleBlacklist.messageForTransferRestriction(uint8)._restrictionCode](src/rules/validation/RuleBlacklist.sol#L66) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L66


 - [ ] ID-44
Parameter [RuleEngine.messageForTransferRestriction(uint8)._restrictionCode](src/RuleEngine.sol#L101) is not in mixedCase

src/RuleEngine.sol#L101


 - [ ] ID-45
Parameter [RuleSanctionList.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/validation/RuleSanctionList.sol#L78) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L78


 - [ ] ID-46
Parameter [RuleAddressList.addressIsListed(address)._targetAddress](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L103) is not in mixedCase

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L103


 - [ ] ID-47
Parameter [RuleEngineValidation.validateTransferValidation(address,address,uint256)._to](src/modules/RuleEngineValidation.sol#L55) is not in mixedCase

src/modules/RuleEngineValidation.sol#L55


 - [ ] ID-48
Event [RuleConditionalTransferInvariantStorage.transferWaiting(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L110-L116) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L110-L116


 - [ ] ID-49
Struct [RuleConditionalTransferInvariantStorage.TIME_LIMIT](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L30-L35) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L30-L35


 - [ ] ID-50
Parameter [RuleConditionalTransfer.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/operation/RuleConditionalTransfer.sol#L237) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L237


 - [ ] ID-51
Parameter [RuleEngine.validateTransfer(address,address,uint256)._amount](src/RuleEngine.sol#L88) is not in mixedCase

src/RuleEngine.sol#L88


 - [ ] ID-52
Struct [RuleConditionalTransferInvariantStorage.AUTOMATIC_APPROVAL](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L37-L44) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L37-L44


 - [ ] ID-53
Parameter [RuleEngineValidation.validateTransferValidation(address,address,uint256)._from](src/modules/RuleEngineValidation.sol#L54) is not in mixedCase

src/modules/RuleEngineValidation.sol#L54


 - [ ] ID-54
Parameter [RuleSanctionList.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleSanctionList.sol#L58) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L58


 - [ ] ID-55
Parameter [RuleConditionalTransfer.detectTransferRestriction(address,address,uint256)._to](src/rules/operation/RuleConditionalTransfer.sol#L216) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L216


 - [ ] ID-56
Parameter [RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)._from](src/modules/RuleEngineValidation.sol#L30) is not in mixedCase

src/modules/RuleEngineValidation.sol#L30


 - [ ] ID-57
Parameter [RuleEngineValidation.validateTransferValidation(address,address,uint256)._amount](src/modules/RuleEngineValidation.sol#L56) is not in mixedCase

src/modules/RuleEngineValidation.sol#L56


 - [ ] ID-58
Parameter [RuleWhitelistWrapper.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleWhitelistWrapper.sol#L40) is not in mixedCase

src/rules/validation/RuleWhitelistWrapper.sol#L40


 - [ ] ID-59
Parameter [RuleWhitelist.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleWhitelist.sol#L29) is not in mixedCase

src/rules/validation/RuleWhitelist.sol#L29


 - [ ] ID-60
Struct [RuleConditionalTransferInvariantStorage.AUTOMATIC_TRANSFER](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L18-L21) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L18-L21


 - [ ] ID-61
Parameter [RuleValidateTransfer.validateTransfer(address,address,uint256)._to](src/rules/validation/abstract/RuleValidateTransfer.sol#L17) is not in mixedCase

src/rules/validation/abstract/RuleValidateTransfer.sol#L17


 - [ ] ID-62
Event [RuleConditionalTransferInvariantStorage.transferProcessed(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L103-L109) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L103-L109


 - [ ] ID-63
Parameter [RuleWhitelist.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleWhitelist.sol#L28) is not in mixedCase

src/rules/validation/RuleWhitelist.sol#L28


 - [ ] ID-64
Parameter [RuleValidateTransfer.validateTransfer(address,address,uint256)._amount](src/rules/validation/abstract/RuleValidateTransfer.sol#L18) is not in mixedCase

src/rules/validation/abstract/RuleValidateTransfer.sol#L18


 - [ ] ID-65
Parameter [RuleEngine.validateTransfer(address,address,uint256)._from](src/RuleEngine.sol#L86) is not in mixedCase

src/RuleEngine.sol#L86


 - [ ] ID-66
Parameter [RuleConditionalTransfer.operateOnTransfer(address,address,uint256)._to](src/rules/operation/RuleConditionalTransfer.sol#L53) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L53


 - [ ] ID-67
Parameter [RuleConditionalTransfer.detectTransferRestriction(address,address,uint256)._from](src/rules/operation/RuleConditionalTransfer.sol#L215) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L215


 - [ ] ID-68
Parameter [RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)._to](src/modules/RuleEngineValidation.sol#L31) is not in mixedCase

src/modules/RuleEngineValidation.sol#L31


 - [ ] ID-69
Parameter [RuleBlacklist.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleBlacklist.sol#L34) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L34


 - [ ] ID-70
Parameter [RuleConditionalTransfer.messageForTransferRestriction(uint8)._restrictionCode](src/rules/operation/RuleConditionalTransfer.sol#L248) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L248


 - [ ] ID-71
Parameter [RuleSanctionList.messageForTransferRestriction(uint8)._restrictionCode](src/rules/validation/RuleSanctionList.sol#L91) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L91


 - [ ] ID-72
Parameter [RuleAddressList.addressIsListedBatch(address[])._targetAddresses](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L113) is not in mixedCase

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L113


 - [ ] ID-73
Parameter [RuleEngine.validateTransfer(address,address,uint256)._to](src/RuleEngine.sol#L87) is not in mixedCase

src/RuleEngine.sol#L87


 - [ ] ID-74
Event [RuleConditionalTransferInvariantStorage.transferApproved(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L117-L123) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L117-L123

## similar-names

> Acknowlege

Impact: Informational
Confidence: Medium
 - [ ] ID-75
Variable [RuleSanctionlistInvariantStorage.CODE_ADDRESS_FROM_IS_SANCTIONED](src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#L27) is too similar to [RuleSanctionlistInvariantStorage.TEXT_ADDRESS_FROM_IS_SANCTIONED](src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#L20-L21)

src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#L27


 - [ ] ID-76
Variable [RuleConditionalTransferOperator._createTransferRequestWithApproval(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement).keyElement_](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L326) is too similar to [RuleConditionalTransferOperator.createTransferRequestWithApprovalBatch(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement[]).keyElements](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L245)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L326


 - [ ] ID-77
Variable [RuleConditionalTransferOperator._createTransferRequestWithApproval(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement).keyElement_](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L326) is too similar to [RuleConditionalTransferOperator.approveTransferRequestBatch(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement[],uint256[],bool[]).keyElements](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L219)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L326


 - [ ] ID-78
Variable [RuleConditionalTransferInvariantStorage.CODE_TRANSFER_REQUEST_NOT_APPROVED](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L87) is too similar to [RuleConditionalTransferInvariantStorage.TEXT_TRANSFER_REQUEST_NOT_APPROVED](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L83-L84)

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L87


 - [ ] ID-79
Variable [RuleBlacklistInvariantStorage.CODE_ADDRESS_FROM_IS_BLACKLISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleBlacklistInvariantStorage.sol#L16) is too similar to [RuleBlacklistInvariantStorage.TEXT_ADDRESS_FROM_IS_BLACKLISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleBlacklistInvariantStorage.sol#L9-L10)

src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleBlacklistInvariantStorage.sol#L16


 - [ ] ID-80
Variable [RuleWhitelistInvariantStorage.CODE_ADDRESS_TO_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L17) is too similar to [RuleWhitelistInvariantStorage.TEXT_ADDRESS_TO_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L11-L12)

src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L17


 - [ ] ID-81
Variable [RuleWhitelistInvariantStorage.CODE_ADDRESS_FROM_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L16) is too similar to [RuleWhitelistInvariantStorage.TEXT_ADDRESS_FROM_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L9-L10)

src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L16

## unused-import

> Concerns OpenZeppelin library

Impact: Informational
Confidence: High
 - [ ] ID-82
	The following unused import(s) in lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol should be removed: 
	-import {IERC20Permit} from "../extensions/IERC20Permit.sol"; (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#7)

## var-read-using-this

> Don't manage to find a better solution

Impact: Optimization
Confidence: High
 - [ ] ID-83
The function [RuleValidateTransfer.validateTransfer(address,address,uint256)](src/rules/validation/abstract/RuleValidateTransfer.sol#L15-L24) reads [this.detectTransferRestriction(_from,_to,_amount) == uint8(REJECTED_CODE_BASE.TRANSFER_OK)](src/rules/validation/abstract/RuleValidateTransfer.sol#L21-L23) with `this` which adds an extra STATICCALL.

src/rules/validation/abstract/RuleValidateTransfer.sol#L15-L24

