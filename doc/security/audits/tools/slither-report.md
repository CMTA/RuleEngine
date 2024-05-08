**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [arbitrary-send-erc20](#arbitrary-send-erc20) (1 results) (High)
 - [incorrect-equality](#incorrect-equality) (4 results) (Medium)
 - [calls-loop](#calls-loop) (6 results) (Low)
 - [timestamp](#timestamp) (5 results) (Low)
 - [pragma](#pragma) (1 results) (Informational)
 - [dead-code](#dead-code) (4 results) (Informational)
 - [solc-version](#solc-version) (2 results) (Informational)
 - [naming-convention](#naming-convention) (50 results) (Informational)
 - [similar-names](#similar-names) (5 results) (Informational)
 - [unused-import](#unused-import) (1 results) (Informational)
 - [var-read-using-this](#var-read-using-this) (1 results) (Optimization)
## arbitrary-send-erc20

> from is set inside the smart contract when a request is created

Impact: High
Confidence: High
 - [ ] ID-0
[RuleConditionalTransferOperator._approveRequest(RuleConditionalTransferInvariantStorage.TransferRequest,bool)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L124-L152) uses arbitrary from in transferFrom: [options.automaticTransfer.cmtat.safeTransferFrom(transferRequest.from,transferRequest.to,transferRequest.value)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L145)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L124-L152

## incorrect-equality

> Strict equality is required to check the request status

Impact: Medium
Confidence: High

 - [ ] ID-1
	[RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)](src/rules/operation/RuleConditionalTransfer.sol#L116-L141) uses a dangerous strict equality:
	- [transferRequests[IdToKey[i_scope_0]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L133)

src/rules/operation/RuleConditionalTransfer.sol#L116-L141


 - [ ] ID-2
	[RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)](src/rules/operation/RuleConditionalTransfer.sol#L116-L141) uses a dangerous strict equality:
	- [transferRequests[IdToKey[i]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L123)

src/rules/operation/RuleConditionalTransfer.sol#L116-L141


 - [ ] ID-3
	[RuleConditionalTransfer._validateApproval(bytes32)](src/rules/operation/RuleConditionalTransfer.sol#L239-L251) uses a dangerous strict equality:
	- [isTransferApproved = (transferRequests[key].status == STATUS.APPROVED) && (transferRequests[key].maxTime >= block.timestamp)](src/rules/operation/RuleConditionalTransfer.sol#L243-L244)

src/rules/operation/RuleConditionalTransfer.sol#L239-L251


 - [ ] ID-4
	[RuleConditionalTransferOperator._checkRequestStatus(bytes32)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L120-L122) uses a dangerous strict equality:
	- [(transferRequests[key].status == STATUS.NONE) && (transferRequests[key].key == 0x0)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L121)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L120-L122

## calls-loop

> - Rules are trusted contracts deployed by the issuer.
>
> It is not a problem to perform external call to these contracts
>
> - When a ruleEngine is created, the issuer has indeed to keep in mind to limit the number of rules used.

Impact: Low
Confidence: Medium
 - [ ] ID-5
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L91-L111) has external calls inside a loop: [IRuleValidation(_rulesOperation[i_scope_0]).messageForTransferRestriction(_restrictionCode)](src/RuleEngine.sol#L106-L107)

src/RuleEngine.sol#L91-L111


 - [ ] ID-6
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L91-L111) has external calls inside a loop: [IRuleValidation(_rulesValidation[i]).canReturnTransferRestrictionCode(_restrictionCode)](src/RuleEngine.sol#L97)

src/RuleEngine.sol#L91-L111


 - [ ] ID-7
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L91-L111) has external calls inside a loop: [IRuleValidation(_rulesOperation[i_scope_0]).canReturnTransferRestrictionCode(_restrictionCode)](src/RuleEngine.sol#L105)

src/RuleEngine.sol#L91-L111


 - [ ] ID-8
[RuleEngine.messageForTransferRestriction(uint8)](src/RuleEngine.sol#L91-L111) has external calls inside a loop: [IRuleValidation(_rulesValidation[i]).messageForTransferRestriction(_restrictionCode)](src/RuleEngine.sol#L98-L99)

src/RuleEngine.sol#L91-L111


 - [ ] ID-9
[RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)](src/modules/RuleEngineValidation.sol#L143-L161) has external calls inside a loop: [restriction = IRuleValidation(_rulesValidation[i]).detectTransferRestriction(_from,_to,_amount)](src/modules/RuleEngineValidation.sol#L150-L154)

src/modules/RuleEngineValidation.sol#L143-L161


 - [ ] ID-10
[RuleEngine.detectTransferRestriction(address,address,uint256)](src/RuleEngine.sol#L44-L69) has external calls inside a loop: [restriction = IRuleValidation(_rulesOperation[i]).detectTransferRestriction(_from,_to,_amount)](src/RuleEngine.sol#L58-L62)

src/RuleEngine.sol#L44-L69

## timestamp

> With the Proof of Work, it was possible for a miner to modify the timestamp in a range of about 15 seconds
>
> With the Proof Of Stake, a new block is created every 12 seconds
>
> In all cases, we are not looking for such precision

Impact: Low
Confidence: Medium

 - [ ] ID-11
	[RuleConditionalTransfer._validateApproval(bytes32)](src/rules/operation/RuleConditionalTransfer.sol#L239-L251) uses timestamp for comparisons
	Dangerous comparisons:
	- [automaticApprovalCondition = options.automaticApproval.isActivate && ((transferRequests[key].askTime + options.automaticApproval.timeLimitBeforeAutomaticApproval) >= block.timestamp)](src/rules/operation/RuleConditionalTransfer.sol#L242)
	- [isTransferApproved = (transferRequests[key].status == STATUS.APPROVED) && (transferRequests[key].maxTime >= block.timestamp)](src/rules/operation/RuleConditionalTransfer.sol#L243-L244)
	- [automaticApprovalCondition || isTransferApproved](src/rules/operation/RuleConditionalTransfer.sol#L245)

src/rules/operation/RuleConditionalTransfer.sol#L239-L251


 - [ ] ID-12
	[RuleConditionalTransfer.cancelTransferRequest(uint256)](src/rules/operation/RuleConditionalTransfer.sol#L85-L103) uses timestamp for comparisons
	Dangerous comparisons:
	- [transferRequests[key].from != _msgSender()](src/rules/operation/RuleConditionalTransfer.sol#L93)

src/rules/operation/RuleConditionalTransfer.sol#L85-L103


 - [ ] ID-13
	[RuleConditionalTransferOperator._approveRequest(RuleConditionalTransferInvariantStorage.TransferRequest,bool)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L124-L152) uses timestamp for comparisons
	Dangerous comparisons:
	- [block.timestamp > (transferRequest.askTime + options.timeLimit.timeLimitToApprove)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L131)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L124-L152


 - [ ] ID-14
	[RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)](src/rules/operation/RuleConditionalTransfer.sol#L116-L141) uses timestamp for comparisons
	Dangerous comparisons:
	- [transferRequests[IdToKey[i]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L123)
	- [transferRequests[IdToKey[i_scope_0]].status == _targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L133)

src/rules/operation/RuleConditionalTransfer.sol#L116-L141


 - [ ] ID-15
	[RuleConditionalTransferOperator._checkRequestStatus(bytes32)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L120-L122) uses timestamp for comparisons
	Dangerous comparisons:
	- [(transferRequests[key].status == STATUS.NONE) && (transferRequests[key].key == 0x0)](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L121)

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L120-L122

## pragma

> Concerns the CMTAT lib, will be fixed in the CMTAT lib.

Impact: Informational
Confidence: High
 - [ ] ID-16
	2 different versions of Solidity are used:
	- Version constraint ^0.8.0 is used by:
 		- lib/CMTAT/contracts/interfaces/draft-IERC1404/draft-IERC1404.sol#3
		- lib/CMTAT/contracts/interfaces/draft-IERC1404/draft-IERC1404EnumCode.sol#3
		- lib/CMTAT/contracts/interfaces/draft-IERC1404/draft-IERC1404Wrapper.sol#3
		- lib/CMTAT/contracts/interfaces/engine/IRuleEngine.sol#3
	- Version constraint ^0.8.20 is used by:
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
		- src/modules/RuleInternal.sol#3
		- src/rules/operation/RuleConditionalTransfer.sol#3
		- src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#3
		- src/rules/operation/abstract/RuleConditionalTransferOperator.sol#3
		- src/rules/validation/RuleBlacklist.sol#3
		- src/rules/validation/RuleSanctionList.sol#3
		- src/rules/validation/RuleWhitelist.sol#3
		- src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#3
		- src/rules/validation/abstract/RuleAddressList/RuleAddressListInternal.sol#3
		- src/rules/validation/abstract/RuleAddressList/RuleAddressListInvariantStorage.sol#3
		- src/rules/validation/abstract/RuleAddressList/RuleBlacklistInvariantStorage.sol#3
		- src/rules/validation/abstract/RuleAddressList/RuleWhitelistInvariantStorage.sol#3
		- src/rules/validation/abstract/RuleCommonInvariantStorage.sol#2
		- src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#3
		- src/rules/validation/abstract/RuleValidateTransfer.sol#3

## dead-code

> - Implemented to be gasless compatible (see MetaTxModule)
>
> - If we remove this function, we will have the following error:
>
>   "Derived contract must override function "_msgData". Two or more base classes define function with same name and parameter types."

Impact: Informational
Confidence: Medium
 - [ ] ID-17
[RuleSanctionList._msgData()](src/rules/validation/RuleSanctionList.sol#L108-L115) is never used and should be removed

src/rules/validation/RuleSanctionList.sol#L108-L115


 - [ ] ID-18
[RuleAddressList._msgData()](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L118-L125) is never used and should be removed

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L118-L125


 - [ ] ID-19
[RuleConditionalTransfer._msgData()](src/rules/operation/RuleConditionalTransfer.sol#L268-L275) is never used and should be removed

src/rules/operation/RuleConditionalTransfer.sol#L268-L275


 - [ ] ID-20
[RuleEngine._msgData()](src/RuleEngine.sol#L140-L147) is never used and should be removed

src/RuleEngine.sol#L140-L147

## solc-version

> The version set in the config file is 0.8.22

Impact: Informational
Confidence: High

 - [ ] ID-21
Version constraint ^0.8.0 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess
	- AbiReencodingHeadOverflowWithStaticArrayCleanup
	- DirtyBytesArrayToStorage
	- DataLocationChangeInInternalOverride
	- NestedCalldataArrayAbiReencodingSizeValidation
	- SignedImmutables
	- ABIDecodeTwoDimensionalArrayMemory
	- KeccakCaching.
 It is used by:
	- lib/CMTAT/contracts/interfaces/draft-IERC1404/draft-IERC1404.sol#3
	- lib/CMTAT/contracts/interfaces/draft-IERC1404/draft-IERC1404EnumCode.sol#3
	- lib/CMTAT/contracts/interfaces/draft-IERC1404/draft-IERC1404Wrapper.sol#3
	- lib/CMTAT/contracts/interfaces/engine/IRuleEngine.sol#3

 - [ ] ID-22
	Version constraint ^0.8.20 contains known severe issues (https://solidity.readthedocs.io/en/latest/bugs.html)
	- VerbatimInvalidDeduplication
	- FullInlinerNonExpressionSplitArgumentEvaluationOrder
	- MissingSideEffectsOnSelectorAccess.
	 It is used by:
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
	- src/modules/RuleInternal.sol#3
	- src/rules/operation/RuleConditionalTransfer.sol#3
	- src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#3
	- src/rules/operation/abstract/RuleConditionalTransferOperator.sol#3
	- src/rules/validation/RuleBlacklist.sol#3
	- src/rules/validation/RuleSanctionList.sol#3
	- src/rules/validation/RuleWhitelist.sol#3
	- src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#3
	- src/rules/validation/abstract/RuleAddressList/RuleAddressListInternal.sol#3
	- src/rules/validation/abstract/RuleAddressList/RuleAddressListInvariantStorage.sol#3
	- src/rules/validation/abstract/RuleAddressList/RuleBlacklistInvariantStorage.sol#3
	- src/rules/validation/abstract/RuleAddressList/RuleWhitelistInvariantStorage.sol#3
	- src/rules/validation/abstract/RuleCommonInvariantStorage.sol#2
	- src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#3
	- src/rules/validation/abstract/RuleValidateTransfer.sol#3

## naming-convention

> It is not really necessary to rename all the variables. It will generate a lot of work for a minor improvement.

Impact: Informational
Confidence: High
 - [ ] ID-23
Event [RuleConditionalTransferInvariantStorage.transferDenied(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L73) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L73


 - [ ] ID-24
Parameter [RuleConditionalTransfer.operateOnTransfer(address,address,uint256)._amount](src/rules/operation/RuleConditionalTransfer.sol#L150) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L150


 - [ ] ID-25
Parameter [RuleValidateTransfer.validateTransfer(address,address,uint256)._from](src/rules/validation/abstract/RuleValidateTransfer.sol#L16) is not in mixedCase

src/rules/validation/abstract/RuleValidateTransfer.sol#L16


 - [ ] ID-26
Parameter [RuleEngine.detectTransferRestriction(address,address,uint256)._amount](src/RuleEngine.sol#L47) is not in mixedCase

src/RuleEngine.sol#L47


 - [ ] ID-27
Event [RuleConditionalTransferInvariantStorage.transferReset(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L74) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L74


 - [ ] ID-28
Parameter [RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)._amount](src/modules/RuleEngineValidation.sol#L146) is not in mixedCase

src/modules/RuleEngineValidation.sol#L146


 - [ ] ID-29
Parameter [RuleBlacklist.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/validation/RuleBlacklist.sol#L49) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L49


 - [ ] ID-30
Variable [RuleConditionalTransferOperator.IdToKey](src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L22) is not in mixedCase

src/rules/operation/abstract/RuleConditionalTransferOperator.sol#L22


 - [ ] ID-31
Parameter [RuleSanctionList.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleSanctionList.sol#L50) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L50


 - [ ] ID-32
Parameter [RuleBlacklist.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleBlacklist.sol#L31) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L31


 - [ ] ID-33
Parameter [RuleEngine.detectTransferRestriction(address,address,uint256)._to](src/RuleEngine.sol#L46) is not in mixedCase

src/RuleEngine.sol#L46


 - [ ] ID-34
Parameter [RuleConditionalTransfer.detectTransferRestriction(address,address,uint256)._amount](src/rules/operation/RuleConditionalTransfer.sol#L174) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L174


 - [ ] ID-35
Parameter [RuleConditionalTransfer.getRequestByStatus(RuleConditionalTransferInvariantStorage.STATUS)._targetStatus](src/rules/operation/RuleConditionalTransfer.sol#L116) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L116


 - [ ] ID-36
Parameter [RuleEngine.detectTransferRestriction(address,address,uint256)._from](src/RuleEngine.sol#L45) is not in mixedCase

src/RuleEngine.sol#L45


 - [ ] ID-37
Parameter [RuleConditionalTransfer.operateOnTransfer(address,address,uint256)._from](src/rules/operation/RuleConditionalTransfer.sol#L148) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L148


 - [ ] ID-38
Parameter [RuleBlacklist.messageForTransferRestriction(uint8)._restrictionCode](src/rules/validation/RuleBlacklist.sol#L62) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L62


 - [ ] ID-39
Parameter [RuleEngine.messageForTransferRestriction(uint8)._restrictionCode](src/RuleEngine.sol#L92) is not in mixedCase

src/RuleEngine.sol#L92


 - [ ] ID-40
Parameter [RuleAddressList.removeAddressFromTheList(address)._removeWhitelistAddress](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L75) is not in mixedCase

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L75


 - [ ] ID-41
Parameter [RuleSanctionList.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/validation/RuleSanctionList.sol#L69) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L69


 - [ ] ID-42
Parameter [RuleAddressList.addressIsListed(address)._targetAddress](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L97) is not in mixedCase

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L97


 - [ ] ID-43
Parameter [RuleWhitelist.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/validation/RuleWhitelist.sol#L49) is not in mixedCase

src/rules/validation/RuleWhitelist.sol#L49


 - [ ] ID-44
Parameter [RuleEngineValidation.validateTransferValidation(address,address,uint256)._to](src/modules/RuleEngineValidation.sol#L172) is not in mixedCase

src/modules/RuleEngineValidation.sol#L172


 - [ ] ID-45
Event [RuleConditionalTransferInvariantStorage.transferWaiting(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L71) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L71


 - [ ] ID-46
Struct [RuleConditionalTransferInvariantStorage.TIME_LIMIT](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L18-L21) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L18-L21


 - [ ] ID-47
Parameter [RuleConditionalTransfer.canReturnTransferRestrictionCode(uint8)._restrictionCode](src/rules/operation/RuleConditionalTransfer.sol#L191) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L191


 - [ ] ID-48
Parameter [RuleEngine.validateTransfer(address,address,uint256)._amount](src/RuleEngine.sol#L81) is not in mixedCase

src/RuleEngine.sol#L81


 - [ ] ID-49
Struct [RuleConditionalTransferInvariantStorage.AUTOMATIC_APPROVAL](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L23-L26) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L23-L26


 - [ ] ID-50
Parameter [RuleEngineValidation.validateTransferValidation(address,address,uint256)._from](src/modules/RuleEngineValidation.sol#L171) is not in mixedCase

src/modules/RuleEngineValidation.sol#L171


 - [ ] ID-51
Parameter [RuleSanctionList.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleSanctionList.sol#L49) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L49


 - [ ] ID-52
Parameter [RuleConditionalTransfer.detectTransferRestriction(address,address,uint256)._to](src/rules/operation/RuleConditionalTransfer.sol#L173) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L173


 - [ ] ID-53
Parameter [RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)._from](src/modules/RuleEngineValidation.sol#L144) is not in mixedCase

src/modules/RuleEngineValidation.sol#L144


 - [ ] ID-54
Parameter [RuleEngineValidation.validateTransferValidation(address,address,uint256)._amount](src/modules/RuleEngineValidation.sol#L173) is not in mixedCase

src/modules/RuleEngineValidation.sol#L173


 - [ ] ID-55
Parameter [RuleWhitelist.detectTransferRestriction(address,address,uint256)._to](src/rules/validation/RuleWhitelist.sol#L31) is not in mixedCase

src/rules/validation/RuleWhitelist.sol#L31


 - [ ] ID-56
Parameter [RuleWhitelist.messageForTransferRestriction(uint8)._restrictionCode](src/rules/validation/RuleWhitelist.sol#L62) is not in mixedCase

src/rules/validation/RuleWhitelist.sol#L62


 - [ ] ID-57
Struct [RuleConditionalTransferInvariantStorage.AUTOMATIC_TRANSFER](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L9-L12) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L9-L12


 - [ ] ID-58
Parameter [RuleValidateTransfer.validateTransfer(address,address,uint256)._to](src/rules/validation/abstract/RuleValidateTransfer.sol#L17) is not in mixedCase

src/rules/validation/abstract/RuleValidateTransfer.sol#L17


 - [ ] ID-59
Parameter [RuleInternal.getRuleIndex(address[],address)._rules](src/modules/RuleInternal.sol#L90) is not in mixedCase

src/modules/RuleInternal.sol#L90


 - [ ] ID-60
Parameter [RuleAddressList.addAddressToTheList(address)._newWhitelistAddress](src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L63) is not in mixedCase

src/rules/validation/abstract/RuleAddressList/RuleAddressList.sol#L63


 - [ ] ID-61
Event [RuleConditionalTransferInvariantStorage.transferProcessed(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L70) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L70


 - [ ] ID-62
Parameter [RuleWhitelist.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleWhitelist.sol#L30) is not in mixedCase

src/rules/validation/RuleWhitelist.sol#L30


 - [ ] ID-63
Parameter [RuleValidateTransfer.validateTransfer(address,address,uint256)._amount](src/rules/validation/abstract/RuleValidateTransfer.sol#L18) is not in mixedCase

src/rules/validation/abstract/RuleValidateTransfer.sol#L18


 - [ ] ID-64
Parameter [RuleEngine.validateTransfer(address,address,uint256)._from](src/RuleEngine.sol#L79) is not in mixedCase

src/RuleEngine.sol#L79


 - [ ] ID-65
Parameter [RuleConditionalTransfer.operateOnTransfer(address,address,uint256)._to](src/rules/operation/RuleConditionalTransfer.sol#L149) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L149


 - [ ] ID-66
Parameter [RuleConditionalTransfer.detectTransferRestriction(address,address,uint256)._from](src/rules/operation/RuleConditionalTransfer.sol#L172) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L172


 - [ ] ID-67
Parameter [RuleEngineValidation.detectTransferRestrictionValidation(address,address,uint256)._to](src/modules/RuleEngineValidation.sol#L145) is not in mixedCase

src/modules/RuleEngineValidation.sol#L145


 - [ ] ID-68
Parameter [RuleBlacklist.detectTransferRestriction(address,address,uint256)._from](src/rules/validation/RuleBlacklist.sol#L30) is not in mixedCase

src/rules/validation/RuleBlacklist.sol#L30


 - [ ] ID-69
Parameter [RuleConditionalTransfer.messageForTransferRestriction(uint8)._restrictionCode](src/rules/operation/RuleConditionalTransfer.sol#L203) is not in mixedCase

src/rules/operation/RuleConditionalTransfer.sol#L203


 - [ ] ID-70
Parameter [RuleSanctionList.messageForTransferRestriction(uint8)._restrictionCode](src/rules/validation/RuleSanctionList.sol#L82) is not in mixedCase

src/rules/validation/RuleSanctionList.sol#L82


 - [ ] ID-71
Parameter [RuleEngine.validateTransfer(address,address,uint256)._to](src/RuleEngine.sol#L80) is not in mixedCase

src/RuleEngine.sol#L80


 - [ ] ID-72
Event [RuleConditionalTransferInvariantStorage.transferApproved(bytes32,address,address,uint256,uint256)](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L72) is not in CapWords

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L72


## similar-names
Impact: Informational
Confidence: Medium
 - [ ] ID-73
Variable [RuleSanctionlistInvariantStorage.CODE_ADDRESS_FROM_IS_SANCTIONED](src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#L23) is too similar to [RuleSanctionlistInvariantStorage.TEXT_ADDRESS_FROM_IS_SANCTIONED](src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#L15-L16)

src/rules/validation/abstract/RuleSanctionListInvariantStorage.sol#L23


 - [ ] ID-74
Variable [RuleConditionalTransferInvariantStorage.CODE_TRANSFER_REQUEST_NOT_APPROVED](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L56) is too similar to [RuleConditionalTransferInvariantStorage.TEXT_TRANSFER_REQUEST_NOT_APPROVED](src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L52-L53)

src/rules/operation/abstract/RuleConditionalTransferInvariantStorage.sol#L56


 - [ ] ID-75
Variable [RuleBlacklistInvariantStorage.CODE_ADDRESS_FROM_IS_BLACKLISTED](src/rules/validation/abstract/RuleAddressList/RuleBlacklistInvariantStorage.sol#L16) is too similar to [RuleBlacklistInvariantStorage.TEXT_ADDRESS_FROM_IS_BLACKLISTED](src/rules/validation/abstract/RuleAddressList/RuleBlacklistInvariantStorage.sol#L9-L10)

src/rules/validation/abstract/RuleAddressList/RuleBlacklistInvariantStorage.sol#L16


 - [ ] ID-76
Variable [RuleWhitelistInvariantStorage.CODE_ADDRESS_TO_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/RuleWhitelistInvariantStorage.sol#L17) is too similar to [RuleWhitelistInvariantStorage.TEXT_ADDRESS_TO_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/RuleWhitelistInvariantStorage.sol#L11-L12)

src/rules/validation/abstract/RuleAddressList/RuleWhitelistInvariantStorage.sol#L17


 - [ ] ID-77
Variable [RuleWhitelistInvariantStorage.CODE_ADDRESS_FROM_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/RuleWhitelistInvariantStorage.sol#L16) is too similar to [RuleWhitelistInvariantStorage.TEXT_ADDRESS_FROM_NOT_WHITELISTED](src/rules/validation/abstract/RuleAddressList/RuleWhitelistInvariantStorage.sol#L9-L10)

src/rules/validation/abstract/RuleAddressList/RuleWhitelistInvariantStorage.sol#L16

## unused-import

> Concerns an external library

Impact: Informational
Confidence: High
 - [ ] ID-78
	The following unused import(s) in lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol should be removed: 
	-import {IERC20Permit} from "../extensions/IERC20Permit.sol"; (lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol#7)

## var-read-using-this

>   It does not work without the this keyword "Undeclared identifier"

Impact: Optimization
Confidence: High
 - [ ] ID-79
The function [RuleValidateTransfer.validateTransfer(address,address,uint256)](src/rules/validation/abstract/RuleValidateTransfer.sol#L15-L24) reads [this.detectTransferRestriction(_from,_to,_amount) == uint8(REJECTED_CODE_BASE.TRANSFER_OK)](src/rules/validation/abstract/RuleValidateTransfer.sol#L21-L23) with `this` which adds an extra STATICCALL.

src/rules/validation/abstract/RuleValidateTransfer.sol#L15-L24

