
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
npx hardhat run scripts/deploy.js --network goerli

 npx hardhat test ./test/test_SwapContract.js --network localhost --grep "Wrap All ETH"
 npx hardhat test ./test/test_SwapContract.js --network localhost --grep "Wrap Some ETH"
npx hardhat test ./test/test_SwapContract.js --network localhost
WETH has different addresses for Mainnet/Goerli
Goerli WETH: 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
Mainnet WETH: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

Goerli DAI: 0xdc31Ee1784292379Fbb2964b3B9C4124D8F89C60
Mainnet DAI: 0x6B175474E89094C44Da98b954EedeAC495271d0F

Goerli
npx hardhat run scripts/deploy.js --network goerli
npx hardhat verify "0x0cfE6161A5A5B6F9cBff10e5138af79Ba7058ebF" "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6" "0xdc31Ee1784292379Fbb2964b3B9C4124D8F89C60" "0xE592427A0AEce92De3Edee1F18E0157C05861564" --network goerli
https://goerli.etherscan.io/address/0x0cfE6161A5A5B6F9cBff10e5138af79Ba7058ebF#code

Mainnet
npx hardhat run scripts/deploy.js --network mainnet
npx hardhat verify "" "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2" "0x6B175474E89094C44Da98b954EedeAC495271d0F" "0xE592427A0AEce92De3Edee1F18E0157C05861564" --network goerli

DepositAndWithdraw on Goerli
npx hardhat run scripts/2_deploy_DepositAndWithdraw.js --network goerli


Deploying WETH and DepositAndWithdraw contract with the account: 0xC5AE1dd3c4bBC7bD1f7260A4AC1758eb7c38C021
Deployer account 0xC5AE1dd3c4bBC7bD1f7260A4AC1758eb7c38C021 balance is '0.961227081912468166' ETH
WETH contract depoloyed at  0x91761E31588ddB57386225055cE2B993Ae07081f

DepositAndWithdraw contract depoloyed at 0x179760bbBA596FED47F88b38bFA717DECee353cb using the 0x91761E31588ddB57386225055cE2B993Ae07081f WETH contract deployed 



DepositAndWithdraw

npx hardhat verify "0x179760bbBA596FED47F88b38bFA717DECee353cb" "0x91761E31588ddB57386225055cE2B993Ae07081f" --network goerli

https://goerli.etherscan.io/address/0x179760bbBA596FED47F88b38bFA717DECee353cb#code

WETH:
npx hardhat verify "0x91761E31588ddB57386225055cE2B993Ae07081f" --network goerli

https://goerli.etherscan.io/address/0x91761E31588ddB57386225055cE2B993Ae07081f#code



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




Test coverage
yarn add solidity-coverage --dev


npx hardhat coverage --testfiles "test/test_SwapContract.js"

npx hardhat coverage --testfiles "test/*.js"
-------------------------|----------|----------|----------|----------|----------------|
File                     |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
-------------------------|----------|----------|----------|----------|----------------|
 contracts/              |    77.17 |    46.97 |    70.15 |    79.38 |                |
  DepositAndWithdraw.sol |    86.96 |       50 |    76.92 |    89.29 |      90,95,120 |
  FusionToken.sol        |      100 |       65 |      100 |      100 |                |
  IERC20.sol             |      100 |      100 |      100 |      100 |                |
  IWETH.sol              |      100 |      100 |      100 |      100 |                |
  SwapContract.sol       |    78.57 |       50 |    52.63 |    83.33 |... 221,228,235 |
  WETH.sol               |    45.16 |    22.22 |    52.94 |    44.74 |... 147,148,149 |
-------------------------|----------|----------|----------|----------|----------------|
All files                |    77.17 |    46.97 |    70.15 |    79.38 |                |
-------------------------|----------|----------|----------|----------|----------------|


Goerli DAI/ION pool create pool transaction
https://goerli.etherscan.io/tx/0xa5a63fb9de0a1e28e5d2001b4ffef409029a87a513bd4329ca6ad337fee0faac#eventlog
Pool address 0x439b82465cf11b2417daa294C8754F8220039A7A
1  0xa28Aae128E9193D659De6d25e4979499c41E9c19 (ION) -Created by Sandip Nallani
2  0xdc31Ee1784292379Fbb2964b3B9C4124D8F89C60  (DAI) -Not created by me
3. 0x652Aa57D6f51F74605f8D6e78E0c54FE237A22f4 (GDAI) -Created by Sandip Nallani
4. 0x91761E31588ddB57386225055cE2B993Ae07081f (WETH-Test) -Created by Sandip Nallani 
5. 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6  (WETH)
mint() (NonFungiblePositionManager)
https://goerli.etherscan.io/address/0xC36442b4a4522E871399CD717aBDD847Ab11FE88#writeContract


    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }



    GDAI Goerli DAI Token on Goerli
    Deploying GDAI contract with the account: 0xC5AE1dd3c4bBC7bD1f7260A4AC1758eb7c38C021
Deployer account 0xC5AE1dd3c4bBC7bD1f7260A4AC1758eb7c38C021 balance is '0.956202171462879795' ETH
dgai contract depoloyed at  0x652Aa57D6f51F74605f8D6e78E0c54FE237A22f4


npx hardhat verify --contract contracts/GDAI.sol:GDAI "0x652Aa57D6f51F74605f8D6e78E0c54FE237A22f4" --network goerli
https://goerli.etherscan.io/address/0x652Aa57D6f51F74605f8D6e78E0c54FE237A22f4#code


GDAI /WETH pool created using the NonFungiblePositionManager's 'createAndInitializePoolIfNecessary'
Pool address 
 0x1aC7982148eb00d2AaE341326bbAA3952556C119
MintParams (Mint a new position GDAI/WETH)
(0x652Aa57D6f51F74605f8D6e78E0c54FE237A22f4,0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6,3000,-887272,-887272,100,0.01,0,0,0xC36442b4a4522E871399CD717aBDD847Ab11FE88,"")



MintNewPosition on Goerli
https://goerli.etherscan.io/address/0xc1Eb23E95f13B356318b642D591BF593b4a418Aa#code


ION/GDAI Pool created
 0xC3f197daFB3c14923496ADD63B870Ee1CA20e2e3

 ION/WETH Pool created
 0x5a29669fE3CbC95Ce6148e051F9dF90d6413F815


 ION/DAI pool fee:3000
 0x439b82465cf11b2417daa294C8754F8220039A7A


  ION/DAI pool fee:500
 0x98cfDA0Cc69ED7481c0943D6DAcA2D4e5fD0C774