// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
// import "./interface/IEvoxStaking.sol";
import "hardhat/console.sol";

contract EvoxSablier is AccessControl {
    //  ISablierV2Lockup public sablierV2Lockup = ISablierV2Lockup(address(0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301)); // interface of sablier 

    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    ISablierV2Lockup public sablierV2Lockup; 

    // address of the token 
    address public token;

     /**
     * @dev Supported vote types. Matches Governor Bravo ordering.
     */
    enum VoteType {
        For,
        Against,                
        Abstain
    }

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address voter => bool) hasVoted;
    }

    mapping(uint256 proposalId => ProposalVote) private proposalInfo;

    uint256 public votingLimitProportion = 1e17; // 10%  percentage

    uint256 public totalOverflowVotes;

    //collecting data
    mapping (address => uint256) public staked;

     // Array to store all stakers
    address[] public stakers;

    // Total staked amount
    uint256 public totalStaked;

    uint256 public quorum;

      // Mapping to store the time of deposit for each user
    mapping (address => uint256) public timeofdeposit;

    // a user can have multiple stream id 
    mapping (address => uint256[]) public streamID;

    //get totalamount of sablier
    mapping (address => uint256) public sabliertotalUserAmount;

    // Mapping to check if an account is locked for voting
    mapping (address => bool) public Islocked;

    modifier hasStaked(address _user) {
        require(staked[_user] > 0, "No tokens staked");
        _;
    }

    /**
     * @dev Modifier to make a function callable only by a certain role. In
     * addition to checking the sender's role, `address(0)` 's role is also
     * considered. Granting a role to `address(0)` is equivalent to enabling
     * this role for everyone.
     */
    modifier onlyRoleOrOpenRole(bytes32 role) {
        if (!hasRole(role, address(0))) {
            _checkRole(role, _msgSender());
        }
        _;
    }

    constructor(address admin, address _governer, address _sablierV2LockupAddress, address _token, uint256 _quorum) {

        _grantRole(DEFAULT_ADMIN_ROLE, address(this));

        if(admin != address(0)) {
            _grantRole(DEFAULT_ADMIN_ROLE, address(admin));
        }        

        _grantRole(GOVERNOR_ROLE, _governer);

        sablierV2Lockup = ISablierV2Lockup(_sablierV2LockupAddress);
        token = _token;
        quorum = _quorum;
    }

    // add streamids to this contract 
    function addStreamID( address user, uint256[] calldata _streamID) public onlyRoleOrOpenRole(GOVERNOR_ROLE) {
        streamID[user]= _streamID;
    }
    //get streamIds for user 
    function getstreamID(address user) public view returns(uint256[]memory) {
      return  streamID[user]; 
    }

    //get streamIds for user 
    function hasVoted(uint256 proposalId, address user) public view returns(bool) {
      return  proposalInfo[proposalId].hasVoted[user]; 
    }

    //updating interface address 
    function updateSablierV2Lockup(address _newAddress) external onlyRoleOrOpenRole(GOVERNOR_ROLE) {
        sablierV2Lockup = ISablierV2Lockup(_newAddress);
    }

    /**
     * @dev Accessor to the internal vote counts.
     */
    function proposalVotes(uint256 proposalId) public view returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) {
        return (proposalInfo[proposalId].forVotes, proposalInfo[proposalId].againstVotes, proposalInfo[proposalId].abstainVotes);
    }
    

    function getSablierAmount(address _user) public view  returns(uint256[] memory) {
        uint256[] memory streamIds = getstreamID(_user);
        uint256[] memory result;
        if(streamIds.length != 0) {
            result = new uint256[](streamIds.length);
        } else {
            result = new uint256[](1);
            return result;
        }
        
        if (streamIds.length > 1) {
            for (uint256 i = 0; i < streamIds.length; i++) {
                uint256 streamId = streamIds[i];
                result[i]= getRemainingamount(streamId);
            }
            return result; // exit
        }

        result[0] = getRemainingamount(streamIds[0]);
        
        return result; // exit function  
    }

    function getRemainingamount(uint256 _streamID) public view returns(uint256) {
        uint128 streamedAmount = sablierV2Lockup.streamedAmountOf(_streamID); 

        uint128 depositedAmount = sablierV2Lockup.getDepositedAmount(_streamID);

        require(streamedAmount <= depositedAmount, "Invalid stream state"); 

        uint256 remainingAmount = uint256(depositedAmount - streamedAmount);

        return remainingAmount;
    }

    function gettotalamount(address _user) public view returns(uint256) {
        uint256[] memory sabileramountarray =  getSablierAmount(_user);
        uint256 useramount =0;
        for(uint256 i =0; i < sabileramountarray.length; i++)
        {
            useramount += sabileramountarray[i];
        }
        return useramount;
    }

    // Overflow vote handling
    function handleVotes(uint256 proposalId, address _user, uint8 _voteFlag) public onlyRoleOrOpenRole(GOVERNOR_ROLE) {
        //calculating totalvoting power for user 
        uint256 totalVotingPower = calculateFinalvotingPower(_user);

        // totalSupply of tokens 
        uint256 circulatingSupply = IERC20(token).totalSupply();

        uint256 votingThreshold = (votingLimitProportion * circulatingSupply) / 1e18;

        if(totalVotingPower > votingThreshold ){
            // overflowing the votes

            uint256 overflowVotes = totalVotingPower - votingThreshold;

            totalVotingPower = votingThreshold;

            totalOverflowVotes += overflowVotes;
        }
        if(_voteFlag == uint8(VoteType.Against)) {
            proposalInfo[proposalId].againstVotes += totalVotingPower;
        } else if(_voteFlag == uint8(VoteType.For)) {
            proposalInfo[proposalId].forVotes += totalVotingPower;
        } else {
            proposalInfo[proposalId].abstainVotes += totalVotingPower;
        }
        proposalInfo[proposalId].hasVoted[_user] = true;       
    }

    function calculateFinalVotes(uint256 proposalId) external view returns (uint256, uint256, uint256) {  
        uint256 totalAgainstVotes =  proposalInfo[proposalId].againstVotes;
        uint256 totalForVotes =  proposalInfo[proposalId].forVotes;
        uint256 totalAbstainVotes = proposalInfo[proposalId].abstainVotes;

        // test this out hard get these value above zero 
        uint256 forVotesProportion = totalForVotes * 1e18 / (totalForVotes + totalAgainstVotes + totalAbstainVotes); // 
        uint256 OverflowForVotes = totalOverflowVotes * forVotesProportion / 1e18;

        uint256 againstVotesProportion = totalAgainstVotes * 1e18 / (totalForVotes + totalAgainstVotes + totalAbstainVotes); //     
        uint256 overflowAgainstVotes = totalOverflowVotes * againstVotesProportion / 1e18;

        uint256 abstainVotesProportion = totalAbstainVotes * 1e18 / (totalForVotes + totalAgainstVotes + totalAbstainVotes); // 
        uint256 overflowAbstainVotes = totalOverflowVotes * abstainVotesProportion / 1e18;

        return (totalForVotes + OverflowForVotes, totalAgainstVotes + overflowAgainstVotes, totalAbstainVotes + overflowAbstainVotes);
    }

    function getTotalSupply() public view returns (uint256) {  
       return IERC20(token).totalSupply();
    }


    function calculateFinalvotingPower(address _user) public view returns(uint256) {
        // get the values from the deposit/stake 
        uint256 depositAmount = getUserdepositAmount(_user);
        // get the values from the Sablier's
        uint256 userSablierAmount = gettotalamount(_user);
        // totalVotingPower 
        uint256 totalVotingPower = depositAmount + userSablierAmount;

        return totalVotingPower;
    }

    function getUserdepositAmount(address _user) public view returns(uint256){
        return staked[_user];   
    }

    function deposit(address _user, uint256 amount) public returns (bool) {
        require(amount > 0, "Amount must be greater than 0");

        // Transfer Evox tokens to the contract
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Update staked amount
        if (staked[_user] == 0) {
            stakers.push(_user);
        }
        staked[_user] += amount;

        // Update total staked amount
        totalStaked += amount;

        // Record the time of deposit
        timeofdeposit[_user] = block.timestamp;

        return true;
    }


    function User_withdraw() public hasStaked(msg.sender) {
        // Transfer the staked amount back to the user
        uint256 amount = staked[msg.sender];
        staked[msg.sender] = 0;
        totalStaked -= amount;
        IERC20(token).transfer(msg.sender, amount);

    }

    function lock(address _user) external hasStaked(_user) returns (bool) {
        // Locks the user's staked amount for voting
        Islocked[_user] = true;
        return true;
    }

    function unlock(address _user) external hasStaked(_user) returns (bool) {
        // unLocks the user's staked amount for voting
        Islocked[_user] = false;
        return true;
    }

    function setVotingLimitProportion(uint256 _value) public onlyRoleOrOpenRole(GOVERNOR_ROLE) {
        votingLimitProportion = _value;
    } 

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) external view returns (uint256) {
      return calculateFinalvotingPower(account);
    }

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) external view returns (address) {

    }

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) external {

    }

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external {

    }
}