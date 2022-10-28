# Technical choice

## Access Control
whitelist 
The default admin is the Deployer/issuer, it is set 
RuleENgine
The default admin is the Deployer/issuer, it is set in the constructor
Here a schema of the Access Control.

## Upgradable
The Rule Engine and the whitelist are not upgradeable. The reason is the following.

If we need a new on, we just issue a new one, and tell the token to use the new. This would happen if we need more than just whitelisting, for ex.
 
## Urgency mechanism
    a) Should it be possible to hold in pause the contract (pause / unpause) ?
    b) Should it be possible to destroy the contract bytecode (self destruct) ?

a) Let's maybe have a function clearRules() to remove all the whitelisted addresses.

b) Is it possible to use the generic kill()?

##Whitelist
 
###Add/remove addresses
To add /emove on address
* addAddress(address)
* removeAddress(address)
To add/remove several addresses
* addAddresses(addresses[])
* removeAddresses(addresses[])
### Null address
The possibility to add the null address (0x0) to the whitelist is not really a security problem because OpenZeppelin doesn't autorize the transfer of tokens to the zero address.

**addAddress**
If the aprameter is the null address, the transaction is reverted.
**addAddresses**
If one address is the null adress, the transaction is reveerted
With the array list, the gas cost will improve because we have to make a check for each iteration
**removeAddress**
No check because it is not a problem if we remove the null address from the whitelist.
**removeAddresses**
No check because it is not a problem if we remove the null address from the whitelist.

### Duplicate address

**addAddress**
If the address already exists, the transaction is reverted to save gas.
**addAddresses**
We do not perform check on duplicate, because it will cost more gas to check for each address. 
###NonExistentAddress
**removeAddress**
If the address does not exist, the transaction is reverted to save gas.
**removeAddresses**
We do not if the address is in the whitelist or not, because it will cost more gas to check for each address. 

