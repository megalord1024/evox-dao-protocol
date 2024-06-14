export const config:any = {
  // Configuration for the deployment
  // Change the values for a more personalized deployment
  token: {
    name: "EVOX Token",
    symbol: "EVOX",
    admin: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021",
    pauser: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021",
    minter: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021"
  },
  // Timelock
  timelock: {
    minDelay: 8400, // 12 days (assuming 12 seconds per block)
    proposer: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021",
    executer: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021",
    admin: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021"
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

    timelock: "0x96D8f92E4474a57c5eF6A864D0CCeDC961e32F75",
    sablier: "0xCe78c9b2606B44BF4f8b98da1a773B2c52F38003",
    token: "0x0AB64B82178369B4Dc5e31f67cf0fA10dB927285",
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
  init: {
    token: "0x0AB64B82178369B4Dc5e31f67cf0fA10dB927285", 
    governor: "0x47DbFeFA6027c286bdf293A6F78e9F49B72048fd",
    timelock: "0x96D8f92E4474a57c5eF6A864D0CCeDC961e32F75",
    sablier: "0xCe78c9b2606B44BF4f8b98da1a773B2c52F38003",
    user1: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    user2: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021",
    amount1: 10000_000000000000000000n,
    amount2: 10000_000000000000000000n
  },

  Sablier: {
    name : "sablier",
    sablier_contract_sepolia : "0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301",
    quorum : 1000_000000000000000000n,
    admin: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021",
    governor: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021",
    token: "0x0AB64B82178369B4Dc5e31f67cf0fA10dB927285"
  }
}
