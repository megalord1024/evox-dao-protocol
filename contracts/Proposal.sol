// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/ISablier.sol";
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
        //    timestamp;
        uint256 timestamp;
    }

    // Address of the token used for voting
    address token;

    uint256 votingMarketCap = 10e17; // 10*10e18  percentage

    proposalInfo public proposal;

    IGovernance public governance;


    // Allowed recipients mapping
    mapping(address => bool) public allowedRecipients;

    // voters 
    mapping (address => uint256)public lastProposalVoteTime;

    // Mapping that includes:

    // lastProposalVoteTime + votingPeriod
    // Whenever they vote, this mapping gets updated
    // Withdraw and vote function check that currentTime > this mapping



    modifier IsLocked() {
        require(block.timestamp >= lastProposalVoteTime[msg.sender], "");
        _;
    }


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
        proposal.votingDeadline = block.timestamp + _debatingPeriod; //
        proposal.open = true;
        proposal.amount = _amount;
        proposal.recipient = _recipient;
        proposal.proposalDeposit = msg.value;
        token = _token;
        proposal.timestamp = block.timestamp; 
        governance = IGovernance(_governance);
    
    }

    function vote(bool _supportsProposal) external onlyTokenholders {
        require(proposal.open, "Voting period has ended");
        require(
            block.timestamp < proposal.votingDeadline,
            "Voting deadline has passed"
        );
        

        if (_supportsProposal) {
            proposal.yes++;
            proposal.votedYes[msg.sender] = true;
        } else {
            proposal.no++;
            proposal.votedNo[msg.sender] = true;
        }

       lastProposalVoteTime[msg.sender] = proposal.votingDeadline;
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
        if (proposal.yes > proposal.no) {
            proposal.proposalPassed = true;
        } else {
            proposal.proposalRejected = true;
        }
    }

    uint256 overflowYesvotes;
    
    uint256 overflowNovotes;

    uint256 aggregateOverflowVotes;

    // Overflow vote handling
    function handleOverflowVotes() public  {

        //calculating totalvoting power for user 
        uint256 totalVotingPower = calculateFinalvotingPower(msg.sender);

        // totalSupply of tokens 
        uint256 circulatingSupply = IERC20(token).totalSupply();

        uint256 votingCapNumericalValue = (votingMarketCap * circulatingSupply)/1e18;

        if(totalVotingPower > votingCapNumericalValue ){
            // overflowing the votes

            uint256 overflowVotes = totalVotingPower - votingCapNumericalValue;

            totalVotingPower = votingCapNumericalValue;

            aggregateOverflowVotes += overflowVotes;
        
        }
       
    }

    function calculateFinalVotes() external returns (uint256, uint256) {

       
        uint256 totalYesVotes =  proposal.yes;

        uint256 totalNoVotes =  proposal.no;

        // test this out hard get these value above zero 
        uint256 yesVoteProportion = (totalYesVotes*1e18
                                                        /totalYesVotes+totalNoVotes)*1e18; // 

        overflowYesvotes = (yesVoteProportion * aggregateOverflowVotes)*1e18;
        
        overflowNovotes = (aggregateOverflowVotes-overflowYesvotes);

        proposal.yes += overflowYesvotes;
        proposal.no += overflowNovotes;

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

    function getlastProposalVoteTime(address _user)public view returns(uint256){
        return lastProposalVoteTime[_user];
    }

    function calculateFinalvotingPower(address _user)public view returns(uint256){
        // get the values from the deposit/stake 
        uint256 depositAmount = governance.getUserdepositAmount(_user);
        // get the values from the Sablier's
        uint256 userSablierAmount = governance.getuserRemainingDepositedAmount(_user);
        // totalVotingPower 
        uint256 totalVotingPower = depositAmount + userSablierAmount;

        return totalVotingPower;
    }



}
