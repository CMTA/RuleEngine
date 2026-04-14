**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [calls-loop](#calls-loop) (10 results) (Low)
 - [unindexed-event-address](#unindexed-event-address) (2 results) (Informational)
## calls-loop
Impact: Low
Confidence: Medium
 - [ ] ID-0
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L176-L184) has external calls inside a loop: [IRule(rule(i)).canReturnTransferRestrictionCode(restrictionCode)](src/RuleEngineBase.sol#L179)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L176-L184


 - [ ] ID-1
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L154-L168) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L162)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L154-L168


 - [ ] ID-2
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L176-L184) has external calls inside a loop: [IRule(rule(i)).messageForTransferRestriction(restrictionCode)](src/RuleEngineBase.sol#L180)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L176-L184


 - [ ] ID-3
[RulesManagementModule._transferred(address,address,address,uint256)](src/modules/RulesManagementModule.sol#L192-L197) has external calls inside a loop: [IRule(_rules.at(i)).transferred(spender,from,to,value)](src/modules/RulesManagementModule.sol#L195)
	Calls stack containing the loop:
		RuleEngineBase.transferred(address,address,address,uint256)

src/modules/RulesManagementModule.sol#L192-L197


 - [ ] ID-4
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L154-L168) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L162)
	Calls stack containing the loop:
		RuleEngineBase.canTransferFrom(address,address,address,uint256)
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L154-L168


 - [ ] ID-5
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L143-L152) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L146)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L143-L152


 - [ ] ID-6
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L173-L178) has external calls inside a loop: [IRule(_rules.at(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L176)
	Calls stack containing the loop:
		RuleEngineBase.created(address,uint256)

src/modules/RulesManagementModule.sol#L173-L178


 - [ ] ID-7
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L143-L152) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L146)
	Calls stack containing the loop:
		RuleEngineBase.canTransfer(address,address,uint256)
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L143-L152


 - [ ] ID-8
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L173-L178) has external calls inside a loop: [IRule(_rules.at(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L176)
	Calls stack containing the loop:
		RuleEngineBase.transferred(address,address,uint256)

src/modules/RulesManagementModule.sol#L173-L178


 - [ ] ID-9
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L173-L178) has external calls inside a loop: [IRule(_rules.at(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L176)
	Calls stack containing the loop:
		RuleEngineBase.destroyed(address,uint256)

src/modules/RulesManagementModule.sol#L173-L178


## unindexed-event-address
Impact: Informational
Confidence: High
 - [ ] ID-10
Event [IERC3643Compliance.TokenBound(address)](src/interfaces/IERC3643Compliance.sol#L14) has address parameters but no indexed parameters

src/interfaces/IERC3643Compliance.sol#L14


 - [ ] ID-11
Event [IERC3643Compliance.TokenUnbound(address)](src/interfaces/IERC3643Compliance.sol#L20) has address parameters but no indexed parameters

src/interfaces/IERC3643Compliance.sol#L20


