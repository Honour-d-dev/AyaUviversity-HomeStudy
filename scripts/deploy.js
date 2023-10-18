const hre = require("hardhat");

async function main() {
  const crowdFund = await hre.ethers.deployContract("CrowdFund");

  await crowdFund.waitForDeployment();

  console.log(`crowdfund deployed at ${crowdFund.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
