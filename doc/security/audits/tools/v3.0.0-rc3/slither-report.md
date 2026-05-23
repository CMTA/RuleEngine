**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [calls-loop](#calls-loop) (10 results) (Low)
 - [unindexed-event-address](#unindexed-event-address) (3 results) (Informational)
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
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L149-L158) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L152)
	Calls stack containing the loop:
		RuleEngineBase.canTransfer(address,address,uint256)
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L149-L158


 - [ ] ID-4
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L182-L190) has external calls inside a loop: [IRule(rule(i)).messageForTransferRestriction(restrictionCode)](src/RuleEngineBase.sol#L186)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L182-L190


 - [ ] ID-5
[RuleEngineBase._messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L182-L190) has external calls inside a loop: [IRule(rule(i)).canReturnTransferRestrictionCode(restrictionCode)](src/RuleEngineBase.sol#L185)
	Calls stack containing the loop:
		RuleEngineBase.messageForTransferRestriction(uint8)

src/RuleEngineBase.sol#L182-L190


 - [ ] ID-6
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L160-L174) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L168)
	Calls stack containing the loop:
		RuleEngineBase.canTransferFrom(address,address,address,uint256)
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L160-L174


 - [ ] ID-7
[RulesManagementModule._transferred(address,address,uint256)](src/modules/RulesManagementModule.sol#L201-L206) has external calls inside a loop: [IRule(_rules.at(i)).transferred(from,to,value)](src/modules/RulesManagementModule.sol#L204)
	Calls stack containing the loop:
		RuleEngineBase.created(address,uint256)

src/modules/RulesManagementModule.sol#L201-L206


 - [ ] ID-8
[RuleEngineBase._detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L149-L158) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L152)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestriction(address,address,uint256)

src/RuleEngineBase.sol#L149-L158


 - [ ] ID-9
[RuleEngineBase._detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L160-L174) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L168)
	Calls stack containing the loop:
		RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)

src/RuleEngineBase.sol#L160-L174


## unindexed-event-address
Impact: Informational
Confidence: High
 - [ ] ID-10
Event [IERC3643Compliance.TokenBound(address)](src/interfaces/IERC3643Compliance.sol#L14) has address parameters but no indexed parameters

src/interfaces/IERC3643Compliance.sol#L14


 - [ ] ID-11
Event [IERC3643ComplianceExtended.TokenSelfBindingApprovalSet(address,bool)](src/interfaces/IERC3643ComplianceExtended.sol#L13) has address parameters but no indexed parameters

src/interfaces/IERC3643ComplianceExtended.sol#L13


 - [ ] ID-12
Event [IERC3643Compliance.TokenUnbound(address)](src/interfaces/IERC3643Compliance.sol#L20) has address parameters but no indexed parameters

src/interfaces/IERC3643Compliance.sol#L20


