const { parse } = require("dotenv");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");


async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("\nDeploying MintNewPosition contract with the account:", deployer.address);
    const deployerBal = await deployer.getBalance();

    // console.log("Account balance:", (await deployer.getBalance()).toString());
    console.log("Deployer account %s balance is %o ETH",deployer.address, ethers.utils.formatEther(deployerBal));


    const MintNewPosition = await ethers.getContractFactory("MintNewPosition");
    const mintNewPosition = await MintNewPosition.deploy();
    console.log("mintNewPosition contract depoloyed at ", mintNewPosition.address);

    console.log("\n");

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });