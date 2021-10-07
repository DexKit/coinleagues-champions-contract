// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import hre  from "hardhat";
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  // On Mumbai
 

  const Champions = await hre.ethers.getContractFactory("CoinsLeagueChampions");
  const champions  = await Champions.deploy();

  await champions.deployed();
  console.log("Champions deployed to:", champions.address);
  // Premine all the champions
  for (let index = 0; index < 150; index++) {
      await champions.premine();
  }

   // Should mint first round
   for (let index = 0; index < 150; index++) {
    await champions.premine();
}


 
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
