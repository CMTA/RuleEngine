# Rule - Code list

> It is very important that each rule uses an unique code

Here the list of codes used by the different rules

| Contract                | Constant name                      | Value |
| ----------------------- | ---------------------------------- | ----- |
| All                     | TRANSFER_OK (from CMTAT)           | 0     |
| RuleWhitelist           | CODE_ADDRESS_FROM_NOT_WHITELISTED  | 21    |
| RuleWhitelist           | CODE_ADDRESS_TO_NOT_WHITELISTED    | 22    |
| RuleSanctionList        | CODE_ADDRESS_FROM_IS_SANCTIONED    | 31    |
| RuleSanctionList        | CODE_ADDRESS_TO_IS_SANCTIONED      | 32    |
| RuleBlacklist           | CODE_ADDRESS_FROM_IS_BLACKLISTED   | 41    |
| RuleBlacklist           | CODE_ADDRESS_TO_IS_BLACKLISTED     | 42    |
| RuleConditionalTransfer | CODE_TRANSFER_REQUEST_NOT_APPROVED | 51    |



Warning: the CMTAT already uses the code 0-4 and the code 5-9 should be left free to allow further additions in the CMTAT
