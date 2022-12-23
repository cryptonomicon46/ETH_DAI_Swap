
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


npx hardhat test ./test/test_FusionToken.js --network localhost


  Goerli DAI/ETH POOL 
  https://info.uniswap.org/#/pools/0x60594a405d53811d3bc4766596efd80fd545a270

To deploy your scripts on Goerli or local forked node

npx hardhat run scripts/deploy.js --network goerli
OUTPUT>
Deploying contracts with the account: 0xC5AE1dd3c4bBC7bD1f7260A4AC1758eb7c38C021
Deployer account 0xC5AE1dd3c4bBC7bD1f7260A4AC1758eb7c38C021 balance is '2.498698766861562921' ETH
SimpleSwap address: 0x3CEa950Ae49291836f7a8a656b4Ddd4f003E08dC
SwapETH2DAI address: 0x3d680E71a582324441Cde75f6335b9Bb01580cf2


npx hardhat run scripts/deploy.js --network hardhat
OUTPUT>
Deploying contracts with the account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Deployer account 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 balance is '10000.0' ETH
SimpleSwap address: 0x707531c9999AaeF9232C8FEfBA31FBa4cB78d84a
SwapETH2DAI address: 0x2538a10b7fFb1B78c890c870FC152b10be121f04


Verify your contracts on etherscan
npm install --save-dev @nomiclabs/hardhat-etherscan
require("@nomiclabs/hardhat-etherscan");
npx hardhat verify --network mainnet DEPLOYED_CONTRACT_ADDRESS "Constructor argument 1"

Fusion Token on goerli:
npx hardhat verify "0xa28Aae128E9193D659De6d25e4979499c41E9c19" --network goerli
Verified contract:
https://goerli.etherscan.io/address/0xa28Aae128E9193D659De6d25e4979499c41E9c19#code



DEPLOY SwapContract.sol on Goerli

 npx hardhat test ./test/test_SwapContract.js --network localhost --grep "Wrap All ETH"
 npx hardhat test ./test/test_SwapContract.js --network localhost --grep "Wrap Some ETH"
npx hardhat test ./test/test_SwapContract.js --network localhost
WETH has different addresses for Mainnet/Goerli
Goerli WETH: 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
Mainnet WETH: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

Goerli
npx hardhat run scripts/deploy.js --network goerli
npx hardhat verify "0x83E7dfDDFB62382449c436BF034137236C599a1F" "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6" "0x6B175474E89094C44Da98b954EedeAC495271d0F" "0xE592427A0AEce92De3Edee1F18E0157C05861564" --network goerli
https://goerli.etherscan.io/address/0x83E7dfDDFB62382449c436BF034137236C599a1F#code

Mainnet
npx hardhat run scripts/deploy.js --network mainnet
npx hardhat verify "" "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2" "0x6B175474E89094C44Da98b954EedeAC495271d0F" "0xE592427A0AEce92De3Edee1F18E0157C05861564" --network goerli

Wrap_UnWrapETH on Goerli
npx hardhat run scripts/deploy.js --network goerli
npx hardhat verify "0x017Bafc85843e4B13c90338323782752dc88Cb03" "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6" --network goerli

https://goerli.etherscan.io/address/0x017Bafc85843e4B13c90338323782752dc88Cb03#code
DEPLOLY WETH contract onto Goerli

npx hardhat test ./test/test_WETH.js --network localhost
npx hardhat run scripts/deploy.js --network goerli
npx hardhat verify "0x5040f2eBc736656a03c971Cfa7dfF005cf2084b7" --network goerli
https://goerli.etherscan.io/address/0x5040f2eBc736656a03c971Cfa7dfF005cf2084b7#code

DEPLOY WETH ON MAINNET

Deploying contracts with the account: 0xC5AE1dd3c4bBC7bD1f7260A4AC1758eb7c38C021
Deployer account 0xC5AE1dd3c4bBC7bD1f7260A4AC1758eb7c38C021 balance is '0.037732853772326136' ETH
WETH contract depoloyed at  0xd5aCB47829e407aD67BA3A1423e7ce387995D703
npx hardhat verify "0xd5aCB47829e407aD67BA3A1423e7ce387995D703" --network mainnet
https://etherscan.io/address/0xd5aCB47829e407aD67BA3A1423e7ce387995D703#code



SWAP DAI TO ETH
 npx hardhat test ./test/test_SwapToWEth.js --network localhost --grep "Contract Deployed"


