// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;


Contract Proposal{








function newProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionData,
        uint64 _debatingPeriod
    ) onlyTokenholders payable returns (uint _proposalID) {

        if (!allowedRecipients[_recipient]
            || _debatingPeriod < minProposalDebatePeriod
            || _debatingPeriod > 8 weeks
            || msg.value < proposalDeposit
            || msg.sender == address(this) //to prevent a 51% attacker to convert the ether into deposit
            )
                throw;

        // to prevent curator from halving quorum before first proposal
        if (proposals.length == 1) // initial length is 1 (see constructor)
            lastTimeMinQuorumMet = now;

        _proposalID = proposals.length++;
        Proposal p = proposals[_proposalID];
        p.recipient = _recipient;
        p.amount = _amount;
        p.description = _description;
        // p.proposalHash = sha3(_recipient, _amount, _transactionData);
        p.votingDeadline = now + _debatingPeriod;
        p.open = true;
        //p.proposalPassed = False; // that's default
        p.creator = msg.sender;
        p.proposalDeposit = msg.value;

        sumOfProposalDeposits += msg.value;

        ProposalAdded(
            _proposalID,
            _recipient,
            _amount,
            _description
        );
    }

 function vote(uint _proposalID, bool _supportsProposal) {

        Proposal p = proposals[_proposalID];

        unVote(_proposalID);

        if (_supportsProposal) {
            p.yea += token.balanceOf(msg.sender);
            p.votedYes[msg.sender] = true;
        } else {
            p.nay += token.balanceOf(msg.sender);
            p.votedNo[msg.sender] = true;
        }

        if (blocked[msg.sender] == 0) {
            blocked[msg.sender] = _proposalID;
        } else if (p.votingDeadline > proposals[blocked[msg.sender]].votingDeadline) {
            // this proposal's voting deadline is further into the future than
            // the proposal that blocks the sender so make it the blocker
            blocked[msg.sender] = _proposalID;
        }

        votingRegister[msg.sender].push(_proposalID);
        Voted(_proposalID, _supportsProposal, msg.sender);
    }

    // function unVote(uint _proposalID){
    //     Proposal p = proposals[_proposalID];

    //     if (now >= p.votingDeadline) {
    //         throw;
    //     }

    //     if (p.votedYes[msg.sender]) {
    //         p.yea -= token.balanceOf(msg.sender);
    //         p.votedYes[msg.sender] = false;
    //     }

    //     if (p.votedNo[msg.sender]) {
    //         p.nay -= token.balanceOf(msg.sender);
    //         p.votedNo[msg.sender] = false;
    //     }
    // }

}





/**
 * const aggregateOverflowVotes = X 0 

If (votes > tenPercentOfSupply){

    const overflowVotes = votes - tenPercentOfCirculatingSupply

    votes = tenPercentOfCirculatingSupply

    aggregateOverflowVotes += overflowVotes

}

Let totalYesVotes = A

Let totalNoVotes = B

yesVoteProportion = A/(A+B)

overflowToAllocateToYes = yesVoteProportion * aggregateOverflowVotes

overflowToAllocateToNo = aggregateOverflowVotes - overflowToAllocateToYes

 

totalYesVotes += overflowToAllocateToYes

totalNoVotes += overflowToAllocateToNo

if (vote == yes){

    totalYesVotes += votes
}

else{

    totalNoVotes +=votes

}



 */