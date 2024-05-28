// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interface/ISablier.sol";
import "./interface/Igovernance.sol";



contract Governance is Ownable ,AccessControl, IGovernance{
    // Mapping to store the amount of tokens staked by each user
    mapping (address => uint256) public staked;

    // Mapping to check if an account is locked for voting
    mapping (address => bool) public Islocked;

    // Mapping to store the time of deposit for each user
    mapping (address => uint256) public timeofdeposit;

    // Array to store all stakers
    address[] public stakers;

    // Address of the token contract (assume this is the Evox token)
    IERC20 public token;

    ISabiler public sabiler;

    // Reward rate per block
    uint256 public rewardRate;

    // Total staked amount
    uint256 public totalStaked;

    address factory_address;

    // Event to log deposits
    event Deposited(address indexed user, uint256 amount);

    // Event to log claims
    event Claimed(address indexed user, uint256 amount);

    // Event to log withdrawals
    event Withdrawn(address indexed user, uint256 amount);

    // Event to log reward addition
    event RewardAdded(uint256 amount);

    bytes32 public constant MODAERTOR = keccak256("MODAERTOR");

    // Modifier to check if the user has staked tokens
    modifier hasStaked(address _user) {
        require(staked[_user] > 0, "No tokens staked");
        _;
    }

    // Modifier to check if the user is not locked
    modifier notLocked(address _user) {
        require(!Islocked[_user], "Account is locked");
        _;
    }

    //new modifier 
    modifier onlyfactoryOROwner() {
        require(msg.sender == factory_address || msg.sender == owner(), "not the owner");
        _;
    }

    function addmoderator( address _moderator) external onlyfactoryOROwner {

    grantRole(MODAERTOR, _moderator);
        
    }


    constructor(address _token, uint256 _rewardRate, address _sabiler, address _factory_address) Ownable() {
        token = IERC20(_token);
        rewardRate = _rewardRate;
        sabiler = ISabiler(_sabiler);
        factory_address = _factory_address;
    }

    function deposit(address _user, uint256 amount) public returns (bool) {
        require(amount > 0, "Amount must be greater than 0");

        // Transfer Evox tokens to the contract
        token.transferFrom(msg.sender, address(this), amount);

        // Update staked amount
        if (staked[_user] == 0) {
            stakers.push(_user);
        }
        staked[_user] += amount;

        // Update total staked amount
        totalStaked += amount;

        // Record the time of deposit
        timeofdeposit[_user] = block.timestamp;

        emit Deposited(_user, amount);

        return true;
    }

    // function dreward() public {
    //     // Calculate the total reward based on the reward rate and total staked amount
    //     uint256 totalReward = totalStaked * rewardRate * (block.timestamp - timeofdeposit[msg.sender]) / 1e18;

    //     // Add the reward to the staked amount of each user
    //     staked[msg.sender] += totalReward;
    // }

    // function claim() public hasStaked(msg.sender) {
    //     // Calculate the user's reward
    //     uint256 reward = staked[msg.sender] * rewardRate * (block.timestamp - timeofdeposit[msg.sender]) / 1e18;

    //     // Reset the deposit time
    //     timeofdeposit[msg.sender] = block.timestamp;

    //     // Transfer the reward to the user
    //     token.transfer(msg.sender, reward);

    //     emit Claimed(msg.sender, reward);
    // }

    function User_withdraw() public hasStaked(msg.sender) notLocked(msg.sender) {
        // Transfer the staked amount back to the user
        uint256 amount = staked[msg.sender];
        staked[msg.sender] = 0;
        totalStaked -= amount;

        token.transfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function lock(address _user) external hasStaked(_user) returns (bool) {
        // Locks the user's staked amount for voting
        require(hasRole(MODAERTOR, msg.sender),"caller isnt modaertor");
        Islocked[_user] = true;
        return true;
    }

    function unlock(address _user) external hasStaked(_user) returns (bool) {
        // unLocks the user's staked amount for voting
        require(hasRole(MODAERTOR, msg.sender),"caller isnt modaertor");
        Islocked[_user] = false;
        return true;
    }

    // Admin functions
    function emergencyunlock() public onlyOwner{
        // Unlock all users
        for (uint256 i = 0; i < stakers.length; i++) {
            Islocked[stakers[i]] = false;
        }
    }

   
    function getWithdrawnAmount(uint256 streamId) external view returns (uint128) {
        return sabiler.getWithdrawnAmount(streamId);
    }


    function getRemainingDepositedAmount(uint256 streamId) external view returns (uint128) {
        return sabiler.getRemainingDepositedAmount(streamId);
    }

}