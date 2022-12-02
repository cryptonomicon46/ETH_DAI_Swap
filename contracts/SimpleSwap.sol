
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "hardhat/console.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
// import "./interfaces/external/IWETH9.sol";
contract SimpleSwap {
    ISwapRouter public immutable swapRouter;

    address public immutable DAI;
    address public immutable WETH9;
    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;
    event SwapETHForDai(uint amountIn);
    event SwapWethForDai_EOS(uint amountOut, uint amountInMaximum);

    constructor(address DAI_, 
            address WETH9_,
              ISwapRouter _swapRouter) {

        DAI = DAI_;
        WETH9 = WETH9_;        
        swapRouter = _swapRouter;
    }
    /// @notice swapWETHforDai_EIS (EIS-ExactInputSingle) swaps amountIn tokens to exact amountOut
    /// using the DAI/WETH9 0.3% pool by calling the 
    /// @param amountIn  fixed amount of token input DAI or WETH
    /// @param amountOut maximum possible output of WET or DAI received
    ///
    function swapETHForDai(uint amountIn) external returns (uint amountOut) 
    {
        TransferHelper.safeTransferFrom(WETH9,msg.sender,address(this),amountIn);
        TransferHelper.safeApprove(WETH9, address(swapRouter),amountIn);


        ISwapRouter.ExactInputSingleParams memory params = 
            ISwapRouter.ExactInputSingleParams({
                tokenIn : WETH9,
                tokenOut : DAI,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            //Executes the swap
        amountOut = ISwapRouter(swapRouter).exactInputSingle(params);
        emit SwapETHForDai(amountIn);
        console.log("amountOut=", amountOut);
        
    }
/// @notice swapWETHForDai_EOS (EOS-ExactOutputSwap) swaps a minimum possible amount of WETH9 for a fixed amount of DAI.
/// @dev The calling address must approve this contract to spend its WETH9 for this function to succeed. As the amount of input WETH9 is variable,
/// the calling address will need to approve for a slightly higher amount, anticipating some variance.
/// @param amountOut The exact amount of DAI to receive from the swap.
/// @param amountInMaximum The amount of WETH9 we are willing to spend to receive the specified amount of DAI.
/// @return amountIn The amount of DAI actually spent in the swap.

    function swapWETHForDai_EOS(uint amountOut , uint amountInMaximum) external returns (uint amountIn) {

        TransferHelper.safeTransferFrom(WETH9,msg.sender, address(this),amountInMaximum);
        TransferHelper.safeApprove(WETH9,address(swapRouter),amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params = 
          ISwapRouter.ExactOutputSingleParams({
                tokenIn : WETH9,
                tokenOut : DAI,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
          });

          amountIn = ISwapRouter(swapRouter).exactOutputSingle(params);
          console.log("amountIn=", amountIn);
         emit SwapWethForDai_EOS(amountOut,amountInMaximum);
          if(amountIn < amountInMaximum) {
            TransferHelper.safeApprove(WETH9, address(swapRouter),0);
            TransferHelper.safeTransfer(WETH9, msg.sender, amountInMaximum-amountIn);
            console.log("refundAmount =",amountInMaximum- amountIn);
          }


    }
    }