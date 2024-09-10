**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [incorrect-equality](#incorrect-equality) (4 results) (Medium)
 - [calls-loop](#calls-loop) (8 results) (Low)
 - [timestamp](#timestamp) (5 results) (Low)
 - [costly-loop](#costly-loop) (2 results) (Informational)
 - [dead-code](#dead-code) (5 results) (Informational)
 - [solc-version](#solc-version) (1 results) (Informational)
 - [naming-convention](#naming-convention) (54 results) (Informational)
 - [similar-names](#similar-names) (7 results) (Informational)
 - [unused-import](#unused-import) (1 results) (Informational)
 - [var-read-using-this](#var-read-using-this) (1 results) (Optimization)
## incorrect-equality

> Strict equality is required to check the request status

Impact: Medium
Confidence: High
 - [ ] ID-0
	[RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)](src/rules/operation/RuleConditionalTransfer.sol#L194-L223) uses a dangerous strict equality:
	- [transferRequests[IdToKey[i]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L203)

src/rules/operation/RuleConditionalTransfer.sol#L194-L223


 - [ ] ID-1
	[RuleConditionalTransferOperator._checkRequestStatus(bytes32)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L367-L372) uses a dangerous strict equality:
	- [(transferRequests[key].status == STATUS.NONE) && (transferRequests[key].key == 0x0)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L369-L371)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L367-L372


 - [ ] ID-2
	[RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)](src/rules/operation/RuleConditionalTransfer.sol#L194-L223) uses a dangerous strict equality:
	- [transferRequests[IdToKey[i_scope_0]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L213)

src/rules/operation/RuleConditionalTransfer.sol#L194-L223


 - [ ] ID-3
	[RuleConditionalTransfer._validateApproval(bytes32)](src/rules/operation/RuleConditionalTransfer.sol#L332-L351) uses a dangerous strict equality:
	- [isTransferApproved = (transferRequests[key].status == STATUS.APPROVED) && (transferRequests[key].maxTime >= block.timestamp)](src/rules/operation/RuleConditionalTransfer.sol#L343-L345)

src/rules/operation/RuleConditionalTransfer.sol#L332-L351

## calls-loop

> Acknowledge

Impact: Low
Confidence: Medium

 - [ ] ID-4
[RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)](src/modules/RuleEngineValidation.sol#L29-L44) has external calls inside a loop: [restriction = IRuleValidation(_rulesValidation[i]).detectTransferRestriction(_from,_to,_amount)](src/modules/RuleEngineValidation.sol#L36-L37)

src/modules/RuleEngineValidation.sol#L29-L44


 - [ ] ID-5
[RuleWhitelistWrapper.detectTransferRestriction(address,address,uint256)](src/rules/validation/RuleWhitelistWrapper.sol#L40-L75) has external calls inside a loop: [isListed = RuleAddressList(_rulesValidation[i]).addressIsListedBatch(targetAddress)](src/rules/validation/RuleWhitelistWrapper.sol#L54-L55)

src/rules/validation/RuleWhitelistWrapper.sol#L40-L75


 - [ ] ID-6
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L97-L125) has external calls inside a loop: [IRuleValidation(_rulesValidation[i]).canReturnTransferRestrictionCode(_restrictionCode)](src/RuleEngine.sol#L104-L105)

src/RuleEngine.sol#L97-L125


 - [ ] ID-7
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L97-L125) has external calls inside a loop: [IRuleValidation(_rulesOperation[i_scope_0]).canReturnTransferRestrictionCode(_restrictionCode)](src/RuleEngine.sol#L116-L117)

src/RuleEngine.sol#L97-L125


 - [ ] ID-8
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L97-L125) has external calls inside a loop: [IRuleValidation(_rulesValidation[i]).messageForTransferRestriction(_restrictionCode)](src/RuleEngine.sol#L107-L109)

src/RuleEngine.sol#L97-L125


 - [ ] ID-9
[RuleEngine.detectTransferRestriction(address,address,uint256)](src/RuleEngine.sol#L47-L73) has external calls inside a loop: [restriction = IRuleValidation(_rulesOperation[i]).detectTransferRestriction(_from,_to,_amount)](src/RuleEngine.sol#L65-L66)

src/RuleEngine.sol#L47-L73


 - [ ] ID-10
[RuleConditionalTransferOperator._approveRequest(RuleConditionalTransferInvariantStorage.TransferRequest,bool)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L374-L433) has external calls inside a loop: [options.automaticTransfer.cmtat.allowance(transferRequest.keyElement.from,address(this)) >= transferRequest.keyElement.value](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L410-L413)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L374-L433


 - [ ] ID-11
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L97-L125) has external calls inside a loop: [IRuleValidation(_rulesOperation[i_scope_0]).messageForTransferRestriction(_restrictionCode)](src/RuleEngine.sol#L119-L121)

src/RuleEngine.sol#L97-L125

## timestamp

> With the Proof of Work, it was possible for a miner to modify the timestamp in a range of about 15 seconds
>
> With the Proof Of Stake, a new block is created every 12 seconds
>
> In all cases, we are not looking for such precision

Impact: Low
Confidence: Medium
 - [ ] ID-12
	[RuleConditionalTransferOperator._checkRequestStatus(bytes32)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L367-L372) uses timestamp for comparisons
	Dangerous comparisons:
	- [(transferRequests[key].status == STATUS.NONE) && (transferRequests[key].key == 0x0)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L369-L371)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L367-L372


 - [ ] ID-13
	[RuleConditionalTransfer._validateApproval(bytes32)](src/rules/operation/RuleConditionalTransfer.sol#L332-L351) uses timestamp for comparisons
	Dangerous comparisons:
	- [automaticApprovalCondition = options.automaticApproval.isActivate && ((transferRequests[key].askTime + options.automaticApproval.timeLimitBeforeAutomaticApproval) >= block.timestamp)](src/rules/operation/RuleConditionalTransfer.sol#L336-L341)
	- [isTransferApproved = (transferRequests[key].status == STATUS.APPROVED) && (transferRequests[key].maxTime >= block.timestamp)](src/rules/operation/RuleConditionalTransfer.sol#L343-L345)
	- [automaticApprovalCondition || isTransferApproved](src/rules/operation/RuleConditionalTransfer.sol#L346)

src/rules/operation/RuleConditionalTransfer.sol#L332-L351


 - [ ] ID-14
	[RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)](src/rules/operation/RuleConditionalTransfer.sol#L194-L223) uses timestamp for comparisons
	Dangerous comparisons:
	- [transferRequests[IdToKey[i]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L203)
	- [transferRequests[IdToKey[i_scope_0]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L213)

src/rules/operation/RuleConditionalTransfer.sol#L194-L223


 - [ ] ID-15
	[RuleConditionalTransferOperator._approveRequest(RuleConditionalTransferInvariantStorage.TransferRequest,bool)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L374-L433) uses timestamp for comparisons
	Dangerous comparisons:
	- [transferRequest.status != STATUS.WAIT](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L379)
	- [block.timestamp > (transferRequest.askTime + options.timeLimit.timeLimitToApprove)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L385-L386)
	- [options.automaticTransfer.cmtat.allowance(transferRequest.keyElement.from,address(this)) >= transferRequest.keyElement.value](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L410-L413)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L374-L433


 - [ ] ID-16
	[RuleConditionalTransfer._cancelTransferRequest(uint256)](src/rules/operation/RuleConditionalTransfer.sol#L284-L301) uses timestamp for comparisons
	Dangerous comparisons:
	- [transferRequests[key].keyElement.from != _msgSender()](src/rules/operation/RuleConditionalTransfer.sol#L290)

src/rules/operation/RuleConditionalTransfer.sol#L284-L301

## costly-loop

> Acknowledge

Impact: Informational
Confidence: Medium
 - [ ] ID-17
	[RuleConditionalTransferOperator._createTransferRequestWithApproval(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L311-L354) has costly operations inside a loop:
	- [++ requestId](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L339)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L311-L354


 - [ ] ID-18
	[RuleConditionalTransfer.createTransferRequest(address,uint256)](src/rules/operation/RuleConditionalTransfer.sol#L96-L135) has costly operations inside a loop:
	- [++ requestId](src/rules/operation/RuleConditionalTransfer.sol#L122)

src/rules/operation/RuleConditionalTransfer.sol#L96-L135

## dead-code

> - Implemented to be gasless compatible (see MetaTxModule)
>
> - If we remove this function, we will have the following error:
>
>   "Derived contract must override function "_msgData". Two or more base classes define function with same name and parameter types."

Impact: Informational
Confidence: Medium
 - [ ] ID-19
[RuleSanctionList._msgData()](src/rules/validation/RuleSanctionList.sol#L114-L121) is never used and should be removed

src/rules/validation/RuleSanctionList.sol#L114-L121


 - [ ] ID-20
[RuleAddressList._msgData()](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L135-L142) is never used and should be removed

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L135-L142


 - [ ] ID-21
[RuleWhitelistWrapper._msgData()](src/rules/validation/RuleWhitelistWrapper.sol#L92-L99) is never used and should be removed

src/rules/validation/RuleWhitelistWrapper.sol#L92-L99


 - [ ] ID-22
[RuleConditionalTransfer._msgData()](src/rules/operation/RuleConditionalTransfer.sol#L368-L375) is never used and should be removed

src/rules/operation/RuleConditionalTransfer.sol#L368-L375


 - [ ] ID-23
[RuleEngine._msgData()](src/RuleEngine.sol#L160-L167) is never used and should be removed

src/RuleEngine.sol#L160-L167

## solc-version

> The version set in the config file is 0.8.26

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
Impact: Informational
Confidence: High
 - [ ] ID-25
Event [RuleConditionalTransferInvariantStorage.transferDenied(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L125-L131) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L125-L131


 - [ ] ID-26
Parameter [RuleConditionalTransfer.operateOnTransfer(address,address,uint256)._amount](src/rules/operation/RuleConditionalTransfer.sol#L61) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L61


 - [ ] ID-27
Parameter [RuleWhitelistCommon.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/validation/abstract/RuleWhitelistCommon.sol#L17) is not in mixedCase

src/rules/validation/abstract/RuleWhitelistCommon.sol#L17


 - [ ] ID-28
Parameter [RuleValidateTransfer.validateTransfer(address,address,uint256)._from](src/rules/validation/abstract/RuleValidateTransfer.sol#L16) is not in mixedCase

src/rules/validation/abstract/RuleValidateTransfer.sol#L16


 - [ ] ID-29
Parameter [RuleEngine.detectTransferRestriction(address,address,uint256)._amount](src/RuleEngine.sol#L50) is not in mixedCase

src/RuleEngine.sol#L50


 - [ ] ID-30
Event [RuleConditionalTransferInvariantStorage.transferReset(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L132-L138) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L132-L138


 - [ ] ID-31
Parameter [RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)._amount](src/modules/RuleEngineValidation.sol#L32) is not in mixedCase

src/modules/RuleEngineValidation.sol#L32


 - [ ] ID-32
Parameter [RuleBlacklist.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/validation/RuleBlacklist.sol#L53) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L53


 - [ ] ID-33
Parameter [RuleWhitelistCommon.messageForTransferRestriction(uint8)._restrictionCode](src/rules/validation/abstract/RuleWhitelistCommon.sol#L30) is not in mixedCase

src/rules/validation/abstract/RuleWhitelistCommon.sol#L30


 - [ ] ID-34
Variable [RuleConditionalTransferOperator.IdToKey](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L22) is not in mixedCase

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L22


 - [ ] ID-35
Parameter [RuleSanctionList.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleSanctionList.sol#L56) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L56


 - [ ] ID-36
Parameter [RuleBlacklist.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleBlacklist.sol#L35) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L35


 - [ ] ID-37
Parameter [RuleEngine.detectTransferRestriction(address,address,uint256)._to](src/RuleEngine.sol#L49) is not in mixedCase

src/RuleEngine.sol#L49


 - [ ] ID-38
Parameter [RuleConditionalTransfer.detectTransferRestriction(address,address,uint256)._amount](src/rules/operation/RuleConditionalTransfer.sol#L234) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L234


 - [ ] ID-39
Parameter [RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)._targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L195) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L195


 - [ ] ID-40
Parameter [RuleEngine.detectTransferRestriction(address,address,uint256)._from](src/RuleEngine.sol#L48) is not in mixedCase

src/RuleEngine.sol#L48


 - [ ] ID-41
Parameter [RuleWhitelistWrapper.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleWhitelistWrapper.sol#L42) is not in mixedCase

src/rules/validation/RuleWhitelistWrapper.sol#L42


 - [ ] ID-42
Parameter [RuleConditionalTransfer.operateOnTransfer(address,address,uint256)._from](src/rules/operation/RuleConditionalTransfer.sol#L59) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L59


 - [ ] ID-43
Parameter [RuleBlacklist.messageForTransferRestriction(uint8)._restrictionCode](src/rules/validation/RuleBlacklist.sol#L66) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L66


 - [ ] ID-44
Parameter [RuleEngine.messageForTransferRestriction(uint8)._restrictionCode](src/RuleEngine.sol#L98) is not in mixedCase

src/RuleEngine.sol#L98


 - [ ] ID-45
Parameter [RuleAddressList.removeAddressFromTheList(address)._removeWhitelistAddress](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L80) is not in mixedCase

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L80


 - [ ] ID-46
Parameter [RuleSanctionList.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/validation/RuleSanctionList.sol#L75) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L75


 - [ ] ID-47
Parameter [RuleAddressList.addressIsListed(address)._targetAddress](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L101) is not in mixedCase

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L101


 - [ ] ID-48
Parameter [RuleEngineValidation.validateTransferValidation(address,address,uint256)._to](src/modules/RuleEngineValidation.sol#L55) is not in mixedCase

src/modules/RuleEngineValidation.sol#L55


 - [ ] ID-49
Event [RuleConditionalTransferInvariantStorage.transferWaiting(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L111-L117) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L111-L117


 - [ ] ID-50
Struct [RuleConditionalTransferInvariantStorage.TIME_LIMIT](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L30-L35) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L30-L35


 - [ ] ID-51
Parameter [RuleConditionalTransfer.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/operation/RuleConditionalTransfer.sol#L259) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L259


 - [ ] ID-52
Parameter [RuleEngine.validateTransfer(address,address,uint256)._amount](src/RuleEngine.sol#L85) is not in mixedCase

src/RuleEngine.sol#L85


 - [ ] ID-53
Struct [RuleConditionalTransferInvariantStorage.AUTOMATIC_APPROVAL](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L37-L44) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L37-L44


 - [ ] ID-54
Parameter [RuleEngineValidation.validateTransferValidation(address,address,uint256)._from](src/modules/RuleEngineValidation.sol#L54) is not in mixedCase

src/modules/RuleEngineValidation.sol#L54


 - [ ] ID-55
Parameter [RuleSanctionList.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleSanctionList.sol#L55) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L55


 - [ ] ID-56
Parameter [RuleConditionalTransfer.detectTransferRestriction(address,address,uint256)._to](src/rules/operation/RuleConditionalTransfer.sol#L233) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L233


 - [ ] ID-57
Parameter [RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)._from](src/modules/RuleEngineValidation.sol#L30) is not in mixedCase

src/modules/RuleEngineValidation.sol#L30


 - [ ] ID-58
Parameter [RuleEngineValidation.validateTransferValidation(address,address,uint256)._amount](src/modules/RuleEngineValidation.sol#L56) is not in mixedCase

src/modules/RuleEngineValidation.sol#L56


 - [ ] ID-59
Parameter [RuleWhitelistWrapper.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleWhitelistWrapper.sol#L41) is not in mixedCase

src/rules/validation/RuleWhitelistWrapper.sol#L41


 - [ ] ID-60
Parameter [RuleWhitelist.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleWhitelist.sol#L30) is not in mixedCase

src/rules/validation/RuleWhitelist.sol#L30


 - [ ] ID-61
Struct [RuleConditionalTransferInvariantStorage.AUTOMATIC_TRANSFER](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L18-L21) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L18-L21


 - [ ] ID-62
Parameter [RuleValidateTransfer.validateTransfer(address,address,uint256)._to](src/rules/validation/abstract/RuleValidateTransfer.sol#L17) is not in mixedCase

src/rules/validation/abstract/RuleValidateTransfer.sol#L17


 - [ ] ID-63
Parameter [RuleInternal.getRuleIndex(address[],address)._rules](src/modules/RuleInternal.sol#L85) is not in mixedCase

src/modules/RuleInternal.sol#L85


 - [ ] ID-64
Function [RuleConditionalTransferOperator._createTransferRequestWithApproval(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L311-L354) is not in mixedCase

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L311-L354


 - [ ] ID-65
Parameter [RuleAddressList.addAddressToTheList(address)._newWhitelistAddress](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L68) is not in mixedCase

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L68


 - [ ] ID-66
Event [RuleConditionalTransferInvariantStorage.transferProcessed(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L104-L110) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L104-L110


 - [ ] ID-67
Parameter [RuleWhitelist.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleWhitelist.sol#L29) is not in mixedCase

src/rules/validation/RuleWhitelist.sol#L29


 - [ ] ID-68
Parameter [RuleValidateTransfer.validateTransfer(address,address,uint256)._amount](src/rules/validation/abstract/RuleValidateTransfer.sol#L18) is not in mixedCase

src/rules/validation/abstract/RuleValidateTransfer.sol#L18


 - [ ] ID-69
Parameter [RuleEngine.validateTransfer(address,address,uint256)._from](src/RuleEngine.sol#L83) is not in mixedCase

src/RuleEngine.sol#L83


 - [ ] ID-70
Parameter [RuleConditionalTransfer.operateOnTransfer(address,address,uint256)._to](src/rules/operation/RuleConditionalTransfer.sol#L60) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L60


 - [ ] ID-71
Parameter [RuleConditionalTransfer.detectTransferRestriction(address,address,uint256)._from](src/rules/operation/RuleConditionalTransfer.sol#L232) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L232


 - [ ] ID-72
Parameter [RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)._to](src/modules/RuleEngineValidation.sol#L31) is not in mixedCase

src/modules/RuleEngineValidation.sol#L31


 - [ ] ID-73
Parameter [RuleBlacklist.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleBlacklist.sol#L34) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L34


 - [ ] ID-74
Parameter [RuleConditionalTransfer.messageForTransferRestriction(uint8)._restrictionCode](src/rules/operation/RuleConditionalTransfer.sol#L270) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L270


 - [ ] ID-75
Parameter [RuleSanctionList.messageForTransferRestriction(uint8)._restrictionCode](src/rules/validation/RuleSanctionList.sol#L88) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L88


 - [ ] ID-76
Parameter [RuleAddressList.addressIsListedBatch(address[])._targetAddresses](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L111) is not in mixedCase

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L111


 - [ ] ID-77
Parameter [RuleEngine.validateTransfer(address,address,uint256)._to](src/RuleEngine.sol#L84) is not in mixedCase

src/RuleEngine.sol#L84


 - [ ] ID-78
Event [RuleConditionalTransferInvariantStorage.transferApproved(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L118-L124) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L118-L124


## similar-names
Impact: Informational
Confidence: Medium
 - [ ] ID-79
Variable [RuleSanctionlistInvariantStorage.CODE_ADDRESS_FROM_IS_SANCTIONED](src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#L25) is too similar to [RuleSanctionlistInvariantStorage.TEXT_ADDRESS_FROM_IS_SANCTIONED](src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#L18-L19)

src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#L25


 - [ ] ID-80
Variable [RuleConditionalTransferOperator._createTransferRequestWithApproval(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement).keyElement_](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L312) is too similar to [RuleConditionalTransferOperator.createTransferRequestWithApprovalBatch(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement[]).keyElements](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L246)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L312


 - [ ] ID-81
Variable [RuleConditionalTransferOperator._createTransferRequestWithApproval(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement).keyElement_](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L312) is too similar to [RuleConditionalTransferOperator.approveTransferRequestBatch(RuleConditionalTransferInvariantStorage.TransferRequestKeyElement[],uint256[],bool[]).keyElements](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L220)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L312


 - [ ] ID-82
Variable [RuleConditionalTransferInvariantStorage.CODE_TRANSFER_REQUEST_NOT_APPROVED](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L88) is too similar to [RuleConditionalTransferInvariantStorage.TEXT_TRANSFER_REQUEST_NOT_APPROVED](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L84-L85)

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L88


 - [ ] ID-83
Variable [RuleBlacklistInvariantStorage.CODE_ADDRESS_FROM_IS_BLACKLISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleBlacklistInvariantStorage.sol#L16) is too similar to [RuleBlacklistInvariantStorage.TEXT_ADDRESS_FROM_IS_BLACKLISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleBlacklistInvariantStorage.sol#L9-L10)

src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleBlacklistInvariantStorage.sol#L16


 - [ ] ID-84
Variable [RuleWhitelistInvariantStorage.CODE_ADDRESS_TO_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L17) is too similar to [RuleWhitelistInvariantStorage.TEXT_ADDRESS_TO_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L11-L12)

src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L17


 - [ ] ID-85
Variable [RuleWhitelistInvariantStorage.CODE_ADDRESS_FROM_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L16) is too similar to [RuleWhitelistInvariantStorage.TEXT_ADDRESS_FROM_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L9-L10)

src/rules/validation/abstract/RuleAddressList/invariantStorage/RuleWhitelistInvariantStorage.sol#L16


## unused-import
Impact: Informational
Confidence: High
 - [ ] ID-86
	The following unused import(s) in lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol should be removed: 
	-import {IERC20Permit} from "../extensions/IERC20Permit.sol"; (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#7)

## var-read-using-this
Impact: Optimization
Confidence: High
 - [ ] ID-87
The function [RuleValidateTransfer.validateTransfer(address,address,uint256)](src/rules/validation/abstract/RuleValidateTransfer.sol#L15-L24) reads [this.detectTransferRestriction(_from,_to,_amount) == uint8(REJECTED_CODE_BASE.TRANSFER_OK)](src/rules/validation/abstract/RuleValidateTransfer.sol#L21-L23) with `this` which adds an extra STATICCALL.

src/rules/validation/abstract/RuleValidateTransfer.sol#L15-L24

