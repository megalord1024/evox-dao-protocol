// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity =0.8.20; // 0.8.23

Contract StakingDAO {

// lets assume rewards in Evox 



mapping (address => uint256) public staked ;

mapping (address => bool)public Islocked;

mapping (address => uint256) public timeofdeposit ;





function  deposit(address _user , uint256 amount)  returns (bool) {
    // deposit amount to staking contract 
    // or we are getting the value from  sablier
    // current claimable + unclaimable value 
    //only EVOx token are allow 
}


function dreward() public {
    // we need to do the math for number of token by Dao as reward token , 
    // then we want to dyanmic pool based rewarding system 
}




function claim() public {

    //wants users to claim the amount that DAO distributed as rewards ? from the exchange profit
    
    // want to dyanmic pool based rewarding system 


}

function User_withdraw()public {
    //user should able 
    //should check islocked 
    // automatically claim should be called 

} 

function lock() public  returns () {
    //if the user is voting 
    // it should lock the amount  till the endtime of the proposal 

}

// admin functions 

function emergencyunlock()public {
    // if true 
    //by pass all logic and let people withdraw the staked amount (dont think of giving rewards here) 
    

} 

function alterEmergencywithdraw()public onlyowner {
    // change true false for 
}

function addReward() external {
    // we need DAO contract to add rewards into the staking contracts 
    // and update the value in drewards.
    // we need to do the math for number of token added by Dao as reward token ,
    // we need lastReward added . 
}



}