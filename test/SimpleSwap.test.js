const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { parseEther, formatEther } = require("ethers/lib/utils");
const {time,loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { parse } = require("dotenv");


const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const DAI_DECIMALS = 18; 
const SwapRouterAddress = "0xE592427A0AEce92De3Edee1F18E0157C05861564"; 
console.log("WETH_ADDRESS:", WETH_ADDRESS);
console.log("DAI_ADDRESS:", DAI_ADDRESS);
console.log("SwapRouterAddress:", SwapRouterAddress);

const ercAbi = [
  // Read-Only Functions
  "function balanceOf(address owner) view returns (uint256)",
  // Authenticated Functions
  "function transfer(address to, uint amount) returns (bool)",
  "function deposit() public payable",
  "function approve(address spender, uint256 amount) returns (bool)",
  "event Transfer(address indexed _from, address indexed _to, uint256 _value)",
"event Approval(address indexed _owner, address indexed _spender, uint256 _value)"

];


const PRIVATE_KEY = process.env.PRIVATE_KEY;

describe("SimpleSwap", function () {


    async function deploySimpleSwapFixture() {


    [owner,addr1,addr2] = await ethers.getSigners();
    const  SimpleSwap = await ethers.getContractFactory("SimpleSwap");
    const simpleswap = await SimpleSwap.deploy(DAI_ADDRESS,
                                                        WETH_ADDRESS,
                                                            SwapRouterAddress);
                                                            // Connect to the network

                                                            //Transfer 10 WETH to signers[0] or owner 

    await simpleswap.deployed();
    let signers = await ethers.getSigners();
    const WETH = new ethers.Contract(WETH_ADDRESS, ercAbi, owner);
    const DAI = new ethers.Contract(DAI_ADDRESS, ercAbi, owner);


    return {simpleswap, owner, addr1,addr2,WETH,DAI};
    }   


  it("Test ExactInputSingle swap function!", async function () {
    
    const {simpleswap, owner, addr1, addr2,WETH,DAI} = await loadFixture(deploySimpleSwapFixture);
    console.log("Simple swap contract address:", simpleswap.address);

    await WETH.deposit({ value: parseEther('10') })

    let owner_WETH_bal = await WETH.balanceOf(owner.address);
    const WETHBalanceBefore = Number(ethers.utils.formatUnits
        (owner_WETH_bal, 18))
    let owner_DAI_bal_before = await DAI.balanceOf(owner.address);
    const DAIBalanceBefore = Number(ethers.utils.formatUnits
        (owner_DAI_bal_before, 18))
    console.log("Owner: %s \n WETH_BAL: %o \n DAI_BAL:  %o",owner.address,
                                            ethers.utils.formatEther(owner_WETH_bal),
                                            ethers.utils.formatEther(owner_DAI_bal_before));

    // /* Check if the simpleswap contract is a valid address 
    expect(simpleswap.address).to.be.a.properAddress;

    /* Check Initial WETH and DAI  Balances */ 
    expect(DAIBalanceBefore).to.be.equal(parseEther("0"));
    expect(WETHBalanceBefore).to.be.greaterThan(0);

    //Swap function will be reverted with "STF" if called before approving to spend the owner's WETH
    await expect(simpleswap.swapETHForDai(parseEther("1")))
    .to.be.revertedWith("STF");

    // /* Approve the simepleswap router contract to spend weth9 for from the owner */
    await expect(WETH.approve(simpleswap.address, parseEther("10"))).
    to.emit(WETH,"Approval").withArgs(owner.address,simpleswap.address,parseEther("10"));
    
    // /* Execute the swap */
    await simpleswap.swapETHForDai(parseEther("1"));

    
    // /* Check the DAI balance after the swap to see if it's greater than before */
    let owner_DAI_bal_after = await DAI.balanceOf(owner.address)
    const DAIBalanceAfter = Number(ethers.utils.formatUnits
        (owner_DAI_bal_after, 18))

    console.log("DAI Balance after:",DAIBalanceAfter);
    expect(DAIBalanceAfter).is.greaterThan(DAIBalanceBefore);

  });


  it ("Test ExactOutputSwap function!", async function () {
    const {simpleswap, owner, addr1, addr2,WETH,DAI} = await loadFixture(deploySimpleSwapFixture);
    console.log("Simple swap contract address:", simpleswap.address);

    await WETH.deposit({ value: parseEther('10') })

    let owner_WETH_bal = await WETH.balanceOf(owner.address);
    const WETHBalanceBefore = Number(ethers.utils.formatUnits
        (owner_WETH_bal, 18))
    let owner_DAI_bal_before = await DAI.balanceOf(owner.address);
    const DAIBalanceBefore = Number(ethers.utils.formatUnits
        (owner_DAI_bal_before, 18))
    console.log("Owner: %s \n WETH_BAL: %o \n DAI_BAL:  %o",owner.address,
                                            ethers.utils.formatEther(owner_WETH_bal),
                                            ethers.utils.formatEther(owner_DAI_bal_before));
    

    // /* Check if the simpleswap contract is a valid address 
    expect(simpleswap.address).to.be.a.properAddress;

    /* Check Initial WETH and DAI  Balances */ 
    expect(DAIBalanceBefore).to.be.equal(parseEther("0"));
    expect(WETHBalanceBefore).to.be.greaterThan(0);

    //Swap function will be reverted with "STF" if called before approving to spend the owner's WETH
    await expect(simpleswap.swapWETHForDai_EOS(parseEther("500"),parseEther("1")))
    .to.be.revertedWith("STF");


    // /* Approve the simepleswap router contract to spend weth9 for from the owner */
    await expect(WETH.approve(simpleswap.address, parseEther("10"))).
    to.emit(WETH,"Approval").withArgs(owner.address,simpleswap.address,parseEther("10"));

    // // //Execute the exact output swap 
    await simpleswap.swapWETHForDai_EOS(parseEther("5000"),parseEther("5"));


    // /* Check the DAI balance to see if it's exactly the expected amount*/
    let owner_DAI_bal_after = await DAI.balanceOf(owner.address)
    const DAIBalanceAfter = Number(ethers.utils.formatUnits
                            (owner_DAI_bal_after, 18))

    console.log("DAI Balance after:",DAIBalanceAfter);
    expect(owner_DAI_bal_after).is.equal(parseEther('5000'));

    //Check the excess WETH refund from the swap contract to the owner
    let owner_WETH_bal_after = await WETH.balanceOf(owner.address);
    const WETHBalanceAfter= Number(ethers.utils.formatUnits(owner_WETH_bal_after,18));
    console.log("Owner WETH refund amount=", WETHBalanceAfter);
    expect(WETHBalanceAfter).to.be.greaterThan(6);



  })




});
