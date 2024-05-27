const { ethers, upgrades } = require("hardhat");

async function deploy(){
    const [account1] = await ethers.getSigners();
    const Sablier = await ethers.getContractFactory("Sablier");
    // const sablier = await Sablier.deploy("0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301");
    const sablier = await Sablier.attach('0xC5d8AF88Efa244E831D86c7cE3874eab2f1eD4Ae');
    console.log("Contract Sablier deployed to: ",await sablier.getAddress());

    const Staking = await ethers.getContractFactory("Staking");
    const staking = await Staking.attach('0x88d1A8bb63746C4C7398899e5719D8C9e14F657B');
    // const staking = await Staking.deploy("0x3cFd5E5fd2e9709dCB04986A634deB00861fF97e","1000000000000000000","0xC5d8AF88Efa244E831D86c7cE3874eab2f1eD4Ae");
    console.log("Contract Staking deployed to: ",await staking.getAddress());
    
    const withdrawnAmount1 = await staking.getWithdrawnAmount(2966);
    const withdrawnAmount2 = await staking.getWithdrawnAmount(2967);
    console.log("Withdrawn amount are: ", withdrawnAmount1, withdrawnAmount2);

    const depositedAmount1 = await staking.getRemainingDepositedAmount(2966);
    const depositedAmount2 = await staking.getRemainingDepositedAmount(2967)
    console.log("Deposited amount are: ", depositedAmount1, depositedAmount2);
}
deploy();