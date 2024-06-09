require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      viaIR: true
    }
  },
  networks: {
    sepolia: {
      url : 'https://ethereum-sepolia.publicnode.com',
      accounts: ['4141be2614fa25bab42c8a70429c61f68858295519ca06943d54b960574ec82a']
    },
      hardhat: {	
        timeOut: 40000,
        forking: {
          url: 'https://eth-sepolia.g.alchemy.com/v2/PmTh8MEvJXyQAkSIQ1a9JfhrMJEk9sC_',//"https://polygon-mumbai.g.alchemy.com/v2/O1KOV2z4K0eLZzDILA7Yhu4QVlw64YyY",
          accounts:['4141be2614fa25bab42c8a70429c61f68858295519ca06943d54b960574ec82a']
        }
      }
  },
};
