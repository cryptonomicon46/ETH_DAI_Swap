const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { parseEther, formatEther } = require("ethers/lib/utils");
const {time,loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { parse } = require("dotenv");



const DECIMAL = 18;
const NAME = "Fusion";
const SYMBOL = "ION";

// We connect to the Contract using a Provider, so we will only
// have read-only access to the Contract


describe("ION Token Tests", function () {


    async function deployTokenFixture() {

    [owner,addr1,addr2] = await ethers.getSigners();
    const  FusionToken = await ethers.getContractFactory("FusionToken");
    const fusionToken = await FusionToken.deploy();
    await fusionToken.deployed();

    console.log("Contract Address:", fusionToken.address);
    console.log("Deployer Address", owner.address );
    
    return {fusionToken, owner, addr1,addr2};
    }   


  it("Contract Deployed: check contract address to be a proper address", async function () {
    
    const {fusionToken} = await loadFixture(deployTokenFixture);
    expect(fusionToken.address).to.be.a.properAddress;
  });

  it("Name: check the name of the token", async function () {
    
    const {fusionToken} = await loadFixture(deployTokenFixture);
    expect(await fusionToken.name()).to.be.equal(NAME);
  });
   

  it("Symbol: check the symbol of the token", async function () {
    
    const {fusionToken} = await loadFixture(deployTokenFixture);
    expect(await fusionToken.symbol()).to.be.equal(SYMBOL);
  });

  it("Owner intial balance: check owner's initial balance", async function () {
    
    const {fusionToken, owner} = await loadFixture(deployTokenFixture);

    const owner_tokenBal = await fusionToken.balanceOf(owner.address);
    console.log(owner_tokenBal);
    expect(owner_tokenBal).to.equal('0');

  });



  it("Check Decimal: Check the decimal places for the Fusion token.", async function() {
    const {fusionToken, owner} = await loadFixture(deployTokenFixture);
    const decimal = await fusionToken.decimal();
    console.log(decimal);
    expect(decimal).to.be.equal(DECIMAL);
})

it("Check owner address: Confirm the contract owner address.", async function() {
    const {fusionToken, owner} = await loadFixture(deployTokenFixture);
    expect(await fusionToken.owner()).to.be.equal(owner.address);
})

it("Mint Fail: Addr1 account tries to mint tokens", async function() {
    const {fusionToken,addr1} = await loadFixture(deployTokenFixture);
    await expect(fusionToken.connect(addr1).mint(addr1.address, 1000)).
    to.be.revertedWith("Caller is not the owner");


})

it("Mint Success: Owner is allowed to mint tokens, check owner balance", async function() {
    const {fusionToken, owner} = await loadFixture(deployTokenFixture);
    await expect(fusionToken.connect(owner).mint(owner.address,1000)).
    to.emit(fusionToken,"Transfer");

     const ownerBal = await fusionToken.balanceOf(owner.address);
    // console.log(ownerBal);
    expect(ownerBal).to.be.equal(1000);

})


it("Check TotalSupply after Mint: Check the total circulation supply of the Fusion token.", async function() {
    const {fusionToken, owner} = await loadFixture(deployTokenFixture);
    await expect(fusionToken.connect(owner).mint(owner.address,1000)).
    to.emit(fusionToken,"Transfer");


    const totalSupply = await fusionToken.totalSupply();
     expect(totalSupply).to.be.equal(1000);

  })


it("Burn Fail: Burn operation can only be initiated by the deployer", async function(){
    const {fusionToken,addr1} = await loadFixture(deployTokenFixture);
    await expect(fusionToken.connect(addr1).burn(addr1.address, 1000)).
    to.be.revertedWith("Caller is not the owner");
})
   

it("Burn Success: Owner is allowed to burn tokens", async function() {
    const {fusionToken, owner} = await loadFixture(deployTokenFixture);
    await expect(fusionToken.connect(owner).mint(owner.address,1000)).
    to.emit(fusionToken,"Transfer");

     const ownerBal = await fusionToken.balanceOf(owner.address);
    // console.log(ownerBal);
    expect(ownerBal).to.be.equal(1000);

    await expect(fusionToken.connect(owner).burn(owner.address,500)).
    to.emit(fusionToken,"Transfer");

    const new_ownerBal = await fusionToken.balanceOf(owner.address);
    // console.log(ownerBal);
    expect(new_ownerBal).to.be.equal(500);

})



it("Mint and transfer: Owner mints tokens, transfers some tokens to addr1", async function() {
    const {fusionToken, owner,addr1} = await loadFixture(deployTokenFixture);
    await expect(fusionToken.connect(owner).mint(owner.address,1000)).
    to.emit(fusionToken,"Transfer");

    const ownerBal = await fusionToken.balanceOf(owner.address);
    // console.log(ownerBal);
    expect(ownerBal).to.be.equal(1000);

    await expect(fusionToken.connect(owner.address).transfer(addr1.address,1001)).
    to.be.revertedWith("INSUFFICIENT_FOR_TRANSFER");

    await expect(fusionToken.connect(owner).transfer(addr1.address,1000)).
    to.emit(fusionToken,"Transfer");

    const new_ownerBal = await fusionToken.balanceOf(owner.address);
    // console.log(new_ownerBal);
    expect(new_ownerBal).to.be.equal(0);

    const addr1_newBal = await fusionToken.balanceOf(addr1.address);
    expect(addr1_newBal).to.be.equal(1000);


})
   
it("Allowance fail: Owner mints tokens, transfers some tokens to addr1", async function() {
    const {fusionToken, owner,addr1,addr2} = await loadFixture(deployTokenFixture);
    await expect(fusionToken.connect(owner).mint(owner.address,1000)).
    to.emit(fusionToken,"Transfer");

    const ownerBal = await fusionToken.balanceOf(owner.address);
    // console.log(ownerBal);
    expect(ownerBal).to.be.equal(1000);

    await expect(fusionToken.connect(addr1.address).transferFrom(owner.address, addr2.address,100)).
    to.be.revertedWith("INSUFFICIENT_ALLOWANCE");

 


})
it("Allowance Pass: Owner mints tokens, sets allowance for addr1, addr1 transfers to addr1 from Owner ", async function() {

    const {fusionToken, owner,addr1} = await loadFixture(deployTokenFixture);
    await expect(fusionToken.connect(owner).mint(owner.address,1000)).
    to.emit(fusionToken,"Transfer");
    
    const ownerBal = await fusionToken.balanceOf(owner.address);
    // console.log(ownerBal);
    expect(ownerBal).to.be.equal(1000);


    await expect(fusionToken.approve(addr1.address,500)).
    to.emit(fusionToken,"Approval");
    
    const allowance_addr1 = await fusionToken.allowance(owner.address,addr1.address);
    expect(allowance_addr1).to.equal(500);

    
})


it("Allowance Transfer: Owner mints tokens, sets allowance for addr1, addr1 transfers to addr1 from Owner ", async function() {

    const {fusionToken, owner,addr1} = await loadFixture(deployTokenFixture);
    await expect(fusionToken.connect(owner).mint(owner.address,1000)).
    to.emit(fusionToken,"Transfer");
    
    const ownerBal = await fusionToken.balanceOf(owner.address);
    // console.log(ownerBal);
    expect(ownerBal).to.be.equal(1000);


    await expect(fusionToken.approve(addr1.address,500)).
    to.emit(fusionToken,"Approval");
    
    const allowance_addr1 = await fusionToken.allowance(owner.address,addr1.address);
    expect(allowance_addr1).to.equal(500);

    
})



it("TransferFrom: Owner sets allowance to addr1, addr1 transfers to addr2, check all balances", async function () {
    const {fusionToken, owner,addr1,addr2} = await loadFixture(deployTokenFixture);
    await expect(fusionToken.connect(owner).mint(owner.address,1000)).
    to.emit(fusionToken,"Transfer");
    
    const ownerBal = await fusionToken.balanceOf(owner.address);
    // console.log(ownerBal);
    expect(ownerBal).to.be.equal(1000);


    await expect(fusionToken.approve(addr1.address,500)).
    to.emit(fusionToken,"Approval");
    
    const allowance_addr1 = await fusionToken.allowance(owner.address, addr1.address);
    expect(allowance_addr1).to.equal(500);

    await expect(fusionToken.connect(addr1).transferFrom(owner.address, addr2.address, 250)).
    to.emit(fusionToken,"Transfer");

    const new_allowance_addr1 = await fusionToken.allowance(owner.address,addr1.address);
    expect(new_allowance_addr1).to.equal(250);

        
    const addr2_bal = await fusionToken.balanceOf(addr2.address);
    // console.log(ownerBal);
    expect(addr2_bal).to.be.equal(250);


    const new_ownerBal = await fusionToken.balanceOf(owner.address);
    // console.log(ownerBal);
    expect(new_ownerBal).to.be.equal(750);

})





});

