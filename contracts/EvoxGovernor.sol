// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import OpenZeppelin governance contracts
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorStorage.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorPreventLateQuorum.sol";
import "./interface/IEvoxSablier.sol";
import "hardhat/console.sol";

/**
 * @title OZGovernor
 * @dev OZGovernor is a smart contract that extends OpenZeppelin's Governor with additional features
 * for voting, timelock, and quorum.
 */
contract EvoxGovernor is Governor, GovernorSettings, GovernorStorage, GovernorVotes, GovernorTimelockControl {

    IEvoxSablier sablier;
    /**
     * @dev Initializes the OZGovernor contract.
     * @param _name The name of the governor.
     * @param _timelock The timelock controller.
     * @param _initialVotingDelay, 7200, 1 day
     * @param _initialVotingPeriod, 50400, 1 week 
     * @param _initialProposalThreshold, 0, proposal threshold
     */
    constructor(
        string memory _name, 
        TimelockController _timelock,
        IEvoxSablier _sablier,
        IVotes _token,
        uint48 _initialVotingDelay, 
        uint32 _initialVotingPeriod, 
        uint256 _initialProposalThreshold
    )
        Governor(_name)
        GovernorSettings(_initialVotingDelay, _initialVotingPeriod, _initialProposalThreshold)
        GovernorVotes(_token)
        GovernorTimelockControl(_timelock)
        
    {
        sablier = IEvoxSablier(_sablier);
    }

    /**
     * @notice Retrieves the voting delay configured in the settings.
     * @return The configured voting delay.
     */
    function votingDelay()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    /**
     * @notice Retrieves the voting period configured in the settings.
     * @return The configured voting period.
     */
    function votingPeriod()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    /**
     * @notice Retrieves the quorum required for a vote to succeed.
     * @param blockNumber The block number for which to determine the quorum.
     * @return The required quorum at the given block number.
     */
    function quorum(uint256 blockNumber)
        public
        view
        override(Governor)
        returns (uint256)
    {
        return sablier.quorum();
    }

    /**
     * @notice Retrieves the current state of a proposal.
     * @param proposalId The ID of the proposal to query.
     * @return The current state of the proposal (e.g., Pending, Active, Canceled, Defeated, Succeeded, Queued, Executed).
     */
    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    /**
     * @notice Retrieves the threshold required for a proposal to be enacted.
     * @return The threshold required for a proposal to be enacted.
     */
    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    /**
     * @notice Proposes an action to be taken.
     * @param targets The addresses of the contracts to interact with.
     * @param values The values (ETH) to send in the interactions.
     * @param calldatas The encoded data of the interactions.
     * @param description A brief description of the proposal.
     * @param proposer The address of the proposer.
     * @return The ID of the newly created proposal.
     */
    function _propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description, address proposer)
        internal
        override(GovernorStorage, Governor)
        returns (uint256)
    {
        return super._propose(targets, values, calldatas, description, proposer);
    }

    /**
     * @notice Queues operations for execution.
     * @param proposalId The ID of the proposal containing the operations.
     * @param targets The addresses of the contracts to interact with.
     * @param values The values (ETH) to send in the interactions.
     * @param calldatas The encoded data of the interactions.
     * @param descriptionHash The hash of the proposal description.
     * @return The ID of the timelock transaction.
     */
    function _queueOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint48)
    {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    /**
     * @notice Executes operations from a proposal.
     * @param proposalId The ID of the proposal containing the operations.
     * @param targets The addresses of the contracts to interact with.
     * @param values The values (ETH) to send in the interactions.
     * @param calldatas The encoded data of the interactions.
     * @param descriptionHash The hash of the proposal description.
     */
    function _executeOperations(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    /**
     * @notice Cancels operations from a proposal.
     * @param targets The addresses of the contracts to interact with.
     * @param values The values (ETH) to send in the interactions.
     * @param calldatas The encoded data of the interactions.
     * @param descriptionHash The hash of the proposal description.
     * @return The ID of the canceled proposal.
     */
    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    /**
     * @notice Casts a vote on a proposal.
     * @param proposalId The ID of the proposal to vote on.
     * @param account The address of the voter.
     * @param support The vote choice (true for yes, false for no).
     * @param reason A brief description of the reason for the vote.
     * @param params The parameters for the vote.
     * @return The ID of the vote.
     */
    function _castVote(
        uint256 proposalId,
        address account,
        uint8 support,
        string memory reason,
        bytes memory params
    )         
        internal
        virtual
        override(Governor)
        returns (uint256) {

        return super._castVote(proposalId, account, support, reason,params);
    }

    /**
     * 
     * @notice Retrieves the deadline for submitting proposals.
     * @param proposalId The ID of the proposal to query.
     * @return The deadline for submitting proposals.
     */
    function proposalDeadline(uint256 proposalId)
        public
        view
        override(Governor)
        returns (uint256)
    {
        return super.proposalDeadline(proposalId);
    }

    /**
     * @notice Retrieves the address of the executor configured in the timelock control.
     * @return The address of the executor.
     */
    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    /**
     * @inheritdoc IERC6372
     */
    function clock() public view override(Governor, GovernorVotes) returns (uint48) {
        return uint48(block.number);
    }

    /**
     * @inheritdoc IERC6372
     */
    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public view override(Governor, GovernorVotes) returns (string memory) {
        return "mode=blocknumber&from=default";
    }

    /**
     * @dev See {IGovernor-proposalNeedsQueuing}.
     */
    function proposalNeedsQueuing(uint256) public view override(Governor, GovernorTimelockControl) returns (bool) {
        return false;
    }

    function COUNTING_MODE() external view returns (string memory) {
        return "support=bravo&quorum=for,abstain";
    }

    function hasVoted(uint256 proposalId, address account) external view returns (bool) {
        return sablier.hasVoted(proposalId, account);
    }

    /**
     * @dev Amount of votes already cast passes the threshold limit.
     */
    function _quorumReached(uint256 proposalId) internal view override(Governor) returns (bool) {
        uint256 proposal_start = proposalSnapshot(proposalId);
        uint256 current_time = clock();
        uint256 voting_duration = votingPeriod();
        uint256 forVotes;
        uint256 AgainstVotes;
        uint256 abstainVotes;
        if(proposal_start + voting_duration <= current_time) {
            (forVotes, AgainstVotes, abstainVotes) = sablier.calculateFinalVotes(proposalId);
        } else {
            (forVotes, AgainstVotes, abstainVotes) = sablier.proposalVotes(proposalId);
        }
        if(forVotes >= quorum(block.number)) {
            return true;
        }
        return false;
    }

    /**
     * @dev Is the proposal successful or not.
     */
    function _voteSucceeded(uint256 proposalId) internal view override(Governor) returns (bool) {
        (uint256 forVotes, uint256 AgainstVotes, uint256 abstainVotes) = sablier.proposalVotes(proposalId);
        return forVotes > AgainstVotes;
    }

    /**
     * @dev Get the voting weight of `account` at a specific `timepoint`, for a vote as described by `params`.
     */
    function _getVotes(address account, uint256 timepoint, bytes memory params) internal view override(Governor, GovernorVotes) returns (uint256) {
        return sablier.calculateFinalvotingPower(account);
    }

    /**
     * @dev Register a vote for `proposalId` by `account` with a given `support`, voting `weight` and voting `params`.
     *
     * Note: Support is generic and can represent various things depending on the voting system used.
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight,
        bytes memory params
    ) internal override(Governor) {
        sablier.handleVotes(proposalId, account, support);
    }
}
