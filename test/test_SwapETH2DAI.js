const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const { parseEther, formatEther } = require("ethers/lib/utils");
const {time,loadFixture} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { parse } = require("dotenv");


const ETH_ADDRESS = "0x73bFE136fEba2c73F441605752b2B8CAAB6843Ec";
const DAI_ADDRESS = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WETH9_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

const DAI_DECIMALS = 18; 
const SwapRouterAddress = "0xE592427A0AEce92De3Edee1F18E0157C05861564"; 
console.log("ETH_ADDRESS:",ETH_ADDRESS);
console.log("DAI_ADDRESS:", DAI_ADDRESS);
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
                                                        ETH_ADDRESS,
                                                            SwapRouterAddress);
    await swapETH2DAI.deployed();
    const ETH = new ethers.Contract(ETH_ADDRESS, ercAbi, owner);
    const DAI = new ethers.Contract(DAI_ADDRESS, ercAbi, owner);

    console.log("Owner:", owner.address);
    console.log("Owner ETH Balance:",owner.address.balance);

    console.log("DAI Contract Address:",DAI.address);
    console.log("SwapRouter Address:", )
    return {swapETH2DAI, owner, ETH,DAI};
    }   


  it("Check Contract deployed and initial ETH/DAI balances of owner!", async function () {
    
    const {swapETH2DAI, owner,ETH,DAI} = await loadFixture(deploySimpleSwapFixture);
    expect(swapETH2DAI.address).to.be.a.properAddress;

    const owner_ETH_bal = (await owner.getBalance());

    let owner_DAI_bal_before = await DAI.balanceOf(owner.address);

    console.log("Owner: %s \n ETH_BAL: %o \n DAI_BAL:  %o",owner.address,
                                            ethers.utils.formatEther(owner_ETH_bal),
                                            ethers.utils.formatEther(owner_DAI_bal_before));
    // /* Check Initial ETH and DAI  Balances */ 
    const DAIBalanceBefore = Number(ethers.utils.formatUnits
        (owner_DAI_bal_before, 18))

    const ETHBalanceBefore = Number(ethers.utils.formatUnits
            (owner_ETH_bal, 18))
    expect(DAIBalanceBefore).to.be.equal(parseEther("0"));
    expect(ETHBalanceBefore).to.be.greaterThan(9000);



    // //Swap function will be reverted with STF
    // await expect(simpleswap.swapETHForDai(parseEther("1")))
    // .to.be.revertedWith("STF");

    // // /* Approve the swapper contract to spend weth9 for me */
    // await expect(WETH.approve(simpleswap.address, parseEther("10"))).
    // to.emit(WETH,"Approval").withArgs(owner.address,simpleswap.address,parseEther("10"));
    
    // // /* Execute the swap */
    // await simpleswap.swapWETHForDai(parseEther("1"));

    
    // // /* Test that we now have more DAI than when we started */
    // let owner_DAI_bal_after = await DAI.balanceOf(owner.address)
    // const DAIBalanceAfter = Number(ethers.utils.formatUnits
    //     (owner_DAI_bal_after, 18))

    // console.log("DAI Balance after:",DAIBalanceAfter);
    // expect(DAIBalanceAfter).is.greaterThan(DAIBalanceBefore);

  });

    it("Owner tries sending <0.1 ETH to contract, must revert and confirm all balances are still zero", async function () {
        const {swapETH2DAI, owner,ETH,DAI} = await loadFixture(deploySimpleSwapFixture);

    await expect(owner.sendTransaction({
        to: swapETH2DAI.address,
        value: parseEther("0.1"),
      })).to.be.revertedWith("INVALID_INPUT_ETH_VALUE");
    
    const contract_bal = await ethers.provider.getBalance(swapETH2DAI.address);
    //  console.log("Contract balance after transfer:", ethers.utils.formatEther(contract_bal));
     expect(contract_bal).to.be.equal(parseEther('0'));

     const ETHWithdrawal = await swapETH2DAI.connect(owner).getETHBalance();
     const DAIithdrawal = await swapETH2DAI.connect(owner).getDAIBalance();

     expect(ETHWithdrawal).to.be.equal(parseEther('0'));
     expect(DAIithdrawal).to.be.equal(parseEther('0'));

    });




    it("Send 10 ETH to the contract and check ETH/DAI/contract balances", async function () {
        const {swapETH2DAI, owner,ETH,DAI} = await loadFixture(deploySimpleSwapFixture);


        await expect(() => owner.sendTransaction({to: swapETH2DAI.address, value: parseEther("10")}))
        .to.changeEtherBalance(owner, parseEther("-10"));
        
    const contract_bal = await ethers.provider.getBalance(swapETH2DAI.address);
    //  console.log("Contract balance after transfer:", ethers.utils.formatEther(contract_bal));

      const ETHBalance = await swapETH2DAI.connect(owner).getETHBalance();
      const DAIBalance = await swapETH2DAI.connect(owner).getDAIBalance();


      expect(contract_bal).to.be.equal(parseEther('10'));
      expect(ETHBalance).to.be.equal(parseEther('10'));
      expect(DAIBalance).to.be.equal(parseEther('0'));

    });


    it("Send ETH to contract and withdraw it and confirm withdraw event with args", async function () {
        const {swapETH2DAI, owner,ETH,DAI} = await loadFixture(deploySimpleSwapFixture);

        await owner.sendTransaction({
            to: swapETH2DAI.address,
            value: parseEther("10"),
          });
        

          const ETHBalance = await swapETH2DAI.connect(owner).getETHBalance();
          const DAIBalance = await swapETH2DAI.connect(owner).getDAIBalance();
          const contract_bal = await ethers.provider.getBalance(swapETH2DAI.address);

    
          expect(contract_bal).to.be.equal(parseEther('10'));
          expect(ETHBalance).to.be.equal(parseEther('10'));
          expect(DAIBalance).to.be.equal(parseEther('0'));

          await expect(swapETH2DAI.connect(owner).withdrawETH()).
          to.emit(swapETH2DAI,"WithDrawETH").withArgs(ETHBalance);
   


    });


    it("Owner sends 10 ETH, Execute a swap on all 10 ETH, check Contract/ETH/DAI balances and withdrawal", async function () {});

    it("Owner sends 10 ETH, Execute a swap on 5 ETH, check Contract/ETH/DAI balances and withdrawal of ETH/DAI and ETH refund", async function () {});


    it("Check for malicious contract trying to reenter and withdraw contract balance", async function () {});




});
