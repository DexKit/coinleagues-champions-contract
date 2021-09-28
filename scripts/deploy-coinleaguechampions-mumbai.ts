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
  const LINK_Token	= '0x326C977E6efc84E512bB9C30f76E30c160eD06FB';
  const VRF_Coordinator = '0x8C7382F9D8f56b33781fE506E897a4F1e2d17255';
  const Key_Hash = '0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4';
  // deploy Bitt Testnet token to Mumbai
  const Bitt = await hre.ethers.getContractFactory("Token");
  const bitt  = await Bitt.deploy('Bittoken', 'Bitt', 42000000);
  await bitt.deployed();
  console.log("Bitt deployed to:", bitt.address);
  // deploy Kitt Testnet token to Mumbai
  const Kit = await hre.ethers.getContractFactory("Token");
  const kit  = await Kit.deploy('DexKit', 'KIT', 10000000);
  await kit.deployed();
  console.log("Kitt deployed to:", kit.address);

  const Champions = await hre.ethers.getContractFactory("CoinsLeagueChampionsMumbai");
  const champions  = await Champions.deploy(VRF_Coordinator, LINK_Token, Key_Hash, bitt.address, kit.address);

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
