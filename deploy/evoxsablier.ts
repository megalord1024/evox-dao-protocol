import { ethers, network} from "hardhat";

import { config } from "../deploy.config"
import fs from "fs";
import hre from 'hardhat'

async function main() {
	// const signer = await hre.ethers.getSigner()

	const [deployerSigner] = await ethers.getSigners();
	const deployer = await deployerSigner.getAddress();

  console.log("=================Deploying Sablier=====================");
  console.log("deployer", deployer);

  const sablier = await ethers.getContractFactory("EvoxSablier");
  const contract = await sablier.connect(deployerSigner).deploy(
    config.Sablier.admin,
    config.Sablier.governor,
    config.Sablier.sablier_contract_sepolia,
    config.Sablier.token,
    config.Sablier.quorum
  );
  const contractAddress = await contract.getAddress();

  // const tdBlock = token.
  const tdBlock = await hre.ethers.provider.getBlock("latest");

  console.log(`\nVETOER Governor contract: `, contractAddress);
		// verify cli
	let verify_str =
    `npx hardhat verify ` +
    `--network ${hre.network.name} ` +
    `${contractAddress} "${config.Sablier.admin}" "${config.Sablier.governor}" "${config.Sablier.sablier_contract_sepolia}" "${config.Sablier.token}" "${config.Sablier.quorum}"`
  console.log("\n" + verify_str + "\n");


  // save it to a file to make sure the user doesn't lose it.
  fs.appendFileSync(
    "contracts.out",
    `${new Date()}\nSablier contract deployed at: ${contractAddress}` +
    ` - ${hre.network.name} - block number: ${tdBlock?.number}\n${verify_str}\n\n`
  );
};

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });