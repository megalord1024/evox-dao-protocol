// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;


interface IEvoxSablier {
    // add streamids to this contract 
    function addStreamID( address user, uint256[] calldata _streamID) external;
    //get streamIds for user 
    function getstreamID(address user) external returns(uint256[]memory);

    //get streamIds for user 
    function hasVoted(uint256 proposalId, address user) external view returns(bool);
    //updating interface address 
    function updateSablierV2Lockup(address _newAddress) external;

    /**
     * @dev Accessor to the internal vote counts.
     */
    function proposalVotes(uint256 proposalId) external view returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes);
    

    function getSablierAmount(address _user) external view returns(uint256[]memory);

    function getRemainingamount(uint256 _streamID) external view returns(uint256);

    function gettotalamount(address _user) external view returns(uint256);

    // Overflow vote handling
    function handleVotes(uint256 proposalId, address _user, uint8 _voteFlag) external;

    function calculateFinalVotes(uint256 proposalId) external view returns (uint256, uint256, uint256);

    function getTotalSupply() external view returns (uint256);


    function calculateFinalvotingPower(address _user) external view returns(uint256);


    function getUserdepositAmount(address _user) external view returns(uint256);

    function deposit(address _user, uint256 amount) external view returns (bool);

    function User_withdraw() external;

    function lock(address _user) external view returns (bool);

    function unlock(address _user) external view returns (bool);

    function setVotingLimitProportion(uint256 _value) external;

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) external view returns (uint256);

    function quorum() external view returns(uint256);

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) external view returns (address);

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) external;
    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external;
}