**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [calls-loop](#calls-loop) (10 results) (Low)
 - [dead-code](#dead-code) (1 results) (Informational)
 - [naming-convention](#naming-convention) (1 results) (Informational)
 - [unindexed-event-address](#unindexed-event-address) (2 results) (Informational)
## calls-loop
Impact: Low
Confidence: Medium
 - [ ] ID-0
[RulesManagementModule._transferred(address,address,address,uint256)](src/modules/RulesManagementModule.sol#L220-L225) has external calls inside a loop: [IRule(_rules.at(i)).transferred(spender,from,to,value)](src/modules/RulesManagementModule.sol#L223)
	Calls stack containing the loop:
		RuleEngineBase.transferred(address,address,address,uint256)

src/modules/RulesManagementModule.sol#L220-L225


 - [ ] ID-1
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L201-L206) has external calls inside a loop: [IRule(_rules.at(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L204)
	Calls stack containing the loop:
		RuleEngineBase.destroyed(address,uint256)

src/modules/RulesManagementModule.sol#L201-L206


 - [ ] ID-2
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L201-L206) has external calls inside a loop: [IRule(_rules.at(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L204)
	Calls stack containing the loop:
		RuleEngineBase.transferred(address,address,uint256)

src/modules/RulesManagementModule.sol#L201-L206


 - [ ] ID-3
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L181-L189) has external calls inside a loop: [IRule(rule(i)).messageForTransferRestriction(restrictionCode)](src/RuleEngineBase.sol#L185)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L181-L189


 - [ ] ID-4
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L201-L206) has external calls inside a loop: [IRule(_rules.at(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L204)
	Calls stack containing the loop:
		RuleEngineBase.created(address,uint256)

src/modules/RulesManagementModule.sol#L201-L206


 - [ ] ID-5
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L159-L173) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L167)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L159-L173


 - [ ] ID-6
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L181-L189) has external calls inside a loop: [IRule(rule(i)).canReturnTransferRestrictionCode(restrictionCode)](src/RuleEngineBase.sol#L184)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L181-L189


 - [ ] ID-7
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L148-L157) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L151)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L148-L157


 - [ ] ID-8
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L148-L157) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L151)
	Calls stack containing the loop:
		RuleEngineBase.canTransfer(address,address,uint256)
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L148-L157


 - [ ] ID-9
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L159-L173) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L167)
	Calls stack containing the loop:
		RuleEngineBase.canTransferFrom(address,address,address,uint256)
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L159-L173


## dead-code
Impact: Informational
Confidence: Medium
 - [ ] ID-10
[RuleEngineOwnable2Step._msgData()](src/deployment/RuleEngineOwnable2Step.sol#L56-L58) is never used and should be removed

src/deployment/RuleEngineOwnable2Step.sol#L56-L58


## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-11
Enum [IERC1404Extend.REJECTED_CODE_BASE](lib/CMTAT/contracts/interfaces/tokenization/draft-IERC1404.sol#L49-L57) is not in CapWords

lib/CMTAT/contracts/interfaces/tokenization/draft-IERC1404.sol#L49-L57


## unindexed-event-address
Impact: Informational
Confidence: High
 - [ ] ID-12
Event [IERC3643Compliance.TokenBound(address)](src/interfaces/IERC3643Compliance.sol#L14) has address parameters but no indexed parameters

src/interfaces/IERC3643Compliance.sol#L14


 - [ ] ID-13
Event [IERC3643Compliance.TokenUnbound(address)](src/interfaces/IERC3643Compliance.sol#L20) has address parameters but no indexed parameters

src/interfaces/IERC3643Compliance.sol#L20


