// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Staking is Ownable {

    // address of the token 
    address public token;

    //collecting data
    mapping (address => uint256) public staked;

     // Array to store all stakers
    address[] public stakers;

    // Total staked amount
    uint256 public totalStaked;

      // Mapping to store the time of deposit for each user
    mapping (address => uint256) public timeofdeposit;


        // Mapping to check if an account is locked for voting
    mapping (address => bool) public Islocked;

    modifier hasStaked(address _user) {
        require(staked[_user] > 0, "No tokens staked");
        _;
    }

    constructor(address _token)Ownable(msg.sender){
            token = _token;
    }

  function getUserdepositAmount(address _user) public view returns(uint256){
        return staked[_user];   
    }

    function deposit(address _user, uint256 amount) public returns (bool) {
        require(amount > 0, "Amount must be greater than 0");

        // Transfer Evox tokens to the contract
        IERC20(token).transferFrom(_user, address(this), amount);

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

}