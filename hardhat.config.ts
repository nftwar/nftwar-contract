import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    baobab: {   
      url: `https://public-node-api.klaytnapi.com/v1/baobab`,
      accounts: [process.env.PRIVATE_KEY || ''],
      chainId: 1001,
    },
    cypress: {   
      url: `https://public-node-api.klaytnapi.com/v1/cypress`,
      accounts: [process.env.PRIVATE_KEY || ''],
      chainId: 8217,
      gasPrice: 250_000_000_000,
    }
  },
};

export default config;
