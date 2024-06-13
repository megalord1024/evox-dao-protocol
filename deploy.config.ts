export const config:any = {
  // Configuration for the deployment
  // Change the values for a more personalized deployment
  token: {
    name: "EVOX",
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
    votingDelay: 20,
    // 50400 is 7 days (assuming 12 seconds per block)
    votingPeriod: 20,
    // Threshold to be able to propose
    proposalThreshold: 0, // Set a non-zero value to prevent proposal spam.

    timelock: "0x4C0A9FbB133CEE582de526e3c3F88474B38cAB0A",
    sablier: "0xCdEdffa103d61B83ed0851818721839183bdbe66"
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
    token: "0xe3B6344f8e3ea9F57900AFF03d70A065c534453c", 
    governor: "0x83d360C25D94eD7911F83C321aE9736C3D3F3B9c",
    timelock: "0x4C0A9FbB133CEE582de526e3c3F88474B38cAB0A",
    sablier: "0xCdEdffa103d61B83ed0851818721839183bdbe66",
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
      token: "0xe3B6344f8e3ea9F57900AFF03d70A065c534453c"
  }
}
