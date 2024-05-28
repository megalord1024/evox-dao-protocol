// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Proposal.sol";
import "./governance.sol";


// import "./ProposalManager.sol";

contract DaoFactory is Ownable{
    struct Info {
        address creator;
        uint256 timestamp;
        string description;
        address proposal_address;
    }

    address admin;
    Info[] public ProposalList;

    IGovernance public governance;

    address public token;
    constructor(address _token , address _admin) Ownable() {
        token = _token;
        admin = _admin;
    }

    function proposalCreation(
        address _creator,
        string memory _description,
        uint256 _debatingPeriod,
        uint256 _amount,
        address _recipient
    ) public {
        // Create a new proposal
        // fire up a new contract instance for new proposal creation
        //transfer ownership of the new contract to the admin.
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
    }

    function updateGoverance(address _governance) public onlyOwner {
        governance = IGovernance(_governance);
    }
}
