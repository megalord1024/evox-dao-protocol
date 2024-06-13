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

  let args = [
			config.token.name,
			config.token.symbol,
			deployer,
			deployer,
			deployer,
		]

    const token = await ethers.getContractFactory("EvoxToken");
    const contract = await token.connect(deployerSigner).deploy(
      config.token.name,
			config.token.symbol,
			config.token.admin,
			config.token.pauser,
			config.token.minter
    );
    const contractAddress = await contract.getAddress();

    // const tdBlock = token.
		const tdBlock = await hre.ethers.provider.getBlock("latest");

		console.log(`\nToken contract: `, contractAddress);
		// verify cli
		let verify_str =
			`npx hardhat verify ` +
			`--network ${hre.network.name} ` +
			`${contractAddress} "${config.token.name}" "${config.token.symbol}" ${config.token.admin} ${config.token.pauser} ${config.token.minter}`;
		
		console.log("\n" + verify_str + "\n");
		// save it to a file to make sure the user doesn't lose it.
		fs.appendFileSync(
			"contracts.out",
			`${new Date()}\nToken contract deployed at: ${await contractAddress}` +
			` - ${hre.network.name} - block number: ${tdBlock?.number}\n${verify_str}\n\n`
		);
};

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });