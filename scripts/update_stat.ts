import { ethers } from "hardhat";
import { Contract, BigNumber } from "ethers"
import { parse } from "csv-parse/sync";
import fs from "fs"

import NFT from "../artifacts/contracts/beta/beta_nft.sol/NFTWARbetaPARTS.json"

const NFT_ADDRESS = "0xbD557213066076568E003927034f5a8dD997E215";

async function updateInfo(){
    const accounts = await ethers.getSigners();
    const admin = accounts[0];

    const nft = new Contract(NFT_ADDRESS, NFT.abi, admin);

    fs.readFile("scripts/data.csv", 'utf8', async function (err, data) {
        const records = parse(data, {
            columns: true,
            skip_empty_lines: true,
        });

        const result = {
            DEF: [],
            ATK: [],
        }

        // @ts-ignore
        records.forEach(record => {
            // @ts-ignore
            result.DEF.push(Number(record.Defense)),
            // @ts-ignore
            result.ATK.push(Number(record.Attack))
        });

        for(let i = 0; i < 20; i++){
            console.log(`${i*1000}....`)
            const def =  result.DEF.splice(i*1000, 1000);
            const atk =  result.ATK.splice(i*1000, 1000);

            let res = await nft.setDEF(i*1000, def);
            await res.wait()

            res = await nft.setATK(i*1000, atk);
            await res.wait()
        }
    });
}

updateInfo().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

