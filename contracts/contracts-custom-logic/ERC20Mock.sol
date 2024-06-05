// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(
    ) ERC20("XToken", "XTK") {}

    function mint(address _account, uint256 _amount) external {
        _mint(_account, _amount);
    }
}