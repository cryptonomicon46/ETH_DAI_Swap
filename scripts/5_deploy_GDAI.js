const { parse } = require("dotenv");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");


async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("\nDeploying GDAI contract with the account:", deployer.address);
    const deployerBal = await deployer.getBalance();

    // console.log("Account balance:", (await deployer.getBalance()).toString());
    console.log("Deployer account %s balance is %o ETH",deployer.address, ethers.utils.formatEther(deployerBal));


    const GDAI = await ethers.getContractFactory("GDAI");
    const gdai = await GDAI.deploy();
    console.log("dgai contract depoloyed at ", gdai.address);

    console.log("\n");

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });