// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;


interface ISabiler {
    function getSablierAmount(address _user) external returns(uint256[]memory);
    function gettotalamount(address _user)external returns(uint256);
}
