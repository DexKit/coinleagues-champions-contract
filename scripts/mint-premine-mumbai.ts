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
  const championsAddress = "0x05b93425E4b44c9042Ed97b7A332aB1575EbD25d"

  const Champions = await hre.ethers.getContractFactory("CoinLeagueChampionsMumbai");
  const champions  = await Champions.attach(championsAddress);
  let mine;

  for (let index = 0; index < 10; index++) {
    mine = await champions.preMine()
    await mine.wait()
    console.log('pre mined %d', index)
  }
 

  await champions.deployed();
  console.log("Champions deployed to:", champions.address);
 
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
