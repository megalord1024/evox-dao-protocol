// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sablier is Ownable {
    //  ISablierV2Lockup public sablierV2Lockup = ISablierV2Lockup(address(0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301)); // interface of sablier 
    ISablierV2Lockup public sablierV2Lockup; 


    struct streamInfo {
        uint256 streamID;
        uint256 withdrawnAmount;
        uint256 depositAmount;
        uint256 userRemainingDepositedAmount;
    }

    mapping (address => streamInfo) public userInfo;

    mapping(address => uint256) public userStreamID;

    mapping(address => uint256) public userRemainingDepositedAmount;

    event addedstreamId(uint256 _StreamID, address user);

    constructor(address _sablierV2LockupAddress) Ownable() {
        sablierV2Lockup = ISablierV2Lockup(_sablierV2LockupAddress);
    }
    //updating interface address 
    function updateSablierV2Lockup(address _newAddress) external onlyOwner {
        sablierV2Lockup = ISablierV2Lockup(_newAddress);
    }
    // getting user remaining balance in sablier (depositedamount - withdrawnAmount) use that for voting 
    function getRemainingDepositedAmount(address _user) external view returns (uint256) {
        return userRemainingDepositedAmount[_user];
    }

    function getSablierAmount(address _user) public returns(uint256){
        uint256 streamId = userStreamID[_user];
        // already withdraw 
        uint128 StreamedAmount = sablierV2Lockup.streamedAmountOf(streamId);// streamID  
        // deposited for particular stream 
        
        uint128 depositedAmount = sablierV2Lockup.getDepositedAmount(streamId);

        require(StreamedAmount <= depositedAmount, "Invalid stream state: withdrawn > deposited"); 

        uint256 Remainingamount = uint256(depositedAmount - StreamedAmount);

        userRemainingDepositedAmount[_user] = Remainingamount;

        return Remainingamount;
    }

    function getStreamID() external view returns(uint256){
        return userStreamID[msg.sender];
    }

    // think about this 
    function addStreamID(uint256 _streamID, address user) external onlyOwner {
        userStreamID[user]= _streamID;
        emit addedstreamId(_streamID, user);
    }

    // needs to add a function to add batch stream ids 

    // two wallets with multiple streams 
    mapping (address => uint256[]) public _streamID;

    // if (arraylength > 1){
    //     for loop over array length 
            //  run getSablierAmount (_user)  
    // }
    

}