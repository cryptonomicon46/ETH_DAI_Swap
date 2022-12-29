const { parse } = require("dotenv");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");


async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("\nDeploying WETH and DepositAndWithdraw contract with the account:", deployer.address);
    const deployerBal = await deployer.getBalance();

    // console.log("Account balance:", (await deployer.getBalance()).toString());
    console.log("Deployer account %s balance is %o ETH",deployer.address, ethers.utils.formatEther(deployerBal));


    const WETH = await ethers.getContractFactory("WETH");
    const weth = await WETH.deploy();


    const DepositAndWithdraw = await ethers.getContractFactory("DepositAndWithdraw");
    // const depositAndWithdraw = await DepositAndWithdraw.deploy(GWETH_ADDRESS);
    const depositAndWithdraw = await DepositAndWithdraw.deploy(weth.address);
    console.log("WETH contract depoloyed at ", weth.address);
    console.log("DepositAndWithdraw contract depoloyed at %s using the %s WETH contract deployed ", depositAndWithdraw.address,weth.address);

 
    console.log("\n");

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });