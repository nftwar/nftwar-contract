import { ethers } from "hardhat";

async function main() {
  const NFTWARbetaPARTSFactory = await ethers.getContractFactory("NFTWARbetaPARTS");
  const NFTWARbetaPARTS = await NFTWARbetaPARTSFactory.deploy("https://nftwar.games/api/v1/nftwarbetaparts/metadata/");

  await NFTWARbetaPARTS.deployed();

  console.log(NFTWARbetaPARTS.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
