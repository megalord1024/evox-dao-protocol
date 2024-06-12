// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

interface IEvoxStaking {

    function getUserdepositAmount(address _user) external view returns(uint256);
}