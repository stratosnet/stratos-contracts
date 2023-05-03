// SPDX-License-Identifier: MIT
// Stratonet Contracts (last updated v1.1.0) (gov/interfaces/ISdsRouter.sol)

interface ISdsRouter {
    function fileUpload(
        bytes calldata fileHash,
        bytes memory _reporter,
        bytes memory _uploader
    ) external;

    function prepay(bytes memory _beneficiary, uint256 amount) external;
}
