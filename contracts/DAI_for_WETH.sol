// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "hardhat/console.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// import "./IERC20.sol";
import "./IWETH.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

  /// @notice SwapSomeDAI_WETH will swap DAI to WETH
  /// This contract has two functions as explained below
  /// SwapDAI_WETH: uses some amount of the msg.value and refunds the remaining to the caller

 
contract DAI_for_WETH {
    ISwapRouter public immutable swapRouter;
    using SafeMath for uint;
    // address  public immutable DAI;
    // address  public immutable WETH;
    address private _owner;
    IWETH private weth;
    IERC20 private dai;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // UniSwap private uni = new UniSwap();
    event SwapCompleted(uint _amount);
    event Refund(address _refunder, uint _value);
    constructor(
            address  WETH_,
            address  DAI_,
            ISwapRouter _swapRouter)  payable {
        weth = IWETH(WETH_);
        dai = ERC20(DAI_);
        swapRouter = _swapRouter;
        _owner = msg.sender;
    }

  
  
/// @notice SwapDAI_WETH takes in the user's DAI to swap to WETH
    ///@param amountDai input DAI amount to swap
    /// emits a SwapCompleted event
    function SwapDAI_WETH(uint amountDai) external payable returns (uint amountOut) {
        console.log("Input DAI Amount=", amountDai);
        dai.approve(address(this),amountDai);
        console.log("Approved contract to deposit DAI..");

        uint allowance = ERC20(DAI).allowance(msg.sender, address(this));
        console.log("Contract allowance:", allowance);
        // uint amountDai = dai.balanceOf(address(this));


        // dai.transferFrom(DAI,address(this),amountDai);
        // console.log("Transferred DAI from owner to contract successfully..");
        
        // amountDai = dai.balanceOf(address(this));

        // console.log("Dai balance of address(this) after:",amountDai);
      
        // dai.approve(address(swapRouter), amountInDai);
        // uint getRouterAllowance = weth.allowance(address(this),address(swapRouter));
        // console.log("Swap Router's DAI allowance updated to:",getRouterAllowance);

        // amountOut = _swap(amountInDai);
        // console.log("amountOut WETH:", amountOut);
        emit SwapCompleted(amountOut);
    }

    /// @notice _swap internal function that  swaps amountIn tokens to exact amountOut
    /// using the DAI/WETH9 0.3% pool by calling the 
    /// @param amountIn  fixed amount of token input DAI or WETH
    /// @param _amountOut maximum possible output of WET or DAI received
    ///

    function _swap(uint amountIn) internal returns (uint _amountOut) 
    {
        ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn : DAI,
                tokenOut : WETH,
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            //Executes the swap
        _amountOut = ISwapRouter(swapRouter).exactInputSingle(params);
        console.log("amountOut=", _amountOut);     
    }




    /// @notice owner, returns the owner address or deployer address
    /// @return owner who deployed the SwapETH2DAI contract
    function owner() external view returns (address) {
        return _owner;
    }

    ///@notice checks if the msg.sender is the owner who deployed this contract
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }

    ///@notice contractBalance , returns the balance of the contract
    ///@return uint: the balance amount returned in UINT
    ///@dev uses the onlyOwner modifier, and hence can only be called by the contract deployer
    function contractBalance() external view onlyOwner returns (uint) {
        return address(this).balance;
    }



    }