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

describe("Lock", function () {
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

    

  let governor = {
    name: "WE LOVE TALLY DAO",
    votingDelay: 0,
    votingPeriod:  86400,
    quorumNumerator: 4,
    proposalThreshold: 0, // Set a non-zero value to prevent proposal spam.
    voteExtension: 7200 // 7200 is 24 hours (assuming 12 seconds per block)
  };

  let minDelay = 8400

  // personalAccount = new ethers.Wallet("4141be2614fa25bab42c8a70429c61f68858295519ca06943d54b960574ec82a");

  beforeEach(async function () {
     [owner] = await ethers.getSigners();
      //new ethers.Wallet("4141be2614fa25bab42c8a70429c61f68858295519ca06943d54b960574ec82a");
    // owner = personalAccount[0];//await ethers.getSigners();
    // [owner, addr1, addr2] = await ethers.getSigners();
    
    console.log(owner.address, "line 47 ");
  }) 
    it("should revert if non-moderator tries to lock/unlock user", async function () {
    //  const [owner1] = await ethers.getSigners();
      //new ethers.Wallet("4141be2614fa25bab42c8a70429c61f68858295519ca06943d54b960574ec82a");
    // owner = personalAccount[0];//await ethers.getSigners();
    // [owner, addr1, addr2] = await ethers.getSigners();
    
    console.log(owner.address, "line 39 ");

    // Load values for constructor from a ts file deploy.config.ts
    // const governance_address = await getExpectedContractAddress(deployerSigner.address, 3);
    // const timelock_address = await getExpectedContractAddress(deployerSigner.address, 2);
    // const token_address = await getExpectedContractAddress(deployerSigner.address, 1);
    // const sabiler_address = await getExpectedContractAddress(deployerSigner.address, 0);
    // const admin_address = governance_address;

    console.log(owner.address, 'owener')
    Token = await ethers.getContractFactory("ERC20Token");
    token = await Token.deploy("evox", "evox", owner.address, owner.address, owner.address);

    token_address = token.target
    console.log(token.target,
      "tokenADDRESS");


    Staking = await ethers.getContractFactory("Staking")
    staking = await Staking.deploy(token_address);
    staking_address = staking.target;


    //timelock contract 
    timelock = await ethers.getContractFactory("TimelockControllerevox");
    // TimelockControllerevox = timelock.deploy()

    timelocker = await timelock.connect(owner).deploy(
      8400,
      ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"],
      ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"],
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  );

  timelock_address = timelocker.target

    // approve the token 
    const amountToMint = 100000n;
    await token.mint("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9", amountToMint);

    const balanceOne = await token.balanceOf("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9");
    console.log(balanceOne, "balanceOnce`");
    expect(balanceOne).to.be.equal(amountToMint);

    // await token.connect("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9").approve(staking_address, amountToMint);
    // abc = await token.allowance(owner.address, staking_address)
    // console.log(abc, "abc")
    // // deposit token 

    // await staking.deposit("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9", 10n)

    stakingamount = await staking.getUserdepositAmount("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9")
    console.log(stakingamount , "staking amount")


    Sablier = await ethers.getContractFactory("Sablier");
    sablier = await Sablier.deploy("0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301", token_address, staking_address)
    sablier_address = sablier.target
    console.log(sablier_address, "sab");

    streamID1 = 3028
    streamID2 = 3027

    await sablier.addStreamID("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9", [streamID1, streamID2])

    amt = await sablier.getRemainingamount(streamID1);
    console.log(amt, "amount 66");

    am = await sablier.getstreamID("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9");
    console.log(am, "0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9");

    amr = await sablier.getSablierAmount("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9")
    // console.log(amr, "line 70");

    am1 = await sablier.calculateFinalvotingPower("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9");
    console.log(am1.toString(), "am1 calling values ");


      // deploy ozg contract 
    og = await ethers.getContractFactory("OZGovernorEOVX");
    governor = await og.deploy( 
      governor.name,
      token_address,
      timelock_address,
      governor.votingDelay,
      governor.votingPeriod,
      governor.proposalThreshold,
      governor.quorumNumerator,
      governor.voteExtension,
      sablier_address
      );

      const calldata = token.interface.encodeFunctionData("mint", [owner.address, 1000n]);

      // Propose
      const proposalTx = await governor.propose(
          [token_address], // targets 
          [0n], // value
          [calldata],
          "Proposal to mint 1000 tokens for admin"// description
      );


      expect(proposalTx).to.emit(governor, "ProposalCreated");

    // Wait for the transaction to be mined
    const receipt = await proposalTx.wait(1);

    // console.log("proposalId", receipt?.logs);

    const eventLogs = (receipt?.logs ?? []).filter((log) => true);

    // Find the ProposalCreated event in the transaction receipt
    const event = eventLogs.find((log) => log.fragment.name === "ProposalCreated");

    const logDescription = governor.interface.parseLog({
        topics: event?.topics ? [...event.topics] : [],
        data: event?.data ?? "",
    });

    // Get the proposalId from the event arguments
    const proposalId = logDescription?.args["proposalId"];
    console.log(proposalId, "proposalId");
     // try to cast before voting delay and fails
    // await expect( governor.connect(owner).castVoteuser("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9",proposalId, 1)).to.be.reverted;
      console.log(await sablier.aggregateOverflowVotes());
      console.log(await governor.proposalDeadline(proposalId), "proposalDeadline")
   
    //  const numberOfBlocks = Number(await governor.votingDelay()) + 100;
    //  await mineBlocks(numberOfBlocks);

     console.log(await time.latest(), "time before ");
     await network.provider.send("evm_increaseTime", [86400]) // Increase time by 2 Days => 86400 * 2 => 172800
     await network.provider.send("evm_mine")
     console.log(await time.latest(), "time after ");
    //  Vote
     await expect( governor.castVoteuser("0x4b15Fa59ba3e46F20e3D43CF30a9693944E1B1D9",proposalId, 1n)).to.emit(governor, "VoteCast");

  });
});
