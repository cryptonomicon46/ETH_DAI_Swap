require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const URL_GOERLI = process.env.URL_GOERLI;
const GOERLI_PROJECT_ID= process.env.API_GOERLI;
const API_KEY = process.env.ETH_API_KEY;
const ALCHEMY_PROJECT_ID = process.env.ALCHEMY_PROJECT_ID;
// require('hardhat-ethernal');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

task(
    "blockNumber",
    "Prints the current block number",
    async (_, { ethers }) => {
      await ethers.provider.getBlockNumber().then((blockNumber) => {
        console.log("Current block number: " + blockNumber);
      });
    }
  );
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.7.6",
  defaultNetwork: "hardhat",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {

    hardhat: {
        forking: {
          url: "https://eth-mainnet.alchemyapi.io/v2/" + ALCHEMY_PROJECT_ID,
  
        }
      },
    goerli: {
      url: "https://goerli.infura.io/v3/" + ALCHEMY_PROJECT_ID,
      accounts: [`0x${PRIVATE_KEY}`]
    }



  },
};
