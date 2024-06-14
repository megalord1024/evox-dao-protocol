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
    minDelay: 20, // 12 days (assuming 12 seconds per block)
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
    votingDelay: 0,
    // 50400 is 7 days (assuming 12 seconds per block)
    votingPeriod: 30,
    // Threshold to be able to propose
    proposalThreshold: 0, // Set a non-zero value to prevent proposal spam.

    timelock: "0x3d7899242AcDaB1dd9b612648Af39e17342647e7",
    sablier: "0x2B700747B7417f64E563453f553222ab35B65748",
    token: "0x058b1c749226B562Fa2Af4ddDec882b9F151946A",
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
    token: "0x058b1c749226B562Fa2Af4ddDec882b9F151946A", 
    governor: "0x1c14246cf9b2FFfD4A6396493F085BF73C85218E",
    timelock: "0x3d7899242AcDaB1dd9b612648Af39e17342647e7",
    sablier: "0x2B700747B7417f64E563453f553222ab35B65748",
    user1: "0xFcFB312FD2f225798e01f23c11a5861f4A732216",
    user2: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021",
    amount1: 10000_000000000000000000n,
    amount2: 10000_000000000000000000n
  },

  Sablier: {
    name : "sablier",
    sablier_contract_sepolia : "0x7a43F8a888fa15e68C103E18b0439Eb1e98E4301",
    quorum : 1000_000000000000000000n,
    admin: "0x33D33E756cB06b81fF0E861C0f071D3ae7E75021",
    governor: "0x1c14246cf9b2FFfD4A6396493F085BF73C85218E",
    token: "0x058b1c749226B562Fa2Af4ddDec882b9F151946A"
  }
}