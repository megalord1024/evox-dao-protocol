// SPDX-License-Identifier: MIT 
pragma solidity  ^0.8.19;


interface IProposal {
    
function getlastProposalVoteTime(address _user)external view returns(uint256);


}