import { ethers } from "hardhat";

async function nft() {
  const NFTWARbetaPARTSFactory = await ethers.getContractFactory("NFTWARbetaPARTS");
  const NFTWARbetaPARTS = await NFTWARbetaPARTSFactory.deploy("https://nftwar.games/api/v1/nftwarbetaparts/metadata/");

  await NFTWARbetaPARTS.deployed();

  console.log(NFTWARbetaPARTS.address);
}

async function battle(){
  const battleFactory = await ethers.getContractFactory("NFTWARbetaBattle");
  const battle = await battleFactory.deploy("0xbD557213066076568E003927034f5a8dD997E215");

  await battle.deployed();

  console.log(battle.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
battle().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
