// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;


interface ISabiler {

    function getWithdrawnAmount(uint256 streamId) external view returns (uint128);
    function getRemainingDepositedAmount(uint256 streamId) external view returns (uint128);
}
