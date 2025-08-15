**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [calls-loop](#calls-loop) (4 results) (Low)
 - [dead-code](#dead-code) (1 results) (Informational)
## calls-loop

> Acknowledge
> Rule contracts are considered as trusted

Impact: Low
Confidence: Medium
 - [ ] ID-0
[RuleEngineBase.detectTransferRestriction(address,address,uint256)](src/RuleEngineBase.sol#L76-L90) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestriction(from,to,value)](src/RuleEngineBase.sol#L83-L84)

src/RuleEngineBase.sol#L76-L90


 - [ ] ID-1
[RuleEngineBase.messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L116-L132) has external calls inside a loop: [IRule(rule(i)).canReturnTransferRestrictionCode(restrictionCode)](src/RuleEngineBase.sol#L123-L124)

src/RuleEngineBase.sol#L116-L132


 - [ ] ID-2
[RuleEngineBase.messageForTransferRestriction(uint8)](src/RuleEngineBase.sol#L116-L132) has external calls inside a loop: [IRule(rule(i)).messageForTransferRestriction(restrictionCode)](src/RuleEngineBase.sol#L126-L128)

src/RuleEngineBase.sol#L116-L132


 - [ ] ID-3
[RuleEngineBase.detectTransferRestrictionFrom(address,address,address,uint256)](src/RuleEngineBase.sol#L95-L111) has external calls inside a loop: [restriction = IRule(rule(i)).detectTransferRestrictionFrom(spender,from,to,value)](src/RuleEngineBase.sol#L103-L104)

src/RuleEngineBase.sol#L95-L111

## dead-code

> - Implemented to be gasless compatible (see MetaTxModule)
>
> - If we remove this function, we will have the following error:
>
>   "Derived contract must override function "_msgData". Two or more base classes define function with same name and parameter types."

Impact: Informational
Confidence: Medium
 - [ ] ID-4
[RuleEngine._msgData()](src/RuleEngine.sol#L56-L64) is never used and should be removed

src/RuleEngine.sol#L56-L64

