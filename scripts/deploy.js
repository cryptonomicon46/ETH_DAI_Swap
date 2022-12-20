const { parse } = require("dotenv");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const SwapRouterAddress = "0xE592427A0AEce92De3Edee1F18E0157C05861564"; 
const UniswapV3Factory ="0x1F98431c8aD98523631AE4a59f267346ea31F984";
const NonfungiblePositionManager ="0xC36442b4a4522E871399CD717aBDD847Ab11FE88";

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("\nDeploying contracts with the account:", deployer.address);
    const deployerBal = await deployer.getBalance();

    // console.log("Account balance:", (await deployer.getBalance()).toString());
    console.log("Deployer account %s balance is %o ETH",deployer.address, ethers.utils.formatEther(deployerBal));


    // const FusionToken = await ethers.getContractFactory("FusionToken");
    // const fusionToken = await FusionToken.deploy();
    // console.log("Fusion token depoloyed at ", fusionToken.address);
    // console.log("\n");


    const SwapForDai = await ethers.getContractFactory("SwapForDai");
    const swapFordai = await SwapForDai.deploy(WETH_ADDRESS,DAI_ADDRESS,SwapRouterAddress);
    console.log("SwapForDai contract depoloyed at ", swapFordai.address);

    // const WETH = await ethers.getContractFactory("WETH");
    // const weth = await WETH.deploy();
    // console.log("WETH contract depoloyed at ", weth.address);


    console.log("\n");

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });