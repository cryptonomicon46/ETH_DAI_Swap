const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { parseEther, formatEther } = require("ethers/lib/utils");
const {time,loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { parse } = require("dotenv");
const { ADDRESS_ZERO } = require("@uniswap/v3-sdk");


const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; //Mainnet WETH contract address
// const WETH_ADDRESS = "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6"; //Goerli WETH contract address

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

const NOTEOA_abi = [
    "function callDepositAllETH() internal"
]

// We connect to the Contract using a Provider, so we will only
// have read-only access to the Contract


describe("SwapContract", function () {


    async function deploySwapFixture() {

    [owner,addr1,addr2] = await ethers.getSigners();
    const  SwapContract = await ethers.getContractFactory("SwapContract");
    console.log("Deploying SwapContract ...\n");
    const swapContract = await SwapContract.deploy(WETH_ADDRESS,DAI_ADDRESS,SwapRouterAddress);
    await swapContract.deployed();
    console.log("Swap contract deployed at %s:", swapContract.address);
    console.log("\nDeploying NOTEOA contract...\n");
    
    const NOTEOA = await ethers.getContractFactory("NOTEOA");
    const notEOA = await NOTEOA.connect(addr1).deploy(swapContract.address);
    const WETH = new ethers.Contract(WETH_ADDRESS, ercAbi, owner);
    const DAI = new ethers.Contract(DAI_ADDRESS, ercAbi, owner);

    console.log("DAI Contract Address:",DAI.address);
    console.log("GETH Contract Address:",WETH.address);
    return {swapContract, owner, addr1,WETH,DAI,notEOA};
    }   


    it("Contract deposit SomeETH: External contracts aren't allowed to interact, only EOAs can deposit ETH", async function() {
        const {swapContract, owner,addr1,WETH,DAI,notEOA} = await loadFixture(deploySwapFixture);
        await expect(notEOA.connect(owner).callDepositSwapSomeETH()).
        to.be.revertedWith("NOT_THE_OWNER");

        await expect(notEOA.connect(addr1).callDepositSwapSomeETH()).
        to.be.revertedWith("NOT_ALLOWED_TO_PARTICIPATE_SwapSomeETH");
    
        await expect(swapContract.connect(owner).SwapSomeETH_DAI(parseEther("0.5"),{value: parseEther("1.0")})).
        to.emit(swapContract,"SwapCompleted");
        // console.log("DAI Contract balance:",await (dai).getBalance());


    })


    it("Contract deposit AllETH: External contracts aren't allowed to interact, only EOAs can deposit ETH", async function() {
        const {swapContract, owner,addr1,WETH,DAI,notEOA} = await loadFixture(deploySwapFixture);
        await expect(notEOA.connect(owner).callDepositSwapAllETH()).
        to.be.revertedWith("NOT_THE_OWNER")

        await expect(notEOA.connect(addr1).callDepositSwapAllETH()).
        to.be.revertedWith("NOT_ALLOWED_TO_PARTICIPATE_SwapAllETH")

        await expect(swapContract.connect(owner).SwapAllETH_DAI({value: parseEther("1.0")})).
        to.emit(swapContract,"SwapCompleted");
        
    })



  it("Contract deployed: Deploy contract and check for proper address!", async function () {
    
    const {swapContract, owner,addr1,WETH,DAI,notEOA} = await loadFixture(deploySwapFixture);
    expect(swapContract.address).to.be.a.properAddress;

  });





  it("Toggle Contract: In case of an emergency toggle contract state", async function() {
    const {swapContract, owner,addr1,WETH,DAI,notEOA} = await loadFixture(deploySwapFixture);
    
    
    await expect(swapContract.connect(addr1).ToggleContract()).
    to.be.reverted;



    await expect(swapContract.connect(owner).ToggleContract()).
    to.emit(swapContract,"ToggleStartStop").
    withArgs(true);


    await expect(swapContract.connect(owner).ToggleContract()).
    to.emit(swapContract,"ToggleStartStop").
    withArgs(false);


    await expect(swapContract.connect(owner).ToggleContract()).
    to.emit(swapContract,"ToggleStartStop").
    withArgs(true);

   

 
})



    it("Some ETH: Only uses amountTOUse to wrap Wraps ETH to WETH and emits an event", async function() {
        const {swapContract, owner,addr1,WETH,DAI,notEOA} = await loadFixture(deploySwapFixture);
        console.log("Testing Swap Some ETH...");
        console.log("Sent ETH:%s", 10);
        console.log("Amount ETH to be used for the swap:%s", 5);
        const owner_DAI_bal_before = await DAI.balanceOf(owner.address);
        const DAIBalanceBefore = Number(ethers.utils.formatUnits
            (owner_DAI_bal_before, 18))

        const bal0 = await owner.getBalance();
        await expect(swapContract.connect(owner).SwapSomeETH_DAI(parseEther("5"),{value: parseEther("10.0")})).
        to.emit(swapContract,"SwapCompleted");

        const bal1 = await owner.getBalance();

        const balDelta = formatEther((bal0- bal1).toString(),18);

        const owner_DAI_bal_after = await DAI.balanceOf(owner.address);
        const DAIBalanceAfter = Number(ethers.utils.formatUnits
            (owner_DAI_bal_after, 18))

        await expect(Number(balDelta)).to.be.greaterThanOrEqual(4.99);
        await expect(Number(balDelta)).to.be.lessThanOrEqual(5.1);
    
        expect(DAIBalanceAfter).to.be.greaterThan(DAIBalanceBefore);


        console.log("Confirming the amount used after the swap:",balDelta);
        console.log("Owner's DAI balance before the swapp:%s", DAIBalanceBefore);
        console.log("Owner's DAI balance after the swapp:%s", DAIBalanceAfter);

    
     
    })

    it("All: swap must complete and emit event, check DAI balance after the swap!", async function () {
        const {swapContract, owner,addr1,WETH,DAI,notEOA} = await loadFixture(deploySwapFixture);
        console.log("Testing Swap All ETH...");
        console.log("Sent ETH:%s", 10);
        const owner_DAI_bal_before = await DAI.balanceOf(owner.address);
        const DAIBalanceBefore = Number(ethers.utils.formatUnits
            (owner_DAI_bal_before, 18))
    
    // const amountOUT  =  await swapETH2DAI.SwapETHToDai({ value: parseEther("1") })

        const tx =  await swapContract.SwapAllETH_DAI({ value: parseEther("10") });
        const rc = await tx.wait(); // 0ms, as tx is already confirmed
        const event = rc.events.find(event => event.event === 'SwapCompleted');
        const [value] = event.args;
        console.log("SwapCompleted event value:",value);

        const owner_DAI_bal_after = await DAI.balanceOf(owner.address);
        const DAIBalanceAfter = Number(ethers.utils.formatUnits
            (owner_DAI_bal_after, 18))
        
        console.log("Owner's DAI balance before the swap:",formatEther(owner_DAI_bal_after));
        console.log("Owner's DAI balance after the swap:",formatEther(owner_DAI_bal_before));

        expect(DAIBalanceAfter).to.be.greaterThan(DAIBalanceBefore);

        // expect(value).to.be.equal(owner_DAI_bal_after);

       
    });




    it("Toggle Contract to stop some ETH swap: In case of an emergency toggle contract state", async function() {
        const {swapContract, owner,addr1,WETH,DAI,notEOA} = await loadFixture(deploySwapFixture);
        
        
    
        await expect(swapContract.connect(owner).ToggleContract()).
        to.emit(swapContract,"ToggleStartStop").
        withArgs(true);
    
        await expect(swapContract.connect(owner).SwapSomeETH_DAI(parseEther("5"),{value: parseEther("10.0")})).
        to.be.revertedWith("DEPOSITS_DISABLED");
       
        await expect(swapContract.connect(owner).ToggleContract()).
        to.emit(swapContract,"ToggleStartStop").
        withArgs(false);
    
        await expect(swapContract.connect(owner).SwapSomeETH_DAI(parseEther("5"),{value: parseEther("10.0")})).
        to.emit(swapContract,"SwapCompleted");
     
    })
    
    
    it("Toggle Contract to stop ALL ETH swap: In case of an emergency toggle contract state", async function() {
        const {swapContract, owner,addr1,WETH,DAI,notEOA} = await loadFixture(deploySwapFixture);
        
        
    
        await expect(swapContract.connect(owner).ToggleContract()).
        to.emit(swapContract,"ToggleStartStop").
        withArgs(true);
    
        await expect(swapContract.connect(owner).SwapSomeETH_DAI(parseEther("5"),{value: parseEther("10.0")})).
        to.be.revertedWith("DEPOSITS_DISABLED");
       
        await expect(swapContract.connect(owner).ToggleContract()).
        to.emit(swapContract,"ToggleStartStop").
        withArgs(false);
    
        await expect(swapContract.connect(owner).SwapAllETH_DAI({value: parseEther("10.0")})).
        to.emit(swapContract,"SwapCompleted");
     
    })
    


});

