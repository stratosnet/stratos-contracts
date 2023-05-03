// SPDX-License-Identifier: MIT
// Stratonet Contracts (last updated v1.0.0) (utils/CosmosLib.sol)

pragma solidity ^0.8.0;

import "./BytesLib.sol";

library CosmosLib {
    using BytesLib for bytes;

    function toModuleAddress(
        string memory moduleName
    ) internal pure returns (address) {
        return toModuleAddress(bytes(moduleName));
    }

    function toModuleAddress(
        bytes memory moduleName
    ) internal pure returns (address) {
        bytes memory hash_ = abi.encodePacked(sha256(moduleName));
        return address(bytes20(hash_.slice(0, 20)));
    }
}
