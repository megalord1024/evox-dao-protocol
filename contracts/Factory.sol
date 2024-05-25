// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "./Proposal.sol";

// import "./ProposalManager.sol";

contract DaoFactory {
    struct Info {
        address creator;
        uint256 timestamp;
        string description;
        address proposal_address;
    }

    Info[] public ProposalList;

    address public token;
    constructor(address _token) {
        token = _token;
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
            _recipient
        );
        Proposal(address(_proposal)).transferOwnership(msg.sender);
        Info memory newInfo = Info({
            creator: _creator,
            timestamp: block.timestamp,
            description: _description,
            proposal_address: address(_proposal)
        });
        ProposalList.push(newInfo);
    }
}
