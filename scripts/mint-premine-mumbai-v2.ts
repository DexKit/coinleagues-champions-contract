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
  const championsAddress = "0x15d727080E226F31dDb4730734315aF23A1bcBDe"

  const Champions = await hre.ethers.getContractFactory("CoinLeagueChampionsMumbaiV2");
  const champions  = await Champions.attach(championsAddress);
  let mine;
  mine = await champions.preMine(7);
  await mine.wait()
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
