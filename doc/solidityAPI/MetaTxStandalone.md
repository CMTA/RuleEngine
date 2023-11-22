# MetaTxModuleStandalone

[TOC]

_Meta transaction (gasless) module._

### constructor

```solidity
constructor(address trustedForwarder) internal
```

### _msgSender

```solidity
function _msgSender() internal view virtual returns (address sender)
```

_Override for `msg.sender`. Defaults to the original `msg.sender` whenever
a call is not performed by the trusted forwarder or the calldata length is less than
20 bytes (an address length)._

### _msgData

```solidity
function _msgData() internal view virtual returns (bytes)
```

_Override for `msg.data`. Defaults to the original `msg.data` whenever
a call is not performed by the trusted forwarder or the calldata length is less than
20 bytes (an address length)._
