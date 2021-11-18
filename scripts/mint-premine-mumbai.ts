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
  const championsAddress = "0xA3cE3c35Cd032e0343d10248FFDD706c64e13619"

  const Champions = await hre.ethers.getContractFactory("CoinLeagueChampionsMumbai");
  const champions  = await Champions.attach(championsAddress);
  let mine;

  for (let index = 0; index < 1000; index++) {
    mine = await champions.preMineTo('0x69be1977431935eEfCEb3cb23A682Dd1b601A1D4')
    await mine.wait()
    console.log('pre mined %d', index)
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
