const { parse } = require("dotenv");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

const ETH_ADDRESS = "0x73bFE136fEba2c73F441605752b2B8CAAB6843Ec";
const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const SwapRouterAddress = "0xE592427A0AEce92De3Edee1F18E0157C05861564"; 
const UniswapV3Factory ="0x1F98431c8aD98523631AE4a59f267346ea31F984";
const NonfungiblePositionManager ="0xC36442b4a4522E871399CD717aBDD847Ab11FE88";
const GETH_ADDRESS = "0xc3122c8e8e58c185aab6efaa771e76037889bb3f";

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("\nDeploying contracts with the account:", deployer.address);
    const deployerBal = await deployer.getBalance();

    // console.log("Account balance:", (await deployer.getBalance()).toString());
    console.log("Deployer account %s balance is %o ETH",deployer.address, ethers.utils.formatEther(deployerBal));


    const FusionToken = await ethers.getContractFactory("FusionToken");
    const fusionToken = await FusionToken.deploy();
    console.log("Fusion token depoloyed at ", fusionToken.address);
    console.log("\n");


    const SwapETH2DAI = await ethers.getContractFactory("SwapETH2DAI");
    const swapeth2dai = await SwapETH2DAI.deploy(GETH_ADDRESS,DAI_ADDRESS);


    // const SwapETH2DAI = await ethers.getContractFactory("SwapETH2DAI");
    // const swapeth2dai = await SwapETH2DAI.deploy(fusionToken.address,
                                                    // DAI_ADDRESS,
                                                    // SwapRouterAddress,
                                                    // NonfungiblePositionManager);
    // console.log("SwapETH2DAI address:", swapeth2dai.address);
    // console.log("\n");

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });