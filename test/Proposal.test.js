const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DaoFactory and Proposal", function () {
  let DaoFactory, daoFactory, Proposal, proposal, Governance, governance, token, sablier, Sablier;
  let owner, addr1, addr2, moderator, factory;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    DaoFactory = await ethers.getContractFactory("DaoFactory");
    Proposal = await ethers.getContractFactory("Proposal");
    Governance = await ethers.getContractFactory("Governance");
    Sablier = await ethers.getContractFactory("Sablier");
    sablier = await Sablier.attach(
      "0xC5d8AF88Efa244E831D86c7cE3874eab2f1eD4Ae"
    );
    [owner, addr1, addr2, moderator, factory, _] = await ethers.getSigners();

    // Deploy a mock token
    const Token = await ethers.getContractFactory("ERC20Mock");
    token = await Token.deploy();
    await token.deployed();

    // Deploy the Governance contract
    governance = await Governance.deploy(
      token.address,
      100,
      sablier.address,
      factory.address
    );
    await governance.deployed();

    // Deploy the DaoFactory contract
    daoFactory = await DaoFactory.deploy(token.address);
    await daoFactory.deployed();

    // Update the governance address in the factory
    await daoFactory.updateGoverance(governance.address);

    // Mint tokens for users
    await token.mint(owner.address, ethers.utils.parseEther("1000"));
    await token.mint(addr1.address, ethers.utils.parseEther("1000"));
  });

  describe("DaoFactory", function () {
    it("should create a proposal", async function () {
      await daoFactory
        .connect(owner)
        .proposalCreation(
          addr1.address,
          "Test Proposal",
          1000,
          ethers.utils.parseEther("100"),
          addr2.address
        );

      const proposalInfo = await daoFactory.ProposalList(0);
      expect(proposalInfo.creator).to.equal(addr1.address);
      expect(proposalInfo.description).to.equal("Test Proposal");
    });

    it("should revert proposal creation if not called by owner", async function () {
      await expect(
        daoFactory
          .connect(addr1)
          .proposalCreation(
            addr1.address,
            "Test Proposal",
            1000,
            ethers.utils.parseEther("100"),
            addr2.address
          )
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("should update governance address", async function () {
      const newGovernanceAddress = addr1.address;
      await daoFactory.updateGoverance(newGovernanceAddress);
      expect(await daoFactory.governance()).to.equal(newGovernanceAddress);
    });

    it("should revert governance update if not called by owner", async function () {
      await expect(
        daoFactory.connect(addr1).updateGoverance(addr1.address)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe("Proposal", function () {
    beforeEach(async function () {
      await daoFactory
        .connect(owner)
        .proposalCreation(
          addr1.address,
          "Test Proposal",
          1000,
          ethers.utils.parseEther("100"),
          addr2.address
        );

      const proposalInfo = await daoFactory.ProposalList(0);
      proposal = await ethers.getContractAt(
        "Proposal",
        proposalInfo.proposal_address
      );

      await token.mint(addr1.address, ethers.utils.parseEther("100"));
      await token.mint(proposal.address, ethers.utils.parseEther("100"));

      await token
        .connect(addr1)
        .approve(governance.address, ethers.utils.parseEther("100"));
    });

    it("should allow token holders to vote", async function () {
        await governance.connect(owner).addmoderator(proposal.address);
        await governance.connect(addr1).deposit(ethers.utils.parseEther("100"));
      await expect(proposal.connect(addr1).vote(true))
        .to.emit(proposal, "Voted")
        .withArgs(addr1.address, true);

      const finalVotes = await proposal.calculateFinalVotes();
      expect(finalVotes[0]).to.equal(1); // Yes votes
      expect(finalVotes[1]).to.equal(0); // No votes
    });

    it("should revert voting if caller is not a token holder", async function () {
      await expect(proposal.connect(addr2).vote(true)).to.be.revertedWith(
        "Only token holders can perform this action"
      );
    });

    it("should close proposal after voting period ends", async function () {
      await ethers.provider.send("evm_increaseTime", [1001]);
      await ethers.provider.send("evm_mine");

      await proposal.connect(owner).closeProposal();

      const finalVotes = await proposal.calculateFinalVotes();
      expect(finalVotes[0]).to.equal(0); // Yes votes
      expect(finalVotes[1]).to.equal(0); // No votes
    });

    it("should revert closing proposal before voting period ends", async function () {
      await expect(proposal.connect(owner).closeProposal()).to.be.revertedWith(
        "Voting period is not over yet"
      );
    });

    it("should allow withdrawal by owner", async function () {
        const balBefore = await token.balanceOf(owner.address);
      await proposal.connect(owner).withdraw()
      const balAfter = await token.balanceOf(owner.address);
        expect(balAfter).to.equal("1100000000000000000000")
    });

    it("should revert withdrawal by non-owner", async function () {
      await expect(proposal.connect(addr1).withdraw()).to.be.revertedWith(
        "Ownable: caller is not the owner"
      );
    });
  });
});
