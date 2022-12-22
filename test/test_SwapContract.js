const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { parseEther, formatEther } = require("ethers/lib/utils");
const {time,loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { parse } = require("dotenv");


const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
// const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; //Mainnet WETH contract address
const WETH_ADDRESS = "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6"; //Goerli WETH contract address

const SwapRouterAddress = "0xE592427A0AEce92De3Edee1F18E0157C05861564"; 

const DAI_DECIMALS = 18; 
console.log("DAI_ADDRESS:", DAI_ADDRESS);
console.log("WETH_ADDRESS:", WETH_ADDRESS);
console.log("SWAP_ROUTER_ADDRESS:", SwapRouterAddress);

const ercAbi = [
  // Read-Only Functions
  "function balanceOf(address owner) external view returns (uint256)",
  // Authenticated Functions
  "function transfer(address to, uint amount) returns (bool)",
  "function allowance(address owner, uint spender) returns (uint)",
  "function deposit() public payable",
  "function approve(address spender, uint256 amount) returns (bool)",
  "event Transfer(address indexed _from, address indexed _to, uint256 _value)",
"event Approval(address indexed _owner, address indexed _spender, uint256 _value)"

];


// We connect to the Contract using a Provider, so we will only
// have read-only access to the Contract


describe("SwapContract", function () {


    async function deploySwapFixture() {

    [owner,addr1,addr2] = await ethers.getSigners();
    const  SwapContract = await ethers.getContractFactory("SwapContract");
    const swapContract = await SwapContract.deploy(WETH_ADDRESS,DAI_ADDRESS,SwapRouterAddress);
    await swapContract.deployed();
    const WETH = new ethers.Contract(WETH_ADDRESS, ercAbi, owner);
    const DAI = new ethers.Contract(DAI_ADDRESS, ercAbi, owner);
    console.log("DAI Contract Address:",DAI.address);
    console.log("GETH Contract Address:",WETH.address);
    return {swapContract, owner, WETH,DAI};
    }   


  it("Contract Deployed: Deploy contract and check for proper address!", async function () {
    
    const {swapContract, owner,WETH,DAI} = await loadFixture(deploySwapFixture);
    expect(swapContract.address).to.be.a.properAddress;

  });





    it("Wrap Some ETH And Swap: Only uses amountTOUse to wrap Wraps ETH to WETH and emits an event", async function() {
        const {swapContract, owner,WETH,DAI} = await loadFixture(deploySwapFixture);

        // await (swapContract.WrapETH({value: parseEther("1.0")}));
        const bal0 = await owner.getBalance();
        console.log(formatEther(bal0,18));
        await expect(swapContract.SwapSomeETH_DAI(parseEther("0.25"),{value: parseEther("1.0")})).
        to.emit(swapContract,"SwapCompleted");

        const bal1 = await owner.getBalance();
        console.log(formatEther(bal1,18));
        const balDelta = formatEther((bal0- bal1).toString(),18);
        console.log("Amount Used for Swap:",balDelta);
        await expect(Number(balDelta)).to.be.lessThanOrEqual(0.26);
        
    })

    it("Wrap All ETH: swap must complete and emit event, check DAI balance after the swap!", async function () {
        const {swapContract, owner,WETH,DAI} = await loadFixture(deploySwapFixture);
    
        const owner_DAI_bal_before = await DAI.balanceOf(owner.address);
        const DAIBalanceBefore = Number(ethers.utils.formatUnits
            (owner_DAI_bal_before, 18))
    
    // const amountOUT  =  await swapETH2DAI.SwapETHToDai({ value: parseEther("1") })

    const tx =  await swapContract.SwapAllETH_DAI({ value: parseEther("1") });
    const rc = await tx.wait(); // 0ms, as tx is already confirmed
    const event = rc.events.find(event => event.event === 'SwapCompleted');
    const [value] = event.args;
    console.log("SwapCompleted event value:",value);

    const owner_DAI_bal_after = await DAI.balanceOf(owner.address);
    const DAIBalanceAfter = Number(ethers.utils.formatUnits
        (owner_DAI_bal_after, 18))

    console.log("DAI BALANCE BEFORE THE SWAP:",formatEther(owner_DAI_bal_before));

    console.log("DAI BALANCE AFTER SWAP:",formatEther(owner_DAI_bal_after));

        expect(DAIBalanceAfter).to.be.greaterThan(DAIBalanceBefore);

        // expect(value).to.be.equal(owner_DAI_bal_after);

 
    });




    it("Swap DAI-WETH: Only uses amountTOUse to wrap Wraps ETH to WETH and emits an event", async function() {
        const {swapContract, owner,WETH,DAI} = await loadFixture(deploySwapFixture);

        // await (swapContract.WrapETH({value: parseEther("1.0")}));
        const bal0 = await DAI.balanceOf(owner.address);
        console.log("User's DAI balance:",formatEther(bal0,18));

        await expect(swapContract.SwapDAI_WETH(1000)).
        to.emit(swapContract,"SwapCompleted");

        // const bal1 = await owner.getBalance();
        // console.log(formatEther(bal1,18));
        // const balDelta = formatEther((bal0- bal1).toString(),18);
        // console.log("Amount Used for Swap:",balDelta);
        // await expect(Number(balDelta)).to.be.lessThanOrEqual(0.251);
        
    })
   
  


});

