import "dotenv/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import "hardhat-gas-reporter";
import type { HardhatUserConfig } from "hardhat/config";
import { vars } from "hardhat/config";
import { getChainConfig } from "./chain.config";

/* ========== TASKS ===========*/
import "./tasks/expect_contract";
// import { json } from "hardhat/internal/core/params/argumentTypes";

/* ========== DATA FROM .env ===========*/
// Private key
const ACCOUNT0_PRIVATE_KEY = vars.get("ACCOUNT0_PRIVATE_KEY", process.env.ACCOUNT0_PRIVATE_KEY || "");
const ACCOUNT1_PRIVATE_KEY = vars.get("ACCOUNT1_PRIVATE_KEY", process.env.ACCOUNT1_PRIVATE_KEY || "");
const ACCOUNT2_PRIVATE_KEY = vars.get("ACCOUNT2_PRIVATE_KEY", process.env.ACCOUNT2_PRIVATE_KEY || "");
const ACCOUNT3_PRIVATE_KEY = vars.get("ACCOUNT3_PRIVATE_KEY", process.env.ACCOUNT3_PRIVATE_KEY || "");
const ACCOUNT4_PRIVATE_KEY = vars.get("ACCOUNT4_PRIVATE_KEY", process.env.ACCOUNT4_PRIVATE_KEY || "");

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          metadata: {
            // Not including the metadata hash
            bytecodeHash: "none",
          },
          // Disable the optimizer when debugging
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  sourcify: {
    enabled: true
  },
  etherscan: {
    // To get the correct names needed run:
    // npx hardhat verify --list-networks
    apiKey: {
      // Etherscan keys
      mainnet: vars.get("ETHERSCAN_API_KEY", process.env.ETHERSCAN_API_KEY || ""),
      sepolia: vars.get("ETHERSCAN_API_KEY", process.env.ETHERSCAN_API_KEY || ""),
      polygon: vars.get("POLYGONSCAN_KEY", process.env.POLYGONSCAN_KEY || ""),
      polygonMumbai: vars.get("POLYGONSCAN_KEY", process.env.POLYGONSCAN_KEY || ""),
      polygonAmoy: vars.get("POLYGONSCAN_KEY", process.env.POLYGONSCAN_KEY || ""),
      avalanche: vars.get("SNOWTRACE_KEY", process.env.SNOWTRACE_KEY || ""),
      avalancheFujiTestnet: vars.get("SNOWTRACE_KEY", process.env.SNOWTRACE_KEY || ""),
      optimisticEthereum: vars.get("OPT_ETHERSCAN_KEY", process.env.OPT_ETHERSCAN_KEY || ""),
      arbitrumOne: vars.get("ARBISCAN_API_KEY", process.env.ARBISCAN_API_KEY || ""),
      bsc: vars.get("BSCSCAN_KEY", process.env.BSCSCAN_KEY || ""),
      xdai: vars.get("GNOSISSCAN_KEY", process.env.GNOSISSCAN_KEY || ""),
      base: vars.get("BASESCAN_KEY", process.env.BASESCAN_KEY || ""),
      zkevm: vars.get("POLYGONSCAN_ZKEVM_KEY", process.env.POLYGONSCAN_ZKEVM_KEY || ""),
    },
    // the name you setup in customchains must be also added above.
    customChains: [
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: "https://basescan.io/api",
          browserURL: "https://basescan.io",
        },
      },
      {
        network: "zkevm",
        chainId: 1101,
        urls: {
          apiURL: "https://api-zkevm.polygonscan.com/api",
          browserURL: "https://zkevm.polygonscan.com",
        },
      },
    ],
  },
  networks: {
    localhost: {
      url: "http://localhost:8545",
      accounts: [ACCOUNT0_PRIVATE_KEY],
    },
    hardhat: {
      forking: {
        url: 'https://eth-sepolia.g.alchemy.com/v2/PmTh8MEvJXyQAkSIQ1a9JfhrMJEk9sC_', //"https://polygon-mumbai.g.alchemy.com/v2/O1KOV2z4K0eLZzDILA7Yhu4QVlw64YyY",
        // url: process.env.sepolia_url
      },
      
      accounts: [
        { privateKey: ACCOUNT0_PRIVATE_KEY, balance: '1000000000000000000000' },
        { privateKey: ACCOUNT1_PRIVATE_KEY, balance: '1000000000000000000000' },
        { privateKey: ACCOUNT2_PRIVATE_KEY, balance: '1000000000000000000000' },
        { privateKey: ACCOUNT3_PRIVATE_KEY, balance: '1000000000000000000000' },
        { privateKey: ACCOUNT4_PRIVATE_KEY, balance: '1000000000000000000000' },
      ],
    },
    ganache: {
      url: "http://localhost:7545",
      accounts: [ACCOUNT0_PRIVATE_KEY],
    },
    // Ethereum mainnet config
    ethereum: getChainConfig("ethereum"),
    // Sepolia testnet config
    sepolia: getChainConfig("sepolia"),
    // Polygon (Matic) - networks
    polygon: getChainConfig("polygon"),
    // Mumbai testnet config
    mumbai: getChainConfig("polygon-mumbai"),
    // Avalanche mainnet config
    avalanche: getChainConfig("avalanche"),
    // Fuji testnet config
    fuji: getChainConfig("avalanche-fuji"),
    // Optimism - networks
    // Optimism mainnet config
    optimism: getChainConfig("optimism"),
    // Arbitrum One mainnet config
    arbitrum: getChainConfig("arbitrum"),
    arbitrumNova: getChainConfig("arbitrum-nova"),
    // Binance mainnet config
    binance: getChainConfig("bsc"),
    // Gnosis
    gnosis: getChainConfig("gnosis"),
    // ZKSYNC
    zksync: getChainConfig("zkSync-era"),
    amoy: getChainConfig("polygon-amoy"),
    // Polygon ZkEVM
    zkevm: getChainConfig("polygon-zkEVM"),
    // Linea
    linea: getChainConfig("linea"),
    // Linea testnet
    lineaTestnet: getChainConfig("linea-testnet"),
    // Mantle
    mantle: getChainConfig("mantle"),
    // Mantle testnet
    mantleTestnet: getChainConfig("mantle-testnet"),
    // Kroma
    kroma: getChainConfig("kroma"),
    // Kroma testnet
    kromaTestnet: getChainConfig("kroma-testnet"),
    // Shimmer
    shimmerEVM: getChainConfig("shimmerEVM"),
    // Shimmer testnet
    shimmerEVMTestnet: getChainConfig("shimmerEVM-testnet"),
    // Scroll
    scroll: getChainConfig("scroll"),
    // Scroll testnet
    scrollSepolia: getChainConfig("scroll-sepolia"),
    // Base
    base: getChainConfig("base"),
    // Moonbeam
    moonbeam: getChainConfig("moonbeam"),
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./tests",
  },
  typechain: {
    outDir: "types",
    target: "ethers-v6",
  },
};

export default config;
