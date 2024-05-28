const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Staking Contract", function () {
  let Staking, staking, Token, token, owner, addr1, addr2, sabiler, Sabiler;
  const rewardRate = ethers.utils.parseUnits("1", 18); // Define your reward rate

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy mock Sabiler contract
    Sabiler = await ethers.getContractFactory("Sablier");
    sabiler = await Sabiler.attach('0xC5d8AF88Efa244E831D86c7cE3874eab2f1eD4Ae');
    // console.log("Contract Sablier deployed to: ",sabiler.address);

    Token = await ethers.getContractFactory("ERC20Mock");
    token = await Token.deploy();
    // console.log("Contract ERC20 deployed to: ", token.address);

    // Deploy the staking contract
    Staking = await ethers.getContractFactory("Governance");
    staking = await Staking.deploy(token.address, rewardRate, sabiler.address);
    // console.log("Contract Staking deployed to: ",staking.address);

    // Mint tokens to addr1 and addr2
    await token.mint(addr1.address, ethers.utils.parseUnits("1000", 18));
    await token.mint(addr2.address, ethers.utils.parseUnits("1000", 18));
  });

  describe("Deposit", function () {
    it("should allow user to deposit tokens", async function () {

      await token.connect(addr1).approve(staking.address, ethers.utils.parseUnits("10", 18));
      await staking.connect(addr1).deposit(addr1.address, ethers.utils.parseUnits("10", 18));

      expect(await staking.staked(addr1.address)).to.equal(ethers.utils.parseUnits("10", 18));
      expect(await staking.totalStaked()).to.equal(ethers.utils.parseUnits("10", 18));

      await expect(staking.connect(addr1).deposit(addr1.address, 0)).to.be.revertedWith("Amount must be greater than 0");
    });

    it("should emit Deposited event on successful deposit", async function () {
      await token.connect(addr1).approve(staking.address, ethers.utils.parseUnits("10", 18));
      await expect(staking.connect(addr1).deposit(addr1.address, ethers.utils.parseUnits("10", 18)))
        .to.emit(staking, "Deposited")
        .withArgs(addr1.address, ethers.utils.parseUnits("10", 18));
    });
  });

  describe("Claim", function () {
    it("should allow user to claim rewards", async function () {
      const tx = await token.connect(addr1).approve(staking.address, ethers.utils.parseUnits("10", 18));
      await tx.wait();
      await staking.connect(addr1).deposit(addr1.address, ethers.utils.parseUnits("10", 18));

      // Increase time by 1000 seconds to accumulate rewards
      await ethers.provider.send("evm_increaseTime", [1000]);
      await ethers.provider.send("evm_mine");

      const reward = 10;
      await expect(staking.connect(addr1).claim())
        .to.emit(staking, "Claimed")
        .withArgs(addr1.address, BigInt(reward));
    });

    it("should revert if no tokens staked", async function () {
      await expect(staking.connect(addr1).claim()).to.be.revertedWith("No tokens staked");
    });
  });

  describe("Withdraw", function () {
    it("should allow user to withdraw staked tokens", async function () {
      const tx = await token.connect(addr1).approve(staking.address, ethers.utils.parseUnits("10", 18));
      await tx.wait();
      await staking.connect(addr1).deposit(addr1.address, ethers.utils.parseUnits("10", 18));

      // Increase time by 1000 seconds to accumulate rewards
      await ethers.provider.send("evm_increaseTime", [1000]);
      await ethers.provider.send("evm_mine");

      const reward = ethers.utils.parseUnits("10", 18).mul(rewardRate).div(BigInt(1e36));

      await staking.connect(addr1).User_withdraw();

      expect(await token.balanceOf(addr1.address)).to.equal(ethers.utils.parseUnits("100", 18).add(reward));
      expect(await staking.staked(addr1.address)).to.equal(0);
    });

    it("should revert if no tokens staked", async function () {
      await expect(staking.connect(addr1).User_withdraw()).to.be.revertedWith("No tokens staked");
    });

    it("should revert if account is locked", async function () {
      await token.connect(addr1).approve(staking.address, ethers.utils.parseUnits("10", 18));
      await staking.connect(addr1).deposit(addr1.address, ethers.utils.parseUnits("10", 18));

      await staking.connect(addr1).lock();

      await expect(staking.connect(addr1).User_withdraw()).to.be.revertedWith("Account is locked");
    });
  });

  describe("Admin functions", function () {
    it("should allow owner to unlock all accounts", async function () {
      await token.connect(addr1).approve(staking.address, ethers.utils.parseUnits("10", 18));
      await staking.connect(addr1).deposit(addr1.address, ethers.utils.parseUnits("10", 18));

      await staking.connect(addr1).lock();

      await staking.connect(owner).emergencyunlock();

      expect(await staking.Islocked(addr1.address)).to.be.false;
    });

    it("should revert emergencyunlock if not called by owner", async function () {
      await expect(staking.connect(addr1).emergencyunlock()).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe("Reward addition", function () {
    it("should allow adding rewards and update reward rate", async function () {
      const rewardAmount = ethers.utils.parseUnits("50", 18);
      await token.mint(owner.address, rewardAmount);
      await token.allowance(staking.address, rewardAmount);
      await staking.connect(owner).addReward(rewardAmount);

      const newRewardRate = rewardRate.add(rewardAmount.div(await staking.totalStaked()));
      expect(await staking.rewardRate()).to.equal(newRewardRate);
    });

    it("should emit RewardAdded event on adding reward", async function () {
      const rewardAmount = ethers.utils.parseUnits("50", 18);
      await token.mint(owner.address, rewardAmount);
      await token.allowance(staking.address, rewardAmount);
      await expect(staking.connect(owner).addReward(rewardAmount))
        .to.emit(staking, "RewardAdded")
        .withArgs(rewardAmount);
    });
  });
});