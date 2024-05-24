// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Proposal.sol";
// import "./ProposalManager.sol";

contract DaoFactory is Ownable {


    // evo token 
    modifier onlyTokenholders {
        require(token.balanceOf(msg.sender) == 0);
            _;
    }

    struct Info {
        address creator;
        uint256 timestamp;
        string  description ;
        address proposal_address;
    }


    Info[] public ProposalList;

    constructor()public {
    
    }

    function proposalCreation(address creator , string description , uint256 debatingPeriod) onlyTokenholders public {
    // Create a new proposal
    // fire up a new contract instance for new proposal creation 
    //transfer ownership of the new contract to the admin. 
    Proposal _Proposal = new Proposal(creator,description, debatingPeriod);
    ProposalList.push(creator,block.timestamp, description ,address(_Proposal));


    }

} 