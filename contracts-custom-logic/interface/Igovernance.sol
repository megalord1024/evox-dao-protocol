// SPDX-License-Identifier: MIT 
pragma solidity  ^0.8.19;


interface IGovernance {
    

// for locking the deposited funds in the contract while proposal is underway
function lock(address _user) external returns (bool);
// for locking the deposited funds in the contract after proposal is Done 
function unlock(address _user) external returns (bool);

function addmoderator( address _moderator) external ;
// 
function getuserRemainingDepositedAmount(address _user) external view returns(uint256);

function getUserdepositAmount(address _user) external view returns(uint256);

}