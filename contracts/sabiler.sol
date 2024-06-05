// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sablier is Ownable {
    //  ISablierV2Lockup public sablierV2Lockup = ISablierV2Lockup(address(0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301)); // interface of sablier 
    ISablierV2Lockup public sablierV2Lockup; 

    // a user can have multiple stream id 
    mapping (address => uint256[]) public streamID;

    //get totalamount of sablier
    mapping (address => uint256) public totalUserAmount;

    // add streamids to this contract 
    function addStreamID( address user, uint256[] calldata _streamID) public {
        streamID[user]= _streamID;
        
    }
    //get streamIds for user 
    function getstreamID(address user) public view returns(uint256[]memory){
      return  streamID[user]; 
    }

    constructor(address _sablierV2LockupAddress) Ownable(msg.sender) {
        sablierV2Lockup = ISablierV2Lockup(_sablierV2LockupAddress);
    }
    //updating interface address 
    function updateSablierV2Lockup(address _newAddress) external onlyOwner {
        sablierV2Lockup = ISablierV2Lockup(_newAddress);
    }

    function getSablierAmount(address _user) public  returns(uint256[]memory){
        uint256[] memory streamIds = getstreamID(_user);
        uint256[] memory result = new uint256[](streamIds.length);
        
       if (streamIds.length > 1) {
        for (uint256 i = 0; i < streamIds.length; i++) {
            uint256 streamId = streamIds[i];
            result[i]= getRemainingamount(streamId);
            totalUserAmount[_user]+=result[i];
            }
            return result;
        }

        result[0] = getRemainingamount(streamIds[0]);
        totalUserAmount[_user] += result[0];

        return result;
       
    }

    function getRemainingamount(uint256 _streamID)internal view returns(uint256) {
            uint128 streamedAmount = sablierV2Lockup.streamedAmountOf(_streamID);// streamID  

            uint128 depositedAmount = sablierV2Lockup.getDepositedAmount(_streamID);

            require(streamedAmount <= depositedAmount, "Invalid stream state"); 

            uint256 remainingAmount = uint256(depositedAmount - streamedAmount);

            return remainingAmount;
    }

    function gettotalamount(address _user)public returns(uint256) {
        return totalUserAmount[_user];
    }



}