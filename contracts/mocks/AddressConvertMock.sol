// SPDX-License-Identifier: MIT
// Stratonet Contracts (last updated v1.0.0) (mocks/AddressConvertMock.sol)

pragma solidity ^0.8.0;

import "../utils/Bech32.sol";

contract AddressConvertMock {
    using Bech32 for address;
    using Bech32 for string;
    using Bech32 for bytes;

    string public DEFAULT_PREFIX;

    constructor(string memory prefix_) {
        DEFAULT_PREFIX = prefix_;
    }

    function decode(
        bytes memory bechStr,
        uint32 enc
    ) external pure returns (bytes memory, uint8[] memory) {
        return bechStr.decode(enc);
    }

    function convertFromAddressToBech32(
        address addr
    ) external view returns (string memory) {
        return addr.toBech32(DEFAULT_PREFIX);
    }

    function convertFromDataToBech32(
        bytes memory data
    ) external view returns (string memory) {
        return data.toBech32(DEFAULT_PREFIX);
    }

    function convertFromAddressToBech32(
        string calldata prefix,
        address addr
    ) external pure returns (string memory) {
        return addr.toBech32(prefix);
    }

    function convertFromDataToBech32(
        string calldata prefix,
        bytes memory data
    ) external pure returns (string memory) {
        return data.toBech32(prefix);
    }

    function convertFromAddressToBech32(
        string calldata prefix,
        uint8 version,
        address addr
    ) external pure returns (string memory) {
        return addr.toBech32(prefix, version);
    }

    function convertFromDataToBech32(
        string calldata prefix,
        uint8 version,
        bytes memory data
    ) external pure returns (string memory) {
        return data.toBech32(prefix, version);
    }

    function convertFromBech32ToAddress(
        string calldata bechAddr
    ) external view returns (address) {
        return bechAddr.fromBech32(DEFAULT_PREFIX);
    }

    function convertFromBech32ToAddress(
        string calldata prefix,
        string calldata bechAddr
    ) external pure returns (address) {
        return bechAddr.fromBech32(prefix);
    }

    function convertFromBech32ToData(
        string calldata prefix,
        string calldata bechAddr,
        uint32 enc
    ) external pure returns (uint8, bytes memory) {
        return bechAddr.fromBech32WithVersion(prefix, enc);
    }
}
