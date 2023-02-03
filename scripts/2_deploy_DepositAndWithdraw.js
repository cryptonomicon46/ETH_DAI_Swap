const { parse } = require("dotenv");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  //   const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; //Mainnet WETH contract address
  const WETH_ADDRESS = "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6"; //Goerli WETH contract address

  const DepositAndWithdraw = await ethers.getContractFactory(
    "DepositAndWithdraw"
  );
  const depositAndWithdraw = await DepositAndWithdraw.deploy(WETH_ADDRESS);

  console.log(
    "DepositAndWithdraw contract depoloyed at %s using the %s WETH contract deployed ",
    depositAndWithdraw.address,
    WETH_ADDRESS
  );

  console.log("\n");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
