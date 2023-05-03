// SPDX-License-Identifier: MIT
// Stratonet Contracts (last updated v1.1.0) (gov/SdsRouter.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./versions/Version1.sol";
import "./interfaces/ISdsRouter.sol";

import "../utils/Bech32.sol";

contract SdsRouter is Version1, OwnableUpgradeable, ISdsRouter {
    using Bech32 for bytes;
    using Bech32 for address;
    using SafeERC20 for IERC20;

    struct FileInfo {
        uint256 height;
        string uploader;
    }

    mapping(bytes => FileInfo) public fileInfos;
    IERC20 public prepayToken;

    // ----- proxy ------
    uint256[49] private __gap;

    // ===== fallbacks =====

    receive() external payable {}

    // Initialize function for proxy constructor. Must be used atomically
    function initialize(IERC20 prepayToken_) public initializer {
        prepayToken = prepayToken_;

        // proxy inits
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function fileUpload(
        bytes calldata fileHash,
        bytes memory _reporter,
        bytes memory _uploader
    ) external override {
        string memory reporter = _reporter.toBech32("stsds");
        string memory sender = _msgSender().toBech32("cosmos");
        string memory uploader = _uploader.toBech32("cosmos");

        // TODO: Add metanode registration check
        FileInfo storage fInfo = fileInfos[fileHash];
        fInfo.height = block.number;
        fInfo.uploader = uploader;
        // TODO: Add bitmap logic for geting index from reporters
    }

    function prepay(
        bytes memory _beneficiary,
        uint256 amount
    ) external override {
        require(amount != 0, "SDS: ZERO_AMOUNT");
        string memory sender = _msgSender().toBech32("cosmos");
        string memory beneficiary = _beneficiary.toBech32("cosmos");
    }
}
