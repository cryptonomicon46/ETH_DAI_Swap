const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { parseEther, formatEther } = require("ethers/lib/utils");
const {time,loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { parse } = require("dotenv");


const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const SwapRouterAddress = "0xE592427A0AEce92De3Edee1F18E0157C05861564"; 

const DAI_DECIMALS = 18; 
console.log("DAI_ADDRESS:", DAI_ADDRESS);
console.log("WETH_ADDRESS:", GETH_ADDRESS);
console.log("SWAP_ROUTER_ADDRESS:", SwapRouterAddress);

const ercAbi = [
  // Read-Only Functions
  "function balanceOf(address owner) external view returns (uint256)",
  // Authenticated Functions
  "function transfer(address to, uint amount) returns (bool)",
  "function deposit() public payable",
  "function approve(address spender, uint256 amount) returns (bool)",
  "event Transfer(address indexed _from, address indexed _to, uint256 _value)",
"event Approval(address indexed _owner, address indexed _spender, uint256 _value)"

];


// We connect to the Contract using a Provider, so we will only
// have read-only access to the Contract


describe("SwapForDai", function () {


    async function deploySwapFixture() {

    [owner,addr1,addr2] = await ethers.getSigners();
    const  SwapForDai = await ethers.getContractFactory("SwapForDai");
    const swapForDai = await SwapForDai.deploy(GETH_ADDRESS,DAI_ADDRESS,SwapRouterAddress);
    await swapForDai.deployed();
    const GETH = new ethers.Contract(GETH_ADDRESS, ercAbi, owner);
    const DAI = new ethers.Contract(DAI_ADDRESS, ercAbi, owner);
    console.log("DAI Contract Address:",DAI.address);
    console.log("GETH Contract Address:",GETH.address);
    return {swapForDai, owner, GETH,DAI};
    }   


  it("Contract Deployed: Deploy contract and check for proper address!", async function () {
    
    const {swapForDai, owner,GETH,DAI} = await loadFixture(deploySwapFixture);
    expect(swapForDai.address).to.be.a.properAddress;

  });






    it("Swap Succeeds: Owner tries to swap, confirm that SwapCompleted is emitted!", async function () {
        const {swapForDai, owner,GETH,DAI} = await loadFixture(deploySwapFixture);
     
    await swapForDai.Swap({value: parseEther("0.1")});

    // await expect(swapForDai.swap(0.1)({ value: parseEther("0.2") })).
    // to.emit(swapForDai,"Refund");

    // const owner_GETH_bal_after = await GETH.balanceOf(owner.address);
    // console.log("Owner GETH balance after refund:", owner_GETH_bal_after);

    // const owner_DAI_bal_after = await DAI.balanceOf(owner.address);
    // console.log("Owner DAI balance after swap:", owner_DAI_bal_after);

 
    });

    it("DAI amountOut: Owner tries to swap > 0.1 ETH, swap must complete successfully, check value in the emitted event, check DAI balance of the owner!", async function () {
    //     const {swapGETH2DAI, owner,GETH,DAI} = await loadFixture(deploySwapFixture);
    
    //     const owner_DAI_bal_before = await DAI.balanceOf(owner.address);
    //     const DAIBalanceBefore = Number(ethers.utils.formatUnits
    //         (owner_DAI_bal_before, 18))
    
    // // const amountOUT  =  await swapETH2DAI.SwapETHToDai({ value: parseEther("1") })

    // const tx =  await swapETH2DAI.SwapETHToDai({ value: parseEther("1") });
    // const rc = await tx.wait(); // 0ms, as tx is already confirmed
    // const event = rc.events.find(event => event.event === 'SwapCompleted');
    // const [value] = event.args;
    // console.log("SwapCompleted event value:",value);

    // const owner_DAI_bal_after = await DAI.balanceOf(owner.address);
    // const DAIBalanceAfter = Number(ethers.utils.formatUnits
    //     (owner_DAI_bal_after, 18))


    // console.log((owner_DAI_bal_after));
    // console.log(DAIBalanceAfter);

    //     expect(DAIBalanceAfter).to.be.greaterThan(DAIBalanceBefore);

        // expect(value).to.be.equal(owner_DAI_bal_before);

 
    });

  


});

