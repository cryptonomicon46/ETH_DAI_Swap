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
  "function balanceOf(address owner) view returns (uint256)",
  // Authenticated Functions
  "function transfer(address to, uint amount) returns (bool)",
  "function deposit() public payable",
  "function approve(address spender, uint256 amount) returns (bool)",
  "event Transfer(address indexed _from, address indexed _to, uint256 _value)",
"event Approval(address indexed _owner, address indexed _spender, uint256 _value)"

];


// We connect to the Contract using a Provider, so we will only
// have read-only access to the Contract


describe("SwapETH2DAI", function () {


    async function deploySimpleSwapFixture() {

    [owner,addr1,addr2] = await ethers.getSigners();
    const  SwapETH2DAI = await ethers.getContractFactory("SwapETH2DAI");
    const swapETH2DAI = await SwapETH2DAI.deploy(DAI_ADDRESS,
                                                        WETH_ADDRESS,
                                                            SwapRouterAddress);
    await swapETH2DAI.deployed();
    const WETH = new ethers.Contract(WETH_ADDRESS, ercAbi, owner);
    const DAI = new ethers.Contract(DAI_ADDRESS, ercAbi, owner);

    console.log("Owner:", owner.address);
    console.log("Owner ETH Balance:",owner.address.balance);
    console.log("DAI Contract Address:",DAI.address);
    console.log("SwapRouter Address:", )
    return {swapETH2DAI, owner, WETH,DAI};
    }   


  it("Contract Deployed: Check Contract deployed and initial ETH/DAI balances of owner!", async function () {
    
    const {swapETH2DAI, owner,WETH,DAI} = await loadFixture(deploySimpleSwapFixture);
    expect(swapETH2DAI.address).to.be.a.properAddress;

    const owner_ETH_bal_before = (await owner.getBalance());

    let owner_DAI_bal_before = await DAI.balanceOf(owner.address);
    let owner_WETH_bal_before = await WETH.balanceOf(owner.address);



    // /* Check Initial ETH and DAI  Balances */ 
    const DAIBalanceBefore = Number(ethers.utils.formatUnits
        (owner_DAI_bal_before, 18))

    const WETHBalanceBefore = Number(ethers.utils.formatUnits
            (owner_WETH_bal_before, 18))

    const ETHBalanceBefore = Number(ethers.utils.formatUnits
                (owner_ETH_bal_before, 18))
    
    // expect(DAIBalanceBefore).to.be.equal(0);
    // expect(WETHBalanceBefore).to.be.equal(0);
    // expect(ETHBalanceBefore).to.be.greaterThan(9000);
    console.log("Owner: %s \n ETH_BAL: %o \n DAI_BAL:  %o \n WETH_BAL:",owner.address,
                                            ethers.utils.formatEther(owner_ETH_bal_before),
                                            ethers.utils.formatEther(owner_DAI_bal_before),
                                            ethers.utils.formatEther(owner_WETH_bal_before));

  });

    it("Swap Fails: Owner tries to swap <0.1 ETH , operatation must revert with a message!", async function () {
        const {swapETH2DAI, owner,WETH,DAI} = await loadFixture(deploySimpleSwapFixture);
    
        await expect(swapETH2DAI.SwapETHToDai({ value: parseEther("0.1") })).
        to.be.revertedWith("ETH_VALUE_TOO_LOW");

 
    });

    it("Swap Succeeds: Owner tries to swap > 0.1 ETH, confirm that SwapCompleted is emitted!", async function () {
        const {swapETH2DAI, owner,WETH,DAI} = await loadFixture(deploySimpleSwapFixture);
    
        const owner_DAI_bal_before = await DAI.balanceOf(owner.address);
        const DAIBalanceBefore = Number(ethers.utils.formatUnits
            (owner_DAI_bal_before, 18))
    
    // const amountOUT  =  await swapETH2DAI.SwapETHToDai({ value: parseEther("1") })

    await expect(swapETH2DAI.SwapETHToDai({ value: parseEther("1") })).
    to.emit(swapETH2DAI,"SwapCompleted");

    
 
    });

    it("DAI amountOut: Owner tries to swap > 0.1 ETH, swap must complete successfully, check value in the emitted event, check DAI balance of the owner!", async function () {
        const {swapETH2DAI, owner,WETH,DAI} = await loadFixture(deploySimpleSwapFixture);
    
        const owner_DAI_bal_before = await DAI.balanceOf(owner.address);
        const DAIBalanceBefore = Number(ethers.utils.formatUnits
            (owner_DAI_bal_before, 18))
    
    // const amountOUT  =  await swapETH2DAI.SwapETHToDai({ value: parseEther("1") })

    const tx =  await swapETH2DAI.SwapETHToDai({ value: parseEther("1") });
    const rc = await tx.wait(); // 0ms, as tx is already confirmed
    const event = rc.events.find(event => event.event === 'SwapCompleted');
    const [value] = event.args;
    console.log("SwapCompleted event value:",value);

    const owner_DAI_bal_after = await DAI.balanceOf(owner.address);
    const DAIBalanceAfter = Number(ethers.utils.formatUnits
        (owner_DAI_bal_after, 18))


    console.log((owner_DAI_bal_after));
    console.log(DAIBalanceAfter);

        expect(DAIBalanceAfter).to.be.greaterThan(DAIBalanceBefore);

        // expect(value).to.be.equal(owner_DAI_bal_before);

 
    });

  


});

