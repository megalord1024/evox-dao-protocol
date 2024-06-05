// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Proposal.sol";
import "./governance.sol";


contract DaoFactory is Ownable{

    struct Info {
        address creator;
        uint256 timestamp;
        string description;
        address proposal_address; // address of the newly creatred contract 
    }

    address admin;

    Info[] public ProposalList;


    //should true till the first proposal deadline 
    uint256 public lastProposalTime ;


    // modifier for the active Proposal 
    modifier isActiveProposal() {
        require(block.timestamp >= lastProposalTime, "Please wait for current proposal to finish before submitting a new proposal");
        _;
    }

    IGovernance public governance;
    // evoX token 
    address public token;

    constructor(address _token , address _admin) Ownable(msg.sender) {
        token = _token;
        admin = _admin;
    }

    function proposalCreation(
        address _creator,
        string memory _description,
        uint256 _debatingPeriod,
        uint256 _amount,
        address _recipient
    ) public isActiveProposal() {
        // Create a new proposal
        // fire up a new contract instance for new proposal creation
        //transfer ownership of the new contract to the admin.
        //shouldnt create before the first one ends
        Proposal _proposal = new Proposal(
            _creator,
            _description,
            _debatingPeriod,
            _amount,
            token,
            _recipient,
            address(governance)
        );
        // transfer ownership is transferred to the perfered owner once the proposal is created by user.
        Proposal(address(_proposal)).transferOwnership(admin);

        Info memory newInfo = Info({
            creator: _creator,
            timestamp: block.timestamp,
            description: _description,
            proposal_address: address(_proposal)
        });
        ProposalList.push(newInfo);
        governance.addmoderator(address(_proposal)); 
                            // when the proposal started    
       // lastProposalTime = Info.timestamp + _debatingPeriod;
        lastProposalTime = block.timestamp + _debatingPeriod;
    }

    function updateGoverance(address _governance) public onlyOwner {
        governance = IGovernance(_governance);
    }
}
