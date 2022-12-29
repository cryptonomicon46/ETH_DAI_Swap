const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { parseEther, formatEther } = require("ethers/lib/utils");
const {time,loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { parse } = require("dotenv");
const { format } = require("path");




// We connect to the Contract using a Provider, so we will only
// have read-only access to the Contract

const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; //Mainnet WETH contract address
// const WETH_ADDRESS = "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6"; //Goerli WETH contract address

const ercAbi = [
    // Read-Only Functions
    "function balanceOf(address owner) external view returns (uint256)",
    // Authenticated Functions
    "function transfer(address to, uint amount) returns (bool)",
    "function allowance(address owner, uint spender) returns (uint)",
    "function approve(address spender, uint256 amount) returns (bool)",
    "event Transfer(address indexed _from, address indexed _to, uint256 _value)",
  "event Approval(address indexed _owner, address indexed _spender, uint256 _value)"
  
  ];


  const ercAbi_weth = [
    // Read-Only Functions
 
    "function deposit() public payable",
    "function withdraw(uint wad) public",
    "function balanceOf(address owner) external view returns (uint256)",

  ];
describe("Wrap and UnWrap ETH tests", function () {


    async function deployFixture() {

    [owner,addr1,addr2] = await ethers.getSigners();

    const  WETH_TOKEN = await ethers.getContractFactory("WETH");
    const weth_token = await WETH_TOKEN.deploy();
    await weth_token.deployed();

  

    const  DepositAndWithdraw = await ethers.getContractFactory("DepositAndWithdraw");
    // const depositAndWithdraw = await DepositAndWithdraw.deploy(WETH_ADDRESS);
    const depositAndWithdraw = await DepositAndWithdraw.deploy(weth_token.address);
    await depositAndWithdraw.deployed();
   
    const WETH = new ethers.Contract(WETH_ADDRESS, ercAbi_weth, owner);

    // console.log("WETH Contract Address:",WETH.address);
    console.log("WETH Contract Address:", weth_token.address);
    console.log("Contract Address:", depositAndWithdraw.address);
    console.log("Deployer Address", owner.address );
    
    return {depositAndWithdraw, owner, addr1,addr2, weth_token};
    }   


  it("Contract Deployed: check contract address to be a proper address", async function () {

    const {depositAndWithdraw} = await loadFixture(deployFixture);
    expect(depositAndWithdraw.address).to.be.a.properAddress;
  });

  

  it("Wrap ETH: Sender deposits ETH, contract transfers back WETH to sender", async function() {
    const {depositAndWithdraw, owner, addr1,addr2, weth_token} = await loadFixture(deployFixture);

    const owner_InitbalWETH = await weth_token.balanceOf(owner.address);

    await expect(depositAndWithdraw.Wrap_ETH({value: parseEther("1.0")})).
    to.emit(depositAndWithdraw,"deposit").
    withArgs(parseEther("1.0"));
    
    const owner_FinalWETHbal = await weth_token.balanceOf(owner.address);

    console.log("Owner WETH Balance before wrapping:", formatEther(owner_InitbalWETH,18));
    console.log("Owner WETH Balance after wrapping:", formatEther(owner_FinalWETHbal,18));

    const balDelta = formatEther((owner_FinalWETHbal- owner_InitbalWETH).toString(),18);
    expect(balDelta).to.equal("1.0");


    const wethFinalBalanceUser = await depositAndWithdraw.getWETHBalance(owner.address);
    const wethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractWETHBalance();
    expect(wethFinalBalanceUser).to.be.equal(parseEther("1.0"));
    expect(wethFinalBalanceContract).to.be.equal(parseEther("0"));

});



it("UnWrap All WETH-1: Sender tries to withdraw all of the WETH balance", async function() {
    const {depositAndWithdraw, owner, addr1,addr2, weth_token} = await loadFixture(deployFixture);

    // const owner_InitbalWETH = await weth_token.balanceOf(owner.address);


    // await (depositAndWithdraw.connect(owner).deposit_HoldWETH({value: parseEther("1.0")}))

    await expect(depositAndWithdraw.Wrap_ETH({value: parseEther("10.0")})).
    to.emit(depositAndWithdraw,"deposit").
    withArgs(parseEther("10.0"));


    const owner_InitbalETH = await owner.getBalance();

    // console.log("Owner WETH balance before withdraw:",owner_InitbalWETH);
    console.log("Owner ETH balance after depositing:",await owner.getBalance());


    const owner_InitbalWETH = await weth_token.balanceOf(owner.address);

    await weth_token.connect(owner).approve(depositAndWithdraw.address,owner_InitbalWETH);

    const owner_allowance = await weth_token.connect(owner).allowance(owner.address,depositAndWithdraw.address);
   await expect(owner_allowance).to.be.equal(parseEther("10"));
    console.log("Owner set's the contract allowance to %s WETH", formatEther(owner_allowance,18));



    await expect(depositAndWithdraw.UnWrap_WETH(parseEther("5"))).
    to.emit(depositAndWithdraw,"withdraw").
    withArgs(parseEther("5"));

    await expect(depositAndWithdraw.UnWrap_WETH(parseEther("5"))).
    to.emit(depositAndWithdraw,"withdraw").
    withArgs(parseEther("5"));

    await expect(depositAndWithdraw.UnWrap_WETH(parseEther("1"))).
    to.be.revertedWith("INSUFFICIENT_USER_WETH_FUNDS");

    const owner_FinalETHbal = await owner.getBalance();
    const owner_FinalWETHbal = await weth_token.balanceOf(owner.address);

    console.log("Owner Final WETH Balance after unwrapping:", owner_FinalWETHbal );
    expect(owner_FinalWETHbal).to.equal(parseEther("0.0"));

    // const balDeltaWETH = formatEther((owner_InitbalWETH- owner_FinalWETHbal).toString(),18);
    // expect(balDeltaWETH).to.be.equal(("0.0"));

    console.log(formatEther(owner_InitbalETH,18));
    console.log(formatEther(owner_FinalETHbal,18));
    const balDeltaETH = Number(formatEther((owner_InitbalETH- owner_FinalETHbal).toString(),18));
    expect((balDeltaETH)).to.be.lessThanOrEqual((10.001));


    const wethFinalBalanceUser = await depositAndWithdraw.getWETHBalance(owner.address);
    const wethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractWETHBalance();
    const ethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractETHBalance();

    expect(wethFinalBalanceUser).to.be.equal(parseEther("0.0"));
    expect(wethFinalBalanceContract).to.be.equal(parseEther("0.0"));
    expect(ethFinalBalanceContract).to.be.equal(parseEther("0.0"));


});

  


it("UnWrap All WETH-2: Sender tries to withdraw all of the WETH balance", async function() {
    const {depositAndWithdraw, owner, addr1,addr2, weth_token} = await loadFixture(deployFixture);

    // const owner_InitbalWETH = await weth_token.balanceOf(owner.address);


    // await (depositAndWithdraw.connect(owner).deposit_HoldWETH({value: parseEther("1.0")}))

    await expect(depositAndWithdraw.Wrap_ETH({value: parseEther("10.0")})).
    to.emit(depositAndWithdraw,"deposit").
    withArgs(parseEther("10.0"));


    const owner_InitbalETH = await owner.getBalance();

    // console.log("Owner WETH balance before withdraw:",owner_InitbalWETH);
    console.log("Owner ETH balance after depositing:",await owner.getBalance());


    const owner_InitbalWETH = await weth_token.balanceOf(owner.address);

    await weth_token.connect(owner).approve(depositAndWithdraw.address,owner_InitbalWETH);

    const owner_allowance = await weth_token.connect(owner).allowance(owner.address,depositAndWithdraw.address);
   await expect(owner_allowance).to.be.equal(parseEther("10"));
    console.log("Owner set's the contract allowance to %s WETH", formatEther(owner_allowance,18));



    await expect(depositAndWithdraw.UnWrap_WETH(parseEther("10"))).
    to.emit(depositAndWithdraw,"withdraw").
    withArgs(parseEther("10"));


    await expect(depositAndWithdraw.UnWrap_WETH(parseEther("1"))).
    to.be.revertedWith("INSUFFICIENT_USER_WETH_FUNDS");

    const owner_FinalETHbal = await owner.getBalance();
    const owner_FinalWETHbal = await weth_token.balanceOf(owner.address);

    console.log("Owner Final WETH Balance after unwrapping:", owner_FinalWETHbal );
    expect(owner_FinalWETHbal).to.equal(parseEther("0.0"));

    // const balDeltaWETH = formatEther((owner_InitbalWETH- owner_FinalWETHbal).toString(),18);
    // expect(balDeltaWETH).to.be.equal(("0.0"));

    console.log(formatEther(owner_InitbalETH,18));
    console.log(formatEther(owner_FinalETHbal,18));
    const balDeltaETH = Number(formatEther((owner_InitbalETH- owner_FinalETHbal).toString(),18));
    expect((balDeltaETH)).to.be.lessThanOrEqual((10.001));


    const wethFinalBalanceUser = await depositAndWithdraw.getWETHBalance(owner.address);
    const wethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractWETHBalance();
    const ethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractETHBalance();

    expect(wethFinalBalanceUser).to.be.equal(parseEther("0.0"));
    expect(wethFinalBalanceContract).to.be.equal(parseEther("0.0"));
    expect(ethFinalBalanceContract).to.be.equal(parseEther("0.0"));


});



});

