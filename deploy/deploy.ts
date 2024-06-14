import { DeployFunction, DeployResult } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

import { config } from "../deploy.config"
import fs from "fs";
import { EvoxToken, TimelockController, EvoxSablier } from "../types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	console.log("\x1B[37mDeploying Open Zepellin Governance contracts");

	// DEPLOY
	const { deploy } = hre.deployments;

	// const signer = await hre.ethers.getSigner()
	const [deployerSigner] = await hre.ethers.getSigners();
	const deployer = await deployerSigner.getAddress();

	let token;
	let timelock;
	let sablier;
	//// deploy token
	// await (async function deployToken() {

		console.log("=================Deploying EvoxToken=====================");

		let args = [
			config.token.name,
			config.token.symbol,
			deployer,
			deployer,
			deployer,
		]

		token = await deploy("EvoxToken", {
			from: deployer,
			contract: "contracts/EvoxToken.sol:EvoxToken",
			args: args,
			log: true,
		});

		// const tdBlock = token.
		const tdBlock = await hre.ethers.provider.getBlock("latest");

		console.log(`\nToken contract: `, token.address);
		// verify cli
		let verify_str =
			`npx hardhat verify ` +
			`--network ${hre.network.name} ` +
			`${token.address} "${config.token.name}" "${config.token.symbol}" ${deployer} ${deployer} ${deployer}`;
		
		console.log("\n" + verify_str + "\n");
		// save it to a file to make sure the user doesn't lose it.
		fs.appendFileSync(
			"contracts.out",
			`${new Date()}\nToken contract deployed at: ${await token.address}` +
			` - ${hre.network.name} - block number: ${tdBlock?.number}\n${verify_str}\n\n`
		);
	// })();
	
	//// deploy timelock
	// await (async function deployTimelock() {

		// governor and timelock as proposers and executors to guarantee that the DAO will be able to propose and execute
		const proposers = [deployer, deployer];
		const executors = [deployer, deployer];
		
		// TIMELOCK CONTRACT
		// INFO LOGS
		console.log("=================Deploying Timelock=====================");

		timelock = await deploy("TimelockController", {
			from: deployer,
			contract: "@openzeppelin/contracts/governance/TimelockController.sol:TimelockController",
			args: [
				config.timelock.minDelay,
				proposers,
				executors,
				deployer,
			],
			log: true,
		});

		const timelockBlock = await hre.ethers.provider.getBlock("latest");

		console.log(`\nTimelock contract: `, timelock.address);

		fs.appendFileSync(
			`arguments_${timelock.address}.js`,
			`module.exports = [` +
			`${config.timelock.minDelay},` +
			`${JSON.stringify(proposers)},` +
			`${JSON.stringify(executors)},` +
			`"${deployer}"` + 
			`];`
		);

		// verify cli command
		const verify_str_timelock = `npx hardhat verify ` +
			`--network ${hre.network.name} ` +
			`--contract "@openzeppelin/contracts/governance/TimelockController.sol:TimelockController" ` +
			`--constructor-args arguments_${timelock.address}.js ` +
			`${timelock.address}\n`;
		console.log("\n" + verify_str_timelock);

		// save it to a file to make sure the user doesn't lose it.
		fs.appendFileSync(
			"contracts.out",
			`${new Date()}\nTimelock contract deployed at: ${await timelock.address
			}` +
			` - ${hre.network.name} - block number: ${timelockBlock?.number}\n${verify_str_timelock}\n\n`
		);
	// })();

	// await(async function deploySablier(){
		console.log("=================Deploying Sablier=====================");

		args = [
			deployer,
			deployer,
			config.Sablier.sablier_contract_sepolia,
			token.address,
			config.Sablier.quorum
		]

		sablier = await deploy("EvoxSablier",{
			from:deployer,
			contract: "contracts/EvoxSablier.sol:EvoxSablier",
			args: args,
			log: true,
		})

		const SablierBlock = await hre.ethers.provider.getBlock("latest");

		console.log(`\nVETOER Governor contract: `, sablier.address);
		// verify cli
		verify_str =
			`npx hardhat verify ` +
			`--network ${hre.network.name} ` +
			`${sablier.address} "${deployer}" "${deployer}" "${config.Sablier.sablier_contract_sepolia}" "${token.address}" "${config.Sablier.quorum}"`
		console.log("\n" + verify_str + "\n");


		// save it to a file to make sure the user doesn't lose it.
		fs.appendFileSync(
			"contracts.out",
			`${new Date()}\nToken contract deployed at: ${sablier.address}` +
			` - ${hre.network.name} - block number: ${SablierBlock?.number}\n${verify_str}\n\n`
		);


	// })();
	//// deploy governor
	// await (async function deployGovernor() {
		
	console.log("=================Deploying Governer=====================");
		let governor: DeployResult;
		args = [
			config.governor.name,
			timelock.address,
			sablier.address,
			token.address,
			config.governor.votingDelay,
			config.governor.votingPeriod,
			config.governor.proposalThreshold,
		]
		governor = await deploy("EvoxGovernor", {
			from: deployer,
			contract: "contracts/EvoxGovernor.sol:EvoxGovernor",
			args: args,
			log: true,
		});


		const govBlock = await hre.ethers.provider.getBlock("latest");

		console.log(`\nVETOER Governor contract: `, governor.address);
		// verify cli
		verify_str =
			`npx hardhat verify ` +
			`--network ${hre.network.name} ` +
			`${await governor.address} "${config.governor.name}" ${timelock.address} ${sablier.address} ${config.governor.votingDelay} ${config.governor.votingPeriod} ${config.governor.proposalThreshold}`
		console.log("\n" + verify_str + "\n");


		// save it to a file to make sure the user doesn't lose it.
		fs.appendFileSync(
			"contracts.out",
			`${new Date()}\nToken contract deployed at: ${governor.address}` +
			` - ${hre.network.name} - block number: ${govBlock?.number}\n${verify_str}\n\n`
		);
	// })();

	// MINTING the first amount and managing roles to remove it to deployer granting it only to the timelock.
	// await(async function mintAndRolesManagement(){

	// 	const token_result = (await hre.ethers.getContractFactory("contracts/EvoxToken.sol:EvoxToken"));
	// 	const token_contract = token_result.attach(token.address) as EvoxToken;
	// 	await token_contract.grantRole(await token_contract.MINTER_ROLE(), timelock.address);
	// 	// Grant the admin role to the receiving address
	// 	await token_contract.connect(deployer).grantRole(await token_contract.DEFAULT_ADMIN_ROLE(), timelock.address);

	// 	const timelocker = (await hre.ethers.getContractFactory("@openzeppelin/contracts/governance/TimelockController.sol:TimelockController"));
	// 	const timelocker_contract = timelocker.attach(timelock.address) as TimelockController;
	// 	await timelocker_contract.connect(deployer).grantRole(await timelocker_contract.PROPOSER_ROLE(), governor.address);
	// 	await timelocker_contract.grantRole(await timelocker_contract.EXECUTOR_ROLE(), governor.address);

	// 	const sablierer = (await hre.ethers.getContractFactory("contracts/EvoxSablier.sol:EvoxSablier"));
	// 	const sablier_contract = sablierer.attach(sablier.address) as EvoxSablier;
	// 	await sablier_contract.grantRole(await sablier_contract.GOVERNOR_ROLE(), governor.address);
	// // })();

		// const token_result = (await hre.ethers.getContractFactory("contracts/EvoxToken.sol:EvoxToken"));
		// const token_contract = token_result.attach("0x841DefF1fce74C889eB2Bb337d77e16c8c46B56d") as EvoxToken;
		// await token_contract.mint("0x33D33E756cB06b81fF0E861C0f071D3ae7E75021", 20000_000000000000000000n);

	// ending line
	fs.appendFileSync(
		"contracts.out",
		"\n\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\" +
		"\n\n"
	);
};

func.id = "deploy_governor"; // id required to prevent reexecution
func.tags = ["ERC20","GOVERNOR","TIMELOCK"];

export default func;
