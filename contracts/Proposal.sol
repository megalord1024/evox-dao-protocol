// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/Igovernance.sol";

contract Proposal is Ownable {
    // A proposal with `newCurator == false` represents a transaction
    // to be issued by this DAO
    // A proposal with `newCurator == true` represents a DAO split
    struct proposalInfo {
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
        //False if the votes have been counted and
        // the majority said no
        bool proposalRejected;
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
        mapping(address => bool) votedYes;
        // Simple mapping to check if a shareholder has voted against it
        mapping(address => bool) votedNo;
        // Address of the shareholder who created the proposal
        address creator;
    }

    // Address of the token used for voting
    address token;

    uint256 votingMarketCap = 10;

    proposalInfo public proposal;

    IGovernance public governance;

    // Voting register for each address
    mapping(address => uint256[]) public votingRegister;

    // Allowed recipients mapping
    mapping(address => bool) public allowedRecipients;

    // voters 
    address [] public voters;

    // Event for voting
    event Voted(address indexed voter, bool supportsProposal);

    // Modifier to check if the caller is a token holder
    modifier onlyTokenholders() {
        require(
            IERC20(token).balanceOf(msg.sender) > 0,
            "Only token holders can perform this action"
        );
        _;
    }

    constructor(
        address _creator,
        string memory _description,
        uint256 _debatingPeriod,
        uint256 _amount,
        address _token,
        address _recipient,
        address _governance
    ) payable Ownable() {
        require(_creator != address(0), "Invalid creator address");
        require(_recipient != address(0), "Invalid token address");
        require(_debatingPeriod > 0, "Invalid time");
        require(_amount > 0, "Invalid amount");
        require(_token != address(0) , "Invalid token address");
        proposal.creator = _creator;
        proposal.description = _description;
        proposal.votingDeadline = block.timestamp + _debatingPeriod;
        proposal.open = true;
        proposal.amount = _amount;
        proposal.recipient = _recipient;
        proposal.proposalDeposit = msg.value;
        token = _token;
        governance = IGovernance(_governance);
    }

    function vote(bool _supportsProposal) external onlyTokenholders {
        require(proposal.open, "Voting period has ended");
        require(
            block.timestamp < proposal.votingDeadline,
            "Voting deadline has passed"
        );
        voters.push(msg.sender);
        governance.lock(msg.sender);

        if (_supportsProposal) {
            proposal.yes++;
            proposal.votedYes[msg.sender] = true;
        } else {
            proposal.no++;
            proposal.votedNo[msg.sender] = true;
        }

        emit Voted(msg.sender, _supportsProposal);
    }

    function closeProposal() external onlyOwner {
        require(
            block.timestamp >= proposal.votingDeadline,
            "Voting period is not over yet"
        );
        require(proposal.open, "Proposal is already closed");

        proposal.open = false;
        // unlocking everyones token after the proposal is Done.
        for (uint i = 0; i < voters.length; i++) {
            governance.unlock(voters[i]);
        }
        if (proposal.yes > proposal.no) {
            proposal.proposalPassed = true;
        } else {
            proposal.proposalRejected = true;
        }
    }

    // Overflow vote handling
    function handleOverflowVotes(
        uint256 totalVotes,
        uint256 circulatingSupply
    ) internal view returns (uint256, uint256) {
        if (totalVotes <= circulatingSupply / votingMarketCap) {
            return (totalVotes, 0);
        }

        uint256 overflowVotes = totalVotes - circulatingSupply / votingMarketCap;
        uint256 cappedVotes = circulatingSupply / votingMarketCap;

        return (cappedVotes, overflowVotes);

        
    }

    function calculateFinalVotes() external view returns (uint256, uint256) {
        return (proposal.yes, proposal.no);
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "No funds available");

        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer failed");
    }

    function setvotingMarketCap(uint256 _value) public onlyOwner {
        votingMarketCap = _value;
    }

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
