const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { parseEther, formatEther } = require("ethers/lib/utils");
const {time,loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { parse } = require("dotenv");


const DECIMAL = 18;
const NAME = "Wrapped Ether Test";
const SYMBOL = "WETH-Test";

// We connect to the Contract using a Provider, so we will only
// have read-only access to the Contract


describe("Wrapped Ether ERC20 Token Tests", function () {


    async function deployTokenFixture() {

    [owner,addr1,addr2] = await ethers.getSigners();
    const  WETH_TOKEN = await ethers.getContractFactory("WETH");
    const weth_token = await WETH_TOKEN.deploy();
    await weth_token.deployed();

    console.log("Contract Address:", weth_token.address);
    console.log("Deployer Address", owner.address );
    
    return {weth_token, owner, addr1,addr2};
    }   


  it("Contract Deployed: check contract address to be a proper address", async function () {
    
    const {weth_token} = await loadFixture(deployTokenFixture);
    expect(weth_token.address).to.be.a.properAddress;
  });

  it("Name: check the name of the token", async function () {
    
    const {weth_token} = await loadFixture(deployTokenFixture);
    expect(await weth_token.name()).to.be.equal(NAME);
  });
   

  it("Symbol: check the symbol of the token", async function () {
    
    const {weth_token} = await loadFixture(deployTokenFixture);
    expect(await weth_token.symbol()).to.be.equal(SYMBOL);
  });

  it("Intial balance: check owner's initial balance", async function () {
    
    const {weth_token, owner} = await loadFixture(deployTokenFixture);

    const owner_initialBal = await weth_token.balanceOf(owner.address);
    console.log(owner_initialBal);
    expect(owner_initialBal).to.equal('0');

  });


  
  it("Check Decimal: Check the decimal places for the Fusion token.", async function() {
    const {weth_token} = await loadFixture(deployTokenFixture);
    const decimal = await weth_token.decimal();
    console.log(decimal);
    expect(decimal).to.be.equal(DECIMAL);
})

it("Check owner address: Confirm the contract owner address.", async function() {
    const {weth_token,owner} = await loadFixture(deployTokenFixture);
    expect(await weth_token.owner()).to.be.equal(owner.address);
})




it("Deposit ETH: Sender deposits ETH to be wrapped into WETH", async function() {
    const {weth_token, owner,addr1,addr2} = await loadFixture(deployTokenFixture);

    const owner_initialBal = await weth_token.balanceOf(owner.address);
    expect(owner_initialBal).to.equal('0');

    await expect(weth_token.deposit({value: parseEther("1.0")})).
    to.emit(weth_token,"Deposit");


    const owner_NewBal = await weth_token.balanceOf(owner.address);
    expect(ethers.utils.formatUnits(owner_NewBal,18)).to.equal("1.0");

});


it("Withdraw Fail: Initially no WETH should be available to withdraw", async function() {
    const {weth_token, owner,addr1,addr2} = await loadFixture(deployTokenFixture);


    const owner_initialBal = await weth_token.balanceOf(owner.address);
    expect(owner_initialBal).to.equal('0');


    await expect(weth_token.withdraw(1)).
    to.be.revertedWith("NOTHING_TO_WITHDRAW");

    await expect(weth_token.deposit({value: parseEther("1.0")})).
    to.emit(weth_token,"Deposit");

});

it("Withdraw Success: Deposit some ETH->WETH and then withdraw", async function() {
    const {weth_token, owner,addr1,addr2} = await loadFixture(deployTokenFixture);


    const owner_initialBal = await weth_token.balanceOf(owner.address);
    expect(owner_initialBal).to.equal('0');


    await expect(weth_token.withdraw(1)).
    to.be.revertedWith("NOTHING_TO_WITHDRAW");

    await expect(weth_token.deposit({value: parseEther("1.0")})).
    to.emit(weth_token,"Deposit");


    const owner_NewBal = await weth_token.balanceOf(owner.address);
    expect(ethers.utils.formatUnits(owner_NewBal,18)).to.equal("1.0");

    await expect(weth_token.withdraw(parseEther("1.0"))).
    to.emit(weth_token,"Withdraw");


    const owner_NewBal2 = await weth_token.balanceOf(owner.address);
    expect(ethers.utils.formatUnits(owner_NewBal2,18)).to.equal("0.0");


});



});

