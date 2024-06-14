const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { getExpectedContractAddress } = require("../expected_contracts");
const { ethers, network} = require("hardhat");

async function mineBlocks(numBlocks) {
  for (let i = 0; i < numBlocks; i++) {
    await ethers.provider.send('evm_mine');
  }
}

describe("EvoxDao Test", function () {
  let Sablier,
    sablier,
    Token,
    token,
    owner,
    addr1,
    addr2,
    governance,
    Governance,
    factory,
    Factory;   

  let minDelay = 8400

  beforeEach(async function () {
    [owner, user1, user2, user3, user4] = await ethers.getSigners();
  }) 
  
  it("should work the full proposal lifecycle up to executed", async function () {   
    Token = await ethers.getContractFactory("EvoxToken");
    token = await Token.deploy("EVOX", "EVOX", owner.address, owner.address, owner.address);

    token_address = token.target

    //timelock contract 
    timelock = await ethers.getContractFactory("TimelockController");
    
    timelocker = await timelock.connect(owner).deploy(
      86400, // 2 hours
      [owner.address, owner.address],
      [owner.address, owner.address],
      owner.address,
    );

    timelock_address = timelocker.target

    const amountToMint = 10000_000000000000000000n;
    await token.connect(owner).mint(user1.address, amountToMint);
    await token.connect(owner).mint(user2.address, amountToMint);
    
    await expect( token.grantRole(await token.MINTER_ROLE(), timelock_address)).to.emit(token, "RoleGranted");

    let user_balance = await token.balanceOf(user1.address);
    expect(user_balance).to.be.equal(amountToMint);
    user_balance = await token.balanceOf(user2.address);
    expect(user_balance).to.be.equal(amountToMint);
    
    const SablierV2Address = "0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301";
    const quorum = 2000_000000000000000000n;
    Sablier = await ethers.getContractFactory("EvoxSablier");
    sablier = await Sablier.deploy(owner.address, owner.address, SablierV2Address, token_address, quorum);
    sablier_address = sablier.target

    streamID1 = 3028
    streamID2 = 3027

    await sablier.connect(owner).addStreamID(user2.address, [streamID1, streamID2])

    amt = await sablier.getRemainingamount(streamID1);
    
    am = await sablier.getstreamID(user2.address);

    amr = await sablier.getSablierAmount(user2.address);

    am1 = await sablier.calculateFinalvotingPower(user2.address);

    let governor_info = {
      name: "EVOX_DAO",
      votingDelay: 10, // 5 mins
      votingPeriod:  20, // 12 second per block, 4 hours
      proposalThreshold: 1500_000000000000000000n, // Set a non-zero value to prevent proposal spam.
    };

    // deploy ozg contract 
    og = await ethers.getContractFactory("EvoxGovernor");
    governor = await og.deploy( 
      governor_info.name,
      timelock_address,
      sablier_address,
      token_address,
      governor_info.votingDelay,
      governor_info.votingPeriod,
      governor_info.proposalThreshold
    );

    await expect( timelocker.connect(owner).grantRole(await timelocker.PROPOSER_ROLE(), governor.target)).to.emit(timelocker, "RoleGranted");
    await expect( timelocker.connect(owner).grantRole(await timelocker.EXECUTOR_ROLE(), governor.target)).to.emit(timelocker, "RoleGranted");
    await expect( sablier.connect(owner).grantRole(await sablier.GOVERNOR_ROLE(), governor.target)).to.emit(sablier, "RoleGranted");
    await expect( token.connect(owner).grantRole(await token.MINTER_ROLE(), governor.target)).to.emit(token, "RoleGranted");

    const calldata = token.interface.encodeFunctionData("mint", [user3.address, 1000_000000000000000000n]);
    let deposit_amount = 6000_000000000000000000n;
    await token.connect(user1).approve(sablier_address, deposit_amount);
    await sablier.connect(user1).deposit(user1.address, deposit_amount);
    
    deposit_amount = 5000_000000000000000000n;
    await token.connect(user2).approve(sablier_address, deposit_amount);
    await sablier.connect(user2).deposit(user2.address, deposit_amount);

    const proposalTx = await governor.connect(user1).propose(
        [token_address], // targets 
        [0n], // value
        [calldata],
        "Proposal to mint 1000 tokens for admin"// description
    );

    expect(proposalTx).to.emit(governor, "ProposalCreated");

    // Wait for the transaction to be mined
    const receipt = await proposalTx.wait(1);

    const eventLogs = (receipt?.logs ?? []).filter((log) => true);

    // Find the ProposalCreated event in the transaction receipt
    const event = eventLogs.find((log) => log.fragment.name === "ProposalCreated");

    const logDescription = governor.interface.parseLog({
        topics: event?.topics ? [...event.topics] : [],
        data: event?.data ?? "",
    });

    // Get the proposalId from the event arguments
    const proposalId = logDescription?.args["proposalId"];

    await mineBlocks(10);

    await expect(governor.connect(user1).castVote(proposalId, 0)).to.emit(governor, "VoteCast");
    await expect(governor.connect(user2).castVote(proposalId, 0)).to.emit(governor, "VoteCast");

    await expect(governor.queue(proposalId)).to.be.reverted;
    await mineBlocks(18);

    // expect proposal state to be succeeded
    let proposalState = await governor.state(proposalId);
    expect(proposalState).to.be.equal(4);
 
    // Queue proposal
    await expect( governor.queue(proposalId)).to.emit(governor, "ProposalQueued");

    // expect proposal state to be queued
    proposalState = await governor.state(proposalId);
    expect(proposalState).to.be.equal(5);

    // Execute proposal
    await expect(governor.execute(proposalId)).to.be.reverted;

    // Simulate time delay required before execution
    // Replace 'executionDelay' with your contract's specific delay
    await network.provider.send("evm_increaseTime", [86400 + 1]) // Increase time by 2 Days => 86400 * 2 => 172800
    await network.provider.send("evm_mine")
    // await mineBlocks(2);

    // Execute proposal
    await expect( governor.execute(proposalId)).to.emit(governor, "ProposalExecuted");

    // expect proposal state to be executed
    proposalState = await governor.state(proposalId);
    expect(proposalState).to.be.equal(7);

    // Check if admin's balance has increased
    const balance = await token.balanceOf(user3.address);
    expect(balance).to.be.equal(1000_000000000000000000n);
  });
});
