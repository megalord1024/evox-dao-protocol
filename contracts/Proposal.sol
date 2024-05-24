// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Proposal {
    // A proposal with newCurator == false represents a transaction
    // to be issued by this DAO
    // A proposal with newCurator == true represents a DAO split
    struct proposalInfo {
        // The address where the amount will go to if the proposal is accepted
        address recipient;
        // The amount to transfer to recipient if the proposal is accepted.
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
        // least preSupportTime before the voting deadline
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
        // Address of the token used for voting
        address token;
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
            IERC20(proposals[id].token).balanceOf(msg.sender) > 0,
            "Only token holders can perform this action"
        );
        _;
    }

    // Modifier to check if the recipient is allowed
    modifier onlyAllowedRecipients(address _recipient) {
        require(allowedRecipients[_recipient], "Recipient is not allowed");
        _;
    }

    constructor (
        address _creator,
        string memory _description,
        uint256 _debatingPeriod,
        uint256 _amount,
        address _token,
        address _recipient
    ) payable {
        require(_creator != address(0), "Invalid creator address");
        require(_token != address(0), "Invalid token address");
        require(_recipient != address(0), "Invalid token address");
        require(_debatingPeriod > 0, "Invalid time");
        require(_amount > 0, "Invalid amount");
        proposalsCount=1; 
        proposals[proposalsCount].creator = _creator;
        proposals[proposalsCount].description = _description;
        proposals[proposalsCount].votingDeadline = block.timestamp + _debatingPeriod;
        proposals[proposalsCount].open = true;
        proposals[proposalsCount].token = _token;
        proposals[proposalsCount].amount = _amount;
        proposals[proposalsCount].recipient = _recipient;
        proposals[proposalsCount].proposalDeposit = msg.value;
        sumOfProposalDeposits += msg.value;
    }

    function newProposal(
        string memory _description,
        uint256 _debatingPeriod,
        uint256 _amount,
        address _token,
        address _recipient
    ) external payable onlyAllowedRecipients(_recipient) returns (uint _proposalID) {
        require(
            _debatingPeriod >= minProposalDebatePeriod,
            "Debating period is too short"
        );
        require(_debatingPeriod <= 8 weeks, "Debating period is too long");
        require(msg.value > 0, "Proposal deposit is required");

        // to prevent curator from halving quorum before first proposal
        if (proposalsCount == 1)
            // initial length is 1 (see constructor)
            lastTimeMinQuorumMet = block.timestamp;

        _proposalID = proposalsCount++;
        proposalInfo storage p = proposals[_proposalID];
        p.recipient = _recipient;
        p.amount = _amount;
        p.description = _description;
        p.votingDeadline = block.timestamp + _debatingPeriod;
        p.open = true;
        p.creator = msg.sender;
        p.proposalDeposit = msg.value;
        p.token = _token;
        sumOfProposalDeposits += msg.value;

        emit ProposalAdded(_proposalID, _recipient, _amount, _description);
    }

    function vote(uint256 _proposalID, bool _supportsProposal) external onlyTokenholders(_proposalID) {
        proposalInfo storage p = proposals[_proposalID];

        require(p.open, "Voting period has ended");
        require(block.timestamp < p.votingDeadline, "Voting deadline has passed");
        require(isNumberInArray(msg.sender, _proposalID), "User Already Voted");

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

    function isNumberInArray(address user, uint256 number) public view returns (bool) {
        uint256[] storage array = votingRegister[user];
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == number) {
                return true;
            }
        }
        return false;
    }

    function closeProposal(uint256 _proposalID) external {
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

    function calculateFinalVotes(uint256 yesVotes, uint256 noVotes, uint256 aggregateOverflowVotes) internal pure returns (uint256, uint256) {
        uint256 totalVotes = yesVotes + noVotes;

        if (totalVotes == 0) {
            return (yesVotes, noVotes);
        }

        uint256 yesVoteProportion = (yesVotes * 1e18) / totalVotes;
        uint256 overflowToAllocateToYes = (yesVoteProportion * aggregateOverflowVotes) / 1e18;
        uint256 overflowToAllocateToNo = aggregateOverflowVotes - overflowToAllocateToYes;

        return (yesVotes + overflowToAllocateToYes, noVotes + overflowToAllocateToNo);
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

    // Function to add allowed recipients
    function addAllowedRecipient(address _recipient) external {
        // Add access control as needed
        allowedRecipients[_recipient] = true;
    }

    // Function to remove allowed recipients
    function removeAllowedRecipient(address _recipient) external {
        // Add access control as needed
        allowedRecipients[_recipient] = false;
    }
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