# Basic Uniswap Integration Environment
Learn to build your first on chain integration here: https://uniswap.org/blog/your-first-uniswap-integration. 


To  Install and run this project. Please use the following scripts

npm install
npx hardhat accounts
npx hardhat clean
npx hardhat compile

npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

$ npm init
$ npm add --save-dev hardhat
$ npx hardhat init

$ npm add @uniswap/v3-periphery @uniswap/v3-core
// ...
module.exports = {
  solidity: "0.7.6",
};

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';


node modules not found error message debug
Solution:
 cd node_modules/@uniswap/v3-periphery
 npm i 
npx hardhat compile


yarn add -D @uniswap/v3-periphery@1.4.1

npx hardhat node --fork https://eth-mainnet.alchemyapi.io/v2/VkI6gaibszVwSRaLk5KVSkYKe1YPmiSa
npx hardhat node --fork https://eth-mainnet.alchemyapi.io/v2/VkI6gaibszVwSRaLk5KVSkYKe1YPmiSa --fork-block-number 16091924
npx hardhat test 


or  to test on localhost

npx hardhat test --network localhost OR
npx hardhat test --network hardhat 


npx hardhat accounts // after adding the tasks script for accounts in the hardhat config file
npx hardhat run accounts.js

TEST OUTPUT
WETH_ADDRESS: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
DAI_ADDRESS: 0x6B175474E89094C44Da98b954EedeAC495271d0F
SwapRouterAddress: 0xE592427A0AEce92De3Edee1F18E0157C05861564


  SimpleSwap
Simple swap contract address: 0x707531c9999AaeF9232C8FEfBA31FBa4cB78d84a
Owner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 
 WETH_BAL: '10.0' 
 DAI_BAL:  '0.0'
DAI Balance after: 1266.7159750795943
    ✔ Test ExactInputSingle swap function! (3701ms)
Simple swap contract address: 0x707531c9999AaeF9232C8FEfBA31FBa4cB78d84a
Owner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 
 WETH_BAL: '10.0' 
 DAI_BAL:  '0.0'
DAI Balance after: 5000
Owner WETH refund amount= 6.052524122454706
    ✔ Test ExactOutputSwap function! (888ms)


  2 passing (5s)



  Goerli DAI/ETH POOL 
  https://info.uniswap.org/#/pools/0x60594a405d53811d3bc4766596efd80fd545a270

Deploy scripts

npx hardhat run scripts/deploly.js --network goerli
OUTPUT>
Deploying contracts with the account: 0xC5AE1dd3c4bBC7bD1f7260A4AC1758eb7c38C021
Deployer account 0xC5AE1dd3c4bBC7bD1f7260A4AC1758eb7c38C021 balance is '2.498698766861562921' ETH
SimpleSwap address: 0x3CEa950Ae49291836f7a8a656b4Ddd4f003E08dC
SwapETH2DAI address: 0x3d680E71a582324441Cde75f6335b9Bb01580cf2


npx hardhat run scripts/deploly.js --network hardhat
OUTPUT>
Deploying contracts with the account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployer account 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 balance is '10000.0' ETH
SimpleSwap address: 0x707531c9999AaeF9232C8FEfBA31FBa4cB78d84a
SwapETH2DAI address: 0x2538a10b7fFb1B78c890c870FC152b10be121f04


npx hardhat test --network goerli

UNISWAP TESTNET
https://app.uniswap.org/#/swap


npx hardhat node --fork https://eth-mainnet.g.alchemy.com/v2/VkI6gaibszVwSRaLk5KVSkYKe1YPmiSa


npx hardhat node https://eth-goerli.g.alchemy.com/v2/5xH3uo4WsYGg7XQSRqktvZWVyrFM5_Fu


npx hardhat test --grep one

npx hardhat test ./test/test_SwapETH2DAI.js
npx hardhat test ./test/test_SwapETH2DAI2USDC.js --grep ContractDeployed

npx hardhat test ./test/test_SwapETH2DAI2USDC.js --grep "USDC amountOut" --network localhost