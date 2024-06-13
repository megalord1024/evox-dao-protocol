export const config:any = {
  // Configuration for the deployment
  // Change the values for a more personalized deployment
  token: {
    name: "EVOX",
    symbol: "EVOX",
  },
  // Timelock
  timelock: {
    minDelay: 8400, // 12 days (assuming 12 seconds per block)
  },
  // Set clockMode to true for timestamp mode, false for block number mode
  clockMode: false,
  // Governor
  governor: {
    name: "EVOX DAO",
    // 7200 is 24 hours (assuming 12 seconds per block)
    votingDelay: 7200,
    // 50400 is 7 days (assuming 12 seconds per block)
    votingPeriod: 50400,
    // Threshold to be able to propose
    proposalThreshold: 0, // Set a non-zero value to prevent proposal spam.
  },
  // First Mint is used to mint the initial tokens for this governance
  // It must be higher than the proposalThreshold
  // so there are enough tokens for the governance to be able to propose
  // 
  // ATTENTION:
  // If the amount is not higher than 0, it will not mint any tokens and will also maintain roles for the deployer.
  // Keep it as ZERO if you plan on doing manual changes and mints, before locking it up to be controlled by governor contracts.
  // 
  // After the first mint, the deployer will lose the minter and admin role and give it to the timelock, which is the executor.
  firstMint: {
    amount: 1000000000, // If set higher than zero, it will mint the specified amount of tokens to the address below
    // 'to' is an Ethereum Address. If empty, it will default to the deployer. If incorrect, it will also default to the deployer (a warning will be issued when deploying).
    to: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  },


  Sablier: {
      name : "sablier",
      sablier_contract_sepolia : "0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301",
      quorum : 100_000000000000000000n,
  }
}
