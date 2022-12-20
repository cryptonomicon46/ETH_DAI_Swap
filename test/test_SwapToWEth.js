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


describe("DAI_for_WETH", function () {


    async function deploySwapFixture() {

    [owner,addr1,addr2] = await ethers.getSigners();
    const  SwapDAI_WETH = await ethers.getContractFactory("DAI_for_WETH");
    const swapDAI_WETH = await SwapDAI_WETH.deploy(WETH_ADDRESS,DAI_ADDRESS,SwapRouterAddress);
    await swapDAI_WETH.deployed();
    const WETH = new ethers.Contract(WETH_ADDRESS, ercAbi, owner);
    const DAI = new ethers.Contract(DAI_ADDRESS, ercAbi, owner);
    console.log("DAI Contract Address:",DAI.address);
    console.log("GETH Contract Address:",WETH.address);
    return {swapDAI_WETH, owner, WETH,DAI, addr1};
    }   


  it("Contract Deployed: Deploy contract and check for proper address!", async function () {
    
    const {swapDAI_WETH} = await loadFixture(deploySwapFixture);
    expect(swapDAI_WETH.address).to.be.a.properAddress;

  });



  

    it("Swap: Swaps input amount of DAI to WETH, emits a Swap completed event", async function() {
        const {swapDAI_WETH, owner,WETH,DAI} = await loadFixture(deploySwapFixture);

        // await (swapDAI_WETH.WrapETH({value: parseEther("1.0")}));
        const bal0 = await owner.getBalance();
        console.log(formatEther(bal0,18));

        await DAI.transfer(addr1.address, 100);
        const ownerDaiBal_initial = await DAI.balanceOf(addr1.address);
        console.log("Initial Owner Dai balance",ownerDaiBal_initial);


        await expect(swapDAI_WETH.SwapDAI_WETH(100)).
        to.emit(swapDAI_WETH,"SwapCompleted");

        // const bal1 = await owner.getBalance();
        // console.log(formatEther(bal1,18));
        // const balDelta = formatEther((bal0- bal1).toString(),18);
        // console.log("Amount Used for Swap:",balDelta);
        // await expect(Number(balDelta)).to.be.lessThanOrEqual(0.251);
        
    })

    
  


});

