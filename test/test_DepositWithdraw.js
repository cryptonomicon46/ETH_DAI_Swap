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
    const  Wrap_UnWrapETH = await ethers.getContractFactory("Wrap_UnWrapETH");
    const wrap_UnWrapETH = await Wrap_UnWrapETH.deploy(WETH_ADDRESS);
    await wrap_UnWrapETH.deployed();
    const WETH = new ethers.Contract(WETH_ADDRESS, ercAbi_weth, owner);
    // const DAI = new ethers.Contract(DAI_ADDRESS, ercAbi, owner);
    // console.log("DAI Contract Address:",DAI.address);
    console.log("WETH Contract Address:",WETH.address);
    console.log("Contract Address:", wrap_UnWrapETH.address);
    console.log("Deployer Address", owner.address );
    
    return {wrap_UnWrapETH, owner, addr1,addr2, WETH};
    }   


  it("Contract Deployed: check contract address to be a proper address", async function () {

    const {wrap_UnWrapETH} = await loadFixture(deployFixture);
    expect(wrap_UnWrapETH.address).to.be.a.properAddress;
  });

  


  


it("Wrap ETH: Sender deposits ETH to be wrapped into the contract using the doesNotExist functions", async function() {
    const {wrap_UnWrapETH, owner,addr1,addr2,WETH} = await loadFixture(deployFixture);

    const owner_InitbalWETH = await WETH.balanceOf(owner.address);
    console.log("Owner Initial WETH Balance:", owner_InitbalWETH);

    await expect(wrap_UnWrapETH.connect(owner).Wrap_ETH({value: parseEther("1.0")})).
    to.emit(wrap_UnWrapETH,"WrappedETH").
    withArgs(parseEther("1.0"));

    const owner_FinalWETHbal = await WETH.balanceOf(owner.address);
    console.log("Owner WETH Balance after unwrapping:", owner_FinalWETHbal);

    const balDelta = formatEther((owner_FinalWETHbal- owner_InitbalWETH).toString(),18);

    expect(balDelta).to.equal("1.0");

});



it("Un-Wrap WETH Signature: Sender deposits ETH to be wrapped into the contract using the doesNotExist functions", async function() {
    const {wrap_UnWrapETH, owner,addr1,addr2,WETH} = await loadFixture(deployFixture);

    // await expect(wrap_UnWrapETH.connect(owner).Wrap_ETH({value: parseEther("6000.0")})).
    // to.emit(wrap_UnWrapETH,"WrappedETH").
    // withArgs(parseEther("6000.0"));

    // console.log("Owner Initial ETH Balance:", await owner.getBalance());
    const owner_InitbalWETH = await WETH.balanceOf(owner.address);
    console.log("Owner WETH balance before withdraw:",owner_InitbalWETH);
    console.log("Owner ETH balance before withdraw:",await owner.getBalance());

    await wrap_UnWrapETH.connect(owner).UnWrap_WETH(owner_InitbalWETH)
    console.log("Owner Final WETH Balance:", await WETH.balanceOf(owner.address));
    console.log("Owner ETH balance after withdraw:",await owner.getBalance());

    // console.log("Owner Final ETH Balance:", await owner.getBalance());

    // await expect(wrap_UnWrapETH.connect(owner).Wrap_ETH({value: parseEther("1.0")})).
    // to.emit(wrap_UnWrapETH,"WrappedETH").
    // withArgs(parseEther("1.0"));

    // const owner_FinalWETHbal = await WETH.balanceOf(owner.address);
    // console.log("Owner WETH Balance after unwrapping:", owner_FinalWETHbal);

    // const balDelta = formatEther((owner_FinalWETHbal- owner_InitbalWETH).toString(),18);

    // expect(balDelta).to.equal("1.0");

});





});

