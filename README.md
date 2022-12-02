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

npx hardhat test --network localhost


npx hardhat accounts // after adding the tasks script for accounts in the hardhat config file
npx hardhat run accounts.js

TEST OUTPUT ON THE LOCAL NODE

WETH_ADDRESS: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
DAI_ADDRESS: 0x6B175474E89094C44Da98b954EedeAC495271d0F
SwapRouterAddress: 0xE592427A0AEce92De3Edee1F18E0157C05861564


  SimpleSwap
Simple swap contract address: 0x707531c9999AaeF9232C8FEfBA31FBa4cB78d84a
Owner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 
 WETH_BAL: '10.0' 
 DAI_BAL:  '0.0'
DAI Balance after: 1267.8589596528466
    ✔ Test ExactInputSingle swap function! (4450ms)
Simple swap contract address: 0x707531c9999AaeF9232C8FEfBA31FBa4cB78d84a
Owner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 
 WETH_BAL: '10.0' 
 DAI_BAL:  '0.0'
DAI Balance after: 5000
Owner WETH refund amount= 6.056082999688875
    ✔ Test ExactOutputSwap function! (932ms)


  2 passing (5s)