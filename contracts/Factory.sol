// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;


import "./Proposal.sol";
// import "./ProposalManager.sol";

Contract DaoFactory {



    // A proposal with `newCurator == false` represents a transaction
    // to be issued by this DAO
    // A proposal with `newCurator == true` represents a DAO split
    struct Proposal {
        // The address where the `amount` will go to if the proposal is accepted
        address recipient;
        // The amount to transfer to `recipient` if the proposal is accepted.
        uint amount;
        // A plain text description of the proposal
        string description;
        // A unix timestamp, denoting the end of the voting period
        uint votingDeadline;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool open;
        // True the votes have been counted, and
        // the majority said yes
        bool proposalPassed;
        // Deposit in wei the creator added when submitting their proposal. It
        // is taken from the msg.value of a newProposal call.
        uint proposalDeposit;
        // True if this proposal is to assign a new Curator
        bool newCurator;
        // true if more tokens are in favour of the proposal than opposed to it at
        // least `preSupportTime` before the voting deadline
        bool preSupport;
        // Number of Tokens in favor of the proposal
        uint yes;
        // Number of Tokens opposed to the proposal
        uint no;
        // Simple mapping to check if a shareholder has voted for it
        mapping (address => bool) votedYes;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => bool) votedNo;
        // Address of the shareholder who created the proposal
        address creator;
        // Address of the token used for voting 
        address Token;
    }

        // evo token 
    modifier onlyTokenholders {
        if (token.balanceOf(msg.sender) == 0) throw;
            _;
    }


    function proposalCreation() public {
    // Create a new proposal
    // fire up a new contract instance for new proposal creation 
    //transfer ownership of the new contract to the admin. 
    }

event DaoCreated(address indexed dao, address indexed owner, address indexed token, uint256 indexed id);


} 