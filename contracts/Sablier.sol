// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "@sablier/v2-core/src/interfaces/ISablierV2Lockup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sablier is Ownable {
    ISablierV2Lockup public sablierV2Lockup; 

    constructor(address _sablierV2LockupAddress) Ownable(msg.sender) {
        sablierV2Lockup = ISablierV2Lockup(_sablierV2LockupAddress);
    }

    function updateSablierV2Lockup(address _newAddress) external onlyOwner {
        sablierV2Lockup = ISablierV2Lockup(_newAddress);
    }

    function getWithdrawnAmount(uint256 streamId) external view returns (uint128) {
        return sablierV2Lockup.getWithdrawnAmount(streamId);
    }


    function getRemainingDepositedAmount(uint256 streamId) external view returns (uint128) {
        uint128 withdrawnAmount = sablierV2Lockup.getWithdrawnAmount(streamId);
        uint128 depositedAmount = sablierV2Lockup.getDepositedAmount(streamId);
        
        require(withdrawnAmount <= depositedAmount, "Invalid stream state: withdrawn > deposited"); 

        return depositedAmount - withdrawnAmount;
    }

}