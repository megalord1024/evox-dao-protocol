// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

interface IStaking {

    function getUserdepositAmount(address _user) external view returns(uint256);
}