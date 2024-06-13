import { ethers, network} from "hardhat";

import { config } from "../deploy.config"
import fs from "fs";
import hre from 'hardhat'

import { EvoxToken, TimelockController, EvoxSablier, EvoxGovernor } from "../types";

async function main() {
	// const signer = await hre.ethers.getSigner()

	const [adminSigner] = await ethers.getSigners();
	const admin = await adminSigner.getAddress();

  console.log("=================Dao Init=====================");
  console.log("deployer", admin);

  const token = await ethers.getContractFactory("EvoxToken");
  const token_contract = token.attach(config.init.token) as EvoxToken;
  const token_contract_address = await token_contract.getAddress();

  const timelock = await ethers.getContractFactory("TimelockController");
  const timelock_contract = timelock.attach(config.init.timelock) as TimelockController;
  const timelock_contract_address = await timelock_contract.getAddress();

  const sablier = await ethers.getContractFactory("EvoxSablier");
  const sablier_contract = sablier.attach(config.init.sablier) as EvoxSablier;
  const sablier_contract_address = await sablier_contract.getAddress();

  const governor = await ethers.getContractFactory("EvoxGovernor");
  const governor_contract = governor.attach(config.init.governor) as EvoxGovernor;
  const governor_contract_address = await governor_contract.getAddress();

  await token_contract.connect(adminSigner).grantRole(await token_contract.MINTER_ROLE(), timelock_contract_address);
  await token_contract.connect(adminSigner).grantRole(await token_contract.DEFAULT_ADMIN_ROLE(), timelock_contract_address);

  await timelock_contract.connect(adminSigner).grantRole(await timelock_contract.PROPOSER_ROLE(), governor_contract_address);
  await timelock_contract.connect(adminSigner).grantRole(await timelock_contract.EXECUTOR_ROLE(), governor_contract_address);


  await sablier_contract.connect(adminSigner).grantRole(await sablier_contract.GOVERNOR_ROLE(), governor_contract_address);

  await token_contract.connect(adminSigner).mint(config.init.user1, config.init.amount1);
  await token_contract.connect(adminSigner).mint(config.init.user2, config.init.amount2);
};

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });