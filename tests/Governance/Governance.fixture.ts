import { ethers } from "hardhat";
// import hardhat from "hardhat";

import { getExpectedContractAddress } from "../../helpers/expected_contract";
import { type OZGovernor, type TimelockController, type ERC20Token, ERC20, type Sablier } from "../../types";
import { config } from "../../deploy.config"
import { TimelockController__factory,ERC20Token__factory, OZGovernor__factory , Sablier__factory } from "../../types/factories/contracts";

export async function deployGovernanceContractsFixture(): Promise<{
    token: ERC20Token;
    timelock: TimelockController;
    governor: OZGovernor;
    sablier : Sablier;
}> {
    const signers = await ethers.getSigners();
    const deployerSigner = signers[0];

    // Load values for constructor from a ts file deploy.config.ts
    const governance_address = await getExpectedContractAddress(deployerSigner, 3);
    const timelock_address = await getExpectedContractAddress(deployerSigner, 2);
    const token_address = await getExpectedContractAddress(deployerSigner, 1);
    const sabiler_address = await getExpectedContractAddress(deployerSigner, 0);

    const admin_address = governance_address;

    // TOKEN CONTRACT
    const GovernorToken = (await ethers.getContractFactory("contracts/ERC20Token.sol:ERC20Token")) as ERC20Token__factory
    const token = await GovernorToken.connect(deployerSigner).deploy(
        config.token.name,
        config.token.symbol,
        deployerSigner.address,
        deployerSigner.address,
        deployerSigner.address,
    );

    // TIMELOCK CONTRACT
    const TimelockController:TimelockController__factory =  (await ethers.getContractFactory("contracts/TimelockController.sol:TimelockController")) as TimelockController__factory
    const timelock = await TimelockController.connect(deployerSigner).deploy(
        config.timelock.minDelay,
        [admin_address, timelock_address],
        [admin_address, timelock_address],
        timelock_address,
    );

    const Sablier  = (await ethers.getContractFactory("contracts/sabiler.sol:Sablier")) as Sablier__factory
    const sablier = await Sablier.connect(deployerSigner).deploy(
        "0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301",
        token_address
    );




    // GOVERNOR CONTRACT
    const OZGovernor = (await ethers.getContractFactory("contracts/OZGovernor.sol:OZGovernor")) as OZGovernor__factory
    const governor = await OZGovernor.connect(deployerSigner).deploy(
        config.governor.name,
        token_address,
        timelock_address,
        config.governor.votingDelay,
        config.governor.votingPeriod,
        config.governor.proposalThreshold,
        config.governor.quorumNumerator,
        config.governor.voteExtension,
        sabiler_address
    );

    return { token, timelock, governor, sablier };
}

// export async function deployGovernanceContractsClockTimestampFixture(): Promise<{
//     token: ERC20;
//     timelock: TimelockController;
//     governor: OZGovernor;
// }> {
//     const signers = await ethers.getSigners();
//     const deployerSigner = signers[0];

//     // Load values for constructor from a ts file deploy.config.ts
//     const governance_address = await getExpectedContractAddress(deployerSigner, 2);
//     const timelock_address = await getExpectedContractAddress(deployerSigner, 1);
//     const token_address = await getExpectedContractAddress(deployerSigner, 0);

//     const admin_address = governance_address;

//     // TOKEN CONTRACT
//     const GovernorToken = (await ethers.getContractFactory("contracts/clock/ERC20Token.sol:ERC20Token")) as ERC20Token__factory
//     const token = await GovernorToken.connect(deployerSigner).deploy(
//         config.token.name,
//         config.token.symbol,
//         deployerSigner.address,
//         deployerSigner.address,
//         deployerSigner.address,
//     );

//     // TIMELOCK CONTRACT
//     const TimelockController:TimelockController__factory =  (await ethers.getContractFactory("contracts/TimelockController.sol:TimelockController")) as TimelockController__factory
//     const timelock = await TimelockController.connect(deployerSigner).deploy(
//         config.timelock.minDelay,
//         [admin_address, timelock_address],
//         [admin_address, timelock_address],
//         timelock_address,
//     );

//     // GOVERNOR CONTRACT
//     const OZGovernor = (await ethers.getContractFactory("contracts/clock/OZGovernor.sol:OZGovernor")) as OZGovernor__factory
//     const governor = await OZGovernor.connect(deployerSigner).deploy(
//         config.governor.name,
//         token_address,
//         timelock_address,
//         config.governor.votingDelay,
//         config.governor.votingPeriod,
//         config.governor.proposalThreshold,
//         config.governor.quorumNumerator,
//         config.governor.voteExtension,
//     );

//     return { token, timelock, governor };
// }