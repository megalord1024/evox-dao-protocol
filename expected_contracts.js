const { ethers } = require("ethers");

const getExpectedContractAddress = async (deployer, actionsAfter) => {
  const deployerAddress = await deployer.target;
  const adminAddressTransactionCount = await deployer.Nonce;

  const expectedContractAddress = ethers.getCreate2Address({
    from: deployerAddress,
    nonce: adminAddressTransactionCount + actionsAfter,
  });
  console.log(expectedContractAddress , "meow");
  return expectedContractAddress;
};

module.exports = { getExpectedContractAddress };
