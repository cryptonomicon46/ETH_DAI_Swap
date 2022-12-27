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
    const  DepositAndWithdraw = await ethers.getContractFactory("DepositAndWithdraw");
    const depositAndWithdraw = await DepositAndWithdraw.deploy(WETH_ADDRESS);
    await depositAndWithdraw.deployed();
    const WETH = new ethers.Contract(WETH_ADDRESS, ercAbi_weth, owner);
    // const DAI = new ethers.Contract(DAI_ADDRESS, ercAbi, owner);
    // console.log("DAI Contract Address:",DAI.address);
    console.log("WETH Contract Address:",WETH.address);
    console.log("Contract Address:", depositAndWithdraw.address);
    console.log("Deployer Address", owner.address );
    
    return {depositAndWithdraw, owner, addr1,addr2, WETH};
    }   


  it("Contract Deployed: check contract address to be a proper address", async function () {

    const {depositAndWithdraw} = await loadFixture(deployFixture);
    expect(depositAndWithdraw.address).to.be.a.properAddress;
  });

  

  it("Deposit, WETH Not Held: Sender deposits ETH, contract transfers back WETH to sender", async function() {
    const {depositAndWithdraw, owner,addr1,addr2,WETH} = await loadFixture(deployFixture);

    const owner_InitbalWETH = await WETH.balanceOf(owner.address);
    console.log("Owner Initial WETH Balance:", owner_InitbalWETH);

    await expect(depositAndWithdraw.deposit({value: parseEther("1.0")})).
    to.emit(depositAndWithdraw,"deposit_NotHeld").
    withArgs(parseEther("1.0"));

    const owner_FinalWETHbal = await WETH.balanceOf(owner.address);
    console.log("Owner WETH Balance after wrapping:", owner_FinalWETHbal);

    const balDelta = formatEther((owner_FinalWETHbal- owner_InitbalWETH).toString(),18);

    expect(balDelta).to.equal("1.0");


    const wethFinalBalanceUser = await depositAndWithdraw.getWETHBalance(owner.address);
    const wethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractWETHBalance();
    const ethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractBalance();
    expect(wethFinalBalanceUser).to.be.equal(parseEther("1.0"));
    expect(wethFinalBalanceContract).to.be.equal(parseEther("0"));
    expect(ethFinalBalanceContract).to.be.equal(parseEther("0"));

});

it("Deposit Hold WETH: Sender deposits ETH, contract holds the WETH", async function() {
    const {depositAndWithdraw, owner,addr1,addr2,WETH} = await loadFixture(deployFixture);

    const owner_InitbalWETH = await WETH.balanceOf(owner.address);
    console.log("Owner Initial WETH Balance:", owner_InitbalWETH);

    await expect(depositAndWithdraw.deposit_HoldWETH({value: parseEther("1.0")})).
    to.emit(depositAndWithdraw,"deposit_holdWETH").
    withArgs(parseEther("1.0"));

    const wethFinalBalanceUser = await depositAndWithdraw.getWETHBalance(owner.address);
    const wethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractWETHBalance();
    const ethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractBalance();
    expect(wethFinalBalanceUser).to.be.equal(parseEther("0"));
    expect(wethFinalBalanceContract).to.be.equal(parseEther("1.0"));
    expect(ethFinalBalanceContract).to.be.equal(parseEther("0"));

});


it("Withdraw: Sender tries to withdraw from WETH contract", async function() {
    const {depositAndWithdraw, owner,addr1,addr2,WETH} = await loadFixture(deployFixture);

    const owner_InitbalWETH = await WETH.balanceOf(owner.address);
    const owner_InitbalETH = await owner.getBalance();

    console.log("Owner WETH balance before withdraw:",owner_InitbalWETH);
    console.log("Owner ETH balance before withdraw:",await owner.getBalance());

    await (depositAndWithdraw.connect(owner).deposit_HoldWETH({value: parseEther("1.0")}))

    await depositAndWithdraw.connect(owner).withdraw();

    const owner_FinalWETHbal = await WETH.balanceOf(owner.address);
    const owner_FinalETHbal = await owner.getBalance();

    console.log("Owner WETH Balance after wrapping:", owner_FinalWETHbal);

    const balDeltaWETH = formatEther((owner_InitbalWETH- owner_FinalWETHbal).toString(),18);
    expect(balDeltaWETH).to.be.equal(("0.0"));


    const balDeltaETH = Number(formatEther((owner_InitbalETH- owner_FinalETHbal).toString(),18));
    expect((balDeltaETH)).to.be.lessThanOrEqual((0.001));

    expect(owner_FinalWETHbal).to.equal(parseEther("0.0"));
    expect(owner_FinalWETHbal).to.equal(parseEther("0.0"));

    const wethFinalBalanceUser = await depositAndWithdraw.getWETHBalance(owner.address);
    const wethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractWETHBalance();
    const ethFinalBalanceContract = await depositAndWithdraw.connect(owner).getContractBalance();
    expect(wethFinalBalanceUser).to.be.equal(parseEther("0.0"));
    expect(wethFinalBalanceContract).to.be.equal(parseEther("0.0"));
    expect(ethFinalBalanceContract).to.be.equal(parseEther("0.0"));


    // console.log(depositAndWithdraw.getBalance())
});

  




});

