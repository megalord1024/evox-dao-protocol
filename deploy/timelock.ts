import { ethers, network} from "hardhat";

import { config } from "../deploy.config"
import fs from "fs";
import hre from 'hardhat'

async function main() {
	// const signer = await hre.ethers.getSigner()

	const [deployerSigner] = await ethers.getSigners();
	const deployer = await deployerSigner.getAddress();
  
  console.log("=================Deploying Timelock=====================");
  console.log("deployer", deployer);

  const proposers = [config.timelock.proposer, config.timelock.proposer];
	const executors = [config.timelock.executer, config.timelock.executer];

  const timelock = await ethers.getContractFactory("TimelockController");
  const contract = await timelock.connect(deployerSigner).deploy(
    config.timelock.minDelay,
    proposers,
    executors,
    config.timelock.admin,
  );

  const contractAddress = await contract.getAddress();

  // const tdBlock = token.
  const timelockBlock = await hre.ethers.provider.getBlock("latest");

  fs.appendFileSync(
			`arguments_${contractAddress}.js`,
			`module.exports = [` +
			`${config.timelock.minDelay},` +
			`${JSON.stringify(proposers)},` +
			`${JSON.stringify(executors)},` +
			`"${config.timelock.admin}"` + 
			`];`
		);

		// verify cli command
		const verify_str_timelock = `npx hardhat verify ` +
			`--network ${hre.network.name} ` +
			`--contract "@openzeppelin/contracts/governance/TimelockController.sol:TimelockController" ` +
			`--constructor-args arguments_${contractAddress}.js ` +
			`${contractAddress}\n`;
		console.log("\n" + verify_str_timelock);

		// save it to a file to make sure the user doesn't lose it.
		fs.appendFileSync(
			"contracts.out",
			`${new Date()}\nTimelock contract deployed at: ${contractAddress
			}` +
			` - ${hre.network.name} - block number: ${timelockBlock?.number}\n${verify_str_timelock}\n\n`
		);
};

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });