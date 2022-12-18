const { parse } = require("dotenv");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

const ETH_ADDRESS = "0x73bFE136fEba2c73F441605752b2B8CAAB6843Ec";
const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const SwapRouterAddress = "0xE592427A0AEce92De3Edee1F18E0157C05861564"; 

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("\nDeploying contracts with the account:", deployer.address);
    const deployerBal = await deployer.getBalance();

    // console.log("Account balance:", (await deployer.getBalance()).toString());
    console.log("Deployer account %s balance is %o ETH",deployer.address, ethers.utils.formatEther(deployerBal));

    // const SwapETH2DAI = await ethers.getContractFactory("SwapETH2DAI");
    // const swapeth2dai = await SwapETH2DAI.deploy(DAI_ADDRESS,ETH_ADDRESS,SwapRouterAddress);
    // console.log("SwapETH2DAI address:", swapeth2dai.address);
    // console.log("\n");


    const FusionToken = await ethers.getContractFactory("FusionToken");
    const fusionToken = await FusionToken.deploy();
    console.log("Fusion token depoloyed at ", fusionToken.address);
    console.log("\n");


  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });