// SPDX-License-Identifier: MIT 
pragma solidity  ^0.8.19;


interface IGovernance {
    

function lock(address _user) external returns (bool);
function unlock(address _user) external returns (bool);

}