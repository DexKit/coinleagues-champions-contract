import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers, network } from "hardhat";

const PRICE1 = BigNumber.from(110).mul(BigNumber.from(10).pow(18));
const PRICE2 = BigNumber.from(115).mul(BigNumber.from(10).pow(18));
const PRICE3 = BigNumber.from(115).mul(BigNumber.from(10).pow(18));

describe("Champions", function () {
  it("should premine test  and mint all coins after timestamps", async function () {
    const Champions = await ethers.getContractFactory(
      "CoinLeagueChampionsTest"
    );
    const ChainLink = await ethers.getContractFactory("Token");
    const link = ChainLink.attach("0xb0897686c545045aFc77CF20eC7A532E3120E0F1");
    const champions = await Champions.deploy();
    await champions.deployed();
    const [owner, ...rest] = await ethers.getSigners();

    // impersonate account with sufficient WETH to mint all tokens
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x77ceea82E4362dD3B2E0D7F76d0A71A628Cad300"],
    });

    const linkAmount = BigNumber.from(100).mul(BigNumber.from(10).pow(18));

    // impersonate account with LINK on Polygon to send to contract
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0xb7a298189b2c8b703f34cad886e915008c2db738"],
    });
    const linkSigner = await ethers.getSigner(
      "0xb7a298189b2c8b703f34cad886e915008c2db738"
    );
    // At this moment contract now have sufficient amount to use VRF
    await link.connect(linkSigner).transfer(champions.address, linkAmount);
    const balance2 = await link.balanceOf(champions.address);
    console.log(balance2.toString());

    await network.provider.send("hardhat_setBalance", [
      owner.address,
      "0x10000000000000000000000000000000000000000000000000000",
    ]);

    // First round should fail, if no premine was done
    expect(champions.mintFirstRound()).to.be.revertedWith(
      "Need to Premine First"
    );
    //second round should fail, if no premine was done
    expect(champions.mintSecondRound()).to.be.revertedWith(
      "Still tokens on first round"
    );
    let failedMines = 0;

    // let's premine all the amount
    for (let index = 0; index < 20; index++) {
      console.log(index);
      try {
        const mine = await champions.connect(owner).preMine();
        await mine.wait();
        console.log(`allocated rarity`);
        console.log('premining');
      } catch (e) {
        console.log(e);
        failedMines++;
        console.log(`failed: ${index}`);
      }
    }

    // first round
    for (let index = 0; index < 33; index++) {
      console.log(index);
      try {
        const mine = await champions.connect(owner).mintFirstRound({value: PRICE1});
        await mine.wait();
        console.log(`allocated rarity`);
        console.log('mint first');
      } catch (e) {
        console.log(e);
        failedMines++;
        console.log(`failed: ${index}`);
      }
    }

    // second round
    for (let index = 0; index < 33; index++) {
      console.log(index);
      try {
        const mine = await champions.mintSecondRound({value: PRICE2});
        await mine.wait();
        console.log(`allocated rarity`);
        console.log('mint second');
      } catch (e) {
        console.log(e);
        failedMines++;
        console.log(`failed: ${index}`);
      }
    }

    // third round
    for (let index = 0; index < 34; index++) {
      console.log(index);
      try {
        const mine = await champions.mintThirdRound({value: PRICE3});
        await mine.wait();
        console.log('mint third');
        console.log((await champions.getRarityOf(index)).toString());
      } catch (e) {
        console.log(e);
        failedMines++;
        console.log(`failed: ${index}`);
      }
    }

    const mine = await champions.withdrawETH();
    await mine.wait();

    expect((await champions.balanceOf(owner.address)).toString()).to.be.equal("110");

    // let's premine all the amount
    /*  for (let index = 0; index < failedMines; index++) {
      console.log(index);
      try{
         await champions.preMine();
      }catch{
      console.log('failed on recursion')
      }
     }*/

  //  expect((await champions.balanceOf(owner)).toString()).to.be.equal("150");
   // expect(champions.preMine()).to.be.revertedWith("Pre mine supply reached");
    //second round should fail, if no premine was done
    /* expect(champions.mintSecondRound()).to.be.revertedWith(
      "Still tokens on first round"
    );

    // Now we are able to mint and transfer all first round to owner
    for (let index = 0; index < 7850; index++) {
        console.log(index);
      await champions.mintFirstRound();
    }
    expect(champions.mintFirstRound()).to.be.revertedWith(
      "Pre mine supply reached"
    );
    expect((await champions.balanceOf(owner)).toString()).to.be.equal("8000");
    // Let us mint second round
    for (let index = 0; index < 8000; index++) {
        console.log(index);
      await champions.mintSecondRound();
    }
    // As owner minted all tokens it should have all the supply
    expect((await champions.balanceOf(owner)).toString()).to.be.equal("16000");*/
  });
});
