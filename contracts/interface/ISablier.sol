// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;


interface ISabiler {
    function calculateFinalvotingPower(address _user) external view returns(uint256);
    function gettotalamount(address _user)external view returns(uint256);
    function calculateFinalVotes() external returns (uint256, uint256);
    function handleOverflowVotes(address _user) external ;
}
