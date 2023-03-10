# Stratos contracts

**A library for stratos, tendermint and cosmos smart contract development.**

 * Implementations of libraries like [Bech32](https://en.bitcoin.it/wiki/Bech32).


## Overview

### Installation

```
$ yarn add -D @stratosnet/contracts
```


### Usage

Once installed, you can use the contracts in the library by importing them:

```solidity
pragma solidity ^0.8.0;

import "@stratosnet/contracts/utils/Bech32.sol";

contract MyStratosAddress {
    using Bech32 for address;

    function getStratosAddress() public view returns (string memory) {
        return msg.sender.toBech32("st");
    }
}
```

## License

OpenZeppelin Contracts is released under the [MIT License](LICENSE).
