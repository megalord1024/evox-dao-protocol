// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IStaking.sol";
import "hardhat/console.sol";

contract Sablier is Ownable {
    //  ISablierV2Lockup public sablierV2Lockup = ISablierV2Lockup(address(0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301)); // interface of sablier 
    ISablierV2Lockup public sablierV2Lockup; 

    //IStaking
    IStaking public staking;

    // address of the token 
    address public token;
    
    struct proposalInfo {
        uint256 yes;
        uint256 no; 
        uint256 abstain;
    }

    proposalInfo public proposal;

    uint256 public votingMarketCap = 10e17; // 10*10e18  percentage

    uint256 public  overflowYesvotes;
    
    uint256 public overflowNovotes;

    uint256 public aggregateOverflowVotes;

    //collecting data
    mapping (address => uint256) public staked;

     // Array to store all stakers
    address[] public stakers;

    // Total staked amount
    uint256 public totalStaked;

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

    constructor(address _sablierV2LockupAddress , address _token , address _staking) Ownable(msg.sender) {
        sablierV2Lockup = ISablierV2Lockup(_sablierV2LockupAddress);
        token = _token;
        staking = IStaking(_staking);
    }

    // add streamids to this contract 
    function addStreamID( address user, uint256[] calldata _streamID) public {
        streamID[user]= _streamID;
        
    }
    //get streamIds for user 
    function getstreamID(address user) public view returns(uint256[]memory){
      return  streamID[user]; 
    }

    //updating interface address 
    function updateSablierV2Lockup(address _newAddress) external onlyOwner {
        sablierV2Lockup = ISablierV2Lockup(_newAddress);
    }
    

    function getSablierAmount(address _user) public view  returns(uint256[]memory){
        uint256[] memory streamIds = getstreamID(_user);
        uint256[] memory result = new uint256[](streamIds.length);
        
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

    function getRemainingamount(uint256 _streamID)public view returns(uint256) {
            uint128 streamedAmount = sablierV2Lockup.streamedAmountOf(_streamID); 

            uint128 depositedAmount = sablierV2Lockup.getDepositedAmount(_streamID);

            require(streamedAmount <= depositedAmount, "Invalid stream state"); 

            uint256 remainingAmount = uint256(depositedAmount - streamedAmount);

            return remainingAmount;
    }

    function gettotalamount(address _user)public view returns(uint256) {
        uint256[] memory sabileramountarray =  getSablierAmount(_user);
        uint256 useramount =0;
        for(uint256 i =0; i < sabileramountarray.length; i++)
        {
            useramount += sabileramountarray[i];
        }
        return useramount;
    }

    // cast 1 add it yes to no 

    // Overflow vote handling
    function handleOverflowVotes(address _user) public  {

        //calculating totalvoting power for user 
        uint256 totalVotingPower = calculateFinalvotingPower(_user);

        // totalSupply of tokens 
        uint256 circulatingSupply = IERC20(token).totalSupply();

        console.log(circulatingSupply, "circulatingSupply");
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


    function calculateFinalvotingPower(address _user)public view returns(uint256){
        // get the values from the deposit/stake 
        uint256 depositAmount = staking.getUserdepositAmount(_user);
        // get the values from the Sablier's
        uint256 userSablierAmount = gettotalamount(_user);
        // totalVotingPower 
        uint256 totalVotingPower = depositAmount + userSablierAmount;
        console.log(totalVotingPower,"totalvotingPower");
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

    function setvotingMarketCap(uint256 _value) public onlyOwner {
        votingMarketCap = _value;
    }

 
}