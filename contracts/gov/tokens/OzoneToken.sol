// SPDX-License-Identifier: MIT
// Stratonet Contracts (last updated v1.1.0) (gov/tokens/OzoneToken.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OzoneToken is ERC20 {
    constructor() ERC20("Ozone", "OZ") {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
