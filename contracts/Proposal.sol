// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract Proposal is Ownable{
    // A proposal with `newCurator == false` represents a transaction
    // to be issued by this DAO
    // A proposal with `newCurator == true` represents a DAO split

    IERC20 public token;

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

    // Proposal storage
    mapping(uint256 => proposalInfo) public proposals;
    uint256 public proposalsCount;

    // Sum of all proposal deposits
    uint256 public sumOfProposalDeposits;
    uint256 public minProposalDebatePeriod = 1 weeks;
    uint256 public lastTimeMinQuorumMet;

    // Voting register for each address
    mapping(address => uint256[]) public votingRegister;

    // Allowed recipients mapping
    mapping(address => bool) public allowedRecipients;

    // Event for new proposal
    event ProposalAdded(
        uint256 proposalID,
        address recipient,
        uint256 amount,
        string description
    );
    // Event for voting
    event Voted(uint256 proposalID, bool supportsProposal, address voter);

    // Modifier to check if the caller is a token holder
    modifier onlyTokenholders(uint256 id) {
        require(
            IERC20(token).balanceOf(msg.sender) > 0,
            "Only token holders can perform this action"
        );
        _;
    }

    // Modifier to check if the recipient is allowed
    modifier onlyAllowedRecipients(address _recipient) {
        require(allowedRecipients[_recipient], "Recipient is not allowed");
        _;
    }

    modifier onlyCreator(uint256 id) {
        require(proposals[id].creator == msg.sender, "Recipient is not creator");
        _;
    }

    constructor (
        address _creator,
        string memory _description,
        uint256 _debatingPeriod,
        uint256 _amount,
        address _token, // evox
        address _recipient
    ) payable Ownable(msg.sender){
        require(_creator != address(0), "Invalid creator address");
        require(_token != address(0), "Invalid token address");
        require(_recipient != address(0), "Invalid token address");
        require(_debatingPeriod > 0, "Invalid time");
        require(_amount > 0, "Invalid amount");
        token = IERC20(_token);
        proposalsCount = 1; 
        proposals[proposalsCount].creator = _creator;
        proposals[proposalsCount].description = _description;
        proposals[proposalsCount].votingDeadline = block.timestamp + _debatingPeriod;
        proposals[proposalsCount].open = true;
        proposals[proposalsCount].amount = _amount;
        proposals[proposalsCount].recipient = _recipient;
        proposals[proposalsCount].proposalDeposit = msg.value;
        sumOfProposalDeposits += msg.value;
    }


    function vote(uint256 _proposalID, bool _supportsProposal) external onlyTokenholders(_proposalID) {
        proposalInfo storage p = proposals[_proposalID];

        require(p.open, "Voting period has ended");
        require(block.timestamp < p.votingDeadline, "Voting deadline has passed");
       
       // transfer token user to this contract 
       // user use deposit function for the same .
        // 10 =10+1 = 11 state update 
       // token  sits in this contract =>  


        if (_supportsProposal) {
            p.yes ++;
            p.votedYes[msg.sender] = true;
        } else {
            p.no ++;
            p.votedNo[msg.sender] = true;
        }

        votingRegister[msg.sender].push(_proposalID);
        emit Voted(_proposalID, _supportsProposal, msg.sender);
    }

  

    function closeProposal(uint256 _proposalID) external onlyCreator(_proposalID){
        proposalInfo storage p = proposals[_proposalID];

        require(block.timestamp >= p.votingDeadline, "Voting period is not over yet");
        require(p.open, "Proposal is already closed");

        p.open = false;

        if (p.yes > p.no) {
            p.proposalPassed = true;
        } else {
            p.proposalRejected = true;
        }
    }   

    // Overflow vote handling
    function handleOverflowVotes(uint256 totalVotes, uint256 circulatingSupply) internal pure returns (uint256, uint256) {
        if (totalVotes <= circulatingSupply / 10) {
            return (totalVotes, 0);
        }

        uint256 overflowVotes = totalVotes - circulatingSupply / 10;
        uint256 cappedVotes = circulatingSupply / 10;

        return (cappedVotes, overflowVotes);
    }

    function calculateFinalVotes(uint256 _proposalId) external view returns (uint256, uint256) {

        return (proposals[_proposalId].yes , proposals[_proposalId].no);
    }

    // Function to add allowed recipients
    function addAllowedRecipient(address _recipient) external onlyOwner{
        // Add access control as needed
        allowedRecipients[_recipient] = true;
    }

    // Function to remove allowed recipients
    function removeAllowedRecipient(address _recipient) external onlyOwner{
        // Add access control as needed
        allowedRecipients[_recipient] = false;
    }
     function withdraw() external onlyOwner {
        require(address(this).balance > 0, "No funds available");

        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success, "Transfer failed");
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