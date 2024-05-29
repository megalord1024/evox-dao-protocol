const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Staking Contract", function () {
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
  const rewardRate = ethers.utils.parseUnits("1", 18); // Define your reward rate

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy mock Sabiler contract
    Sablier = await ethers.getContractFactory("Sablier");
    sablier = await Sablier.attach(
      "0xC5d8AF88Efa244E831D86c7cE3874eab2f1eD4Ae"
    );

    Token = await ethers.getContractFactory("ERC20Mock");
    token = await Token.deploy();

    Factory = await ethers.getContractFactory("DaoFactory");
    factory = await Factory.deploy(token.address);

    // Deploy the staking contract
    Governance = await ethers.getContractFactory("Governance");
    governance = await Governance.deploy(
      token.address,
      100,
      sablier.address,
      factory.address
    );
    // console.log("Contract Staking deployed to: ",staking.address);

    // Mint tokens to addr1 and addr2
    await token.mint(owner.address, ethers.utils.parseEther("1000"));
    await token.mint(addr1.address, ethers.utils.parseEther("1000"));
    await token.mint(addr2.address, ethers.utils.parseEther("1000"));
  });

  describe("Staking", function () {
    it("should allow user to deposit tokens", async function () {
      await token
        .connect(addr1)
        .approve(governance.address, ethers.utils.parseEther("100"));
      await expect(
        governance.connect(addr1).deposit(ethers.utils.parseEther("100"))
      )
        .to.emit(governance, "Deposited")
        .withArgs(addr1.address, ethers.utils.parseEther("100"));

      expect(await governance.staked(addr1.address)).to.equal(
        ethers.utils.parseEther("100")
      );
      expect(await governance.totalStaked()).to.equal(
        ethers.utils.parseEther("100")
      );
    });

    it("should revert if deposit amount is zero", async function () {
      await expect(governance.connect(addr1).deposit(0)).to.be.revertedWith(
        "Amount must be greater than 0"
      );
    });

    it("should allow user to withdraw tokens", async function () {
      await token
        .connect(addr1)
        .approve(governance.address, ethers.utils.parseEther("100"));
      await governance.connect(addr1).deposit(ethers.utils.parseEther("100"));

      await expect(governance.connect(addr1).User_withdraw())
        .to.emit(governance, "Withdrawn")
        .withArgs(addr1.address, ethers.utils.parseEther("100"));

      expect(await governance.staked(addr1.address)).to.equal(0);
      expect(await governance.totalStaked()).to.equal(0);
    });

    it("should revert if user has no staked tokens", async function () {
      await expect(
        governance.connect(addr1).User_withdraw()
      ).to.be.revertedWith("No tokens staked");
    });

    it("should revert if user account is locked", async function () {
      await token
        .connect(addr1)
        .approve(governance.address, ethers.utils.parseEther("100"));
      await governance.connect(addr1).deposit(ethers.utils.parseEther("100"));

      await governance.connect(owner).lock(addr1.address);

      await expect(
        governance.connect(addr1).User_withdraw()
      ).to.be.revertedWith("Account is locked");
    });
  });

  describe("Locking", function () {
    it("should allow moderator to lock and unlock user", async function () {
      await token
        .connect(addr2)
        .approve(governance.address, ethers.utils.parseEther("100"));
      await governance.connect(addr2).deposit(ethers.utils.parseEther("100"));

      await governance.connect(owner).addmoderator(addr1.address);

      await governance.connect(addr1).lock(addr2.address);

      expect(await governance.Islocked(addr2.address)).to.equal(true);

      await governance.connect(addr1).unlock(addr2.address);

      expect(await governance.Islocked(addr1.address)).to.equal(false);
    });

    it("should revert if non-moderator tries to lock/unlock user", async function () {
      await token
        .connect(addr2)
        .approve(governance.address, ethers.utils.parseEther("100"));
        await governance.connect(addr2).deposit(ethers.utils.parseEther("100"));

      await expect(
        governance.connect(addr1).lock(addr2.address)
      ).to.be.revertedWith("caller isnt modaertor");
      await expect(
        governance.connect(addr1).unlock(addr2.address)
      ).to.be.revertedWith("caller isnt modaertor");
    });
  });

  describe("Emergency Unlock", function () {
    it("should allow owner to lock and unlock all users", async function () {
      await token
        .connect(addr1)
        .approve(governance.address, ethers.utils.parseEther("100"));
        await governance.connect(addr1).deposit(ethers.utils.parseEther("100"));


      await token
        .connect(addr2)
        .approve(governance.address, ethers.utils.parseEther("100"));
        await governance.connect(addr2).deposit(ethers.utils.parseEther("100"));


      await governance.connect(owner).lock(addr1.address);
      await governance.connect(owner).lock(addr2.address);

      expect(await governance.Islocked(addr1.address)).to.equal(true);
      expect(await governance.Islocked(addr2.address)).to.equal(true);

      await governance.connect(owner).emergencyunlock();

      expect(await governance.Islocked(addr1.address)).to.equal(false);
      expect(await governance.Islocked(addr2.address)).to.equal(false);
    });

    it("should revert if non-owner tries to emergency unlock", async function () {
      await expect(
        governance.connect(addr1).emergencyunlock()
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });

  describe("Roles", function () {
    it("should allow owner to add moderator", async function () {
      await expect(governance.connect(owner).addmoderator(addr1.address))
        .to.emit(governance, "RoleGranted")
        .withArgs(ethers.utils.id("MODAERTOR"), addr1.address, owner.address);
    });

    it("should revert if non-owner or non-factory tries to add moderator", async function () {
      await expect(
        governance.connect(addr1).addmoderator(addr1.address)
      ).to.be.revertedWith("not the owner");
    });
  });
    describe("Sablier", function () {
      it("should return correct withdrawn amount from Sablier", async function () {
          const streamId = 2966;
          const withdrawnAmount =  0;
          expect(await governance.getWithdrawnAmount(streamId)).to.equal(withdrawnAmount);
      });

      it("should return correct remaining deposited amount from Sablier", async function () {
          const streamId = 2966;
          const remainingAmount =  500000000000000000000000n;

          await sablier.setRemainingDepositedAmount(streamId, remainingAmount);
          expect(await governance.getRemainingDepositedAmount(streamId)).to.equal(remainingAmount);
      });
  });
});
