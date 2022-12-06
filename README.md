
Uniswap V3 functions implemented: 
1.ETH-> DAI  ExactInputSingle swap
2.ETH-> DAI -> USDC ExactInput Multi Hop swap



Setup Instructions
npm install
npx hardhat accounts
npx hardhat clean
npx hardhat compile

npx hardhat test
npx hardhat node
node scripts/accounts.js
npx hardhat run accounts.js
npx hardhat help


$ npm init
$ npm add --save-dev hardhat
$ npx hardhat init

Get an Alchemy key to run a forked verison of mainnet on your local node

npx hardhat node --fork https://eth-mainnet.alchemyapi.io/v2/<API_KEY>

To targed a specific blcknumber
npx hardhat node --fork https://eth-mainnet.alchemyapi.io/v2/<API_KEY> --fork-block-number 16091924

To run all the tests
npx hardhat test 


To test a specific test file 
npx hardhat test ./test/test_SwapETH2DAI.js --network localhost


To test a specific "IT" in a selected test file
npx hardhat test ./test/test_SwapETH2DAI2USDC.js --grep "Contract Deployed" --network localhost
npx hardhat test ./test/test_SwapETH2DAI2USDC.js --grep "USDC amountOut" --network localhost



  Goerli DAI/ETH POOL 
  https://info.uniswap.org/#/pools/0x60594a405d53811d3bc4766596efd80fd545a270

To deploy your scripts on Goerli or local forked node

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


